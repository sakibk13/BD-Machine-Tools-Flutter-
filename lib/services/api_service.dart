import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:dio/dio.dart' as dio_client;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/product.dart';
import '../models/order.dart';
import '../models/customer.dart';

class ApiService {
  static const String baseUrl = "https://bdmachinetools.com/wp-json/wc/v3/";
  static const String wpBaseUrl = "https://bdmachinetools.com/wp-json/wp/v2/";
  
  static String get consumerKey => dotenv.env['WOO_CONSUMER_KEY'] ?? '';
  static String get consumerSecret => dotenv.env['WOO_CONSUMER_SECRET'] ?? '';

  Future<Map<String, dynamic>> login(String username, String password) async {
    try {
      // With Application Passwords, we verify by calling /users/me with Basic Auth
      final authString = base64Encode(utf8.encode('$username:$password'));
      
      final response = await http.get(
        Uri.parse("${wpBaseUrl}users/me"),
        headers: {
          'Authorization': 'Basic $authString',
        },
      );

      final body = json.decode(response.body);

      if (response.statusCode == 200) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('app_username', username);
        await prefs.setString('app_password', password);
        await prefs.setString('user_display_name', body['name'] ?? username);
        await prefs.setString('user_email', body['email'] ?? '');
        
        return {"success": true, "data": {
          "user_display_name": body['name'] ?? username
        }};
      } else {
        return {
          "success": false,
          "message": body['message'] ?? "Invalid username or application password"
        };
      }
    } catch (e) {
      return {"success": false, "message": "Connection error: $e"};
    }
  }

  Future<Map<String, String>> get _headers async {
    final prefs = await SharedPreferences.getInstance();
    final username = prefs.getString('app_username');
    final password = prefs.getString('app_password');

    String auth;
    if (username != null && password != null) {
      // Use logged in user credentials
      auth = base64Encode(utf8.encode('$username:$password'));
    } else {
      // Fallback to WooCommerce API keys
      auth = base64Encode(utf8.encode('$consumerKey:$consumerSecret'));
    }

    return {
      'Authorization': 'Basic $auth',
      'Content-Type': 'application/json',
    };
  }

  // Helper for Multipart/Media Uploads
  final dio_client.Dio _dio = dio_client.Dio();

  Future<String?> uploadImage(File imageFile) async {
    try {
      String fileName = imageFile.path.split('/').last;
      dio_client.FormData formData = dio_client.FormData.fromMap({
        "file": await dio_client.MultipartFile.fromFile(imageFile.path, filename: fileName),
      });

      final headers = await _headers;
      final response = await _dio.post(
        "${wpBaseUrl}media",
        data: formData,
        options: dio_client.Options(
          headers: headers,
        ),
      );

      if (response.statusCode == 201) {
        return response.data['source_url'];
      }
      return null;
    } catch (e) {
      print("Image Upload Error: $e");
      return null;
    }
  }

  Future<List<Product>> getProducts({int? categoryId}) async {
    try {
      String url = "${baseUrl}products?per_page=50";
      if (categoryId != null && categoryId > 0) {
        url += "&category=$categoryId";
      }
      final headers = await _headers;
      final response = await http.get(Uri.parse(url), headers: headers);
      if (response.statusCode == 200) {
        List<dynamic> data = json.decode(response.body);
        return data.map((json) => Product.fromJson(json)).toList();
      }
      throw Exception("Failed to load products");
    } catch (e) {
      throw Exception("Error: $e");
    }
  }

  Future<List<Order>> getOrders() async {
    try {
      final headers = await _headers;
      final response = await http.get(Uri.parse("${baseUrl}orders"), headers: headers);
      if (response.statusCode == 200) {
        List<dynamic> data = json.decode(response.body);
        return data.map((json) => Order.fromJson(json)).toList();
      }
      throw Exception("Failed to load orders");
    } catch (e) {
      throw Exception("Error: $e");
    }
  }

  Future<List<Customer>> getCustomers() async {
    try {
      final headers = await _headers;
      final response = await http.get(Uri.parse("${baseUrl}customers"), headers: headers);
      if (response.statusCode == 200) {
        List<dynamic> data = json.decode(response.body);
        return data.map((json) => Customer.fromJson(json)).toList();
      }
      throw Exception("Failed to load customers");
    } catch (e) {
      throw Exception("Error: $e");
    }
  }

  Future<Map<String, dynamic>> createProduct(Map<String, dynamic> data) async {
    try {
      final headers = await _headers;
      final response = await http.post(
        Uri.parse("${baseUrl}products"),
        headers: headers,
        body: json.encode(data),
      );
      
      final body = json.decode(response.body);
      if (response.statusCode == 201) {
        return {"success": true, "message": "Product created successfully!"};
      } else {
        return {
          "success": false, 
          "message": body['message'] ?? "Could not create product. Error: ${response.statusCode}"
        };
      }
    } catch (e) {
      return {"success": false, "message": "Connection error: $e"};
    }
  }

  Future<Map<String, dynamic>> createCategory(Map<String, dynamic> data) async {
    try {
      final headers = await _headers;
      final response = await http.post(
        Uri.parse("${baseUrl}products/categories"),
        headers: headers,
        body: json.encode(data),
      );
      final body = json.decode(response.body);
      if (response.statusCode == 201) {
        return {"success": true, "message": "Category created!"};
      } else {
        return {"success": false, "message": body['message'] ?? "Error ${response.statusCode}"};
      }
    } catch (e) {
      return {"success": false, "message": "Connection error"};
    }
  }

  Future<Map<String, dynamic>> updateProduct(int id, Map<String, dynamic> data) async {
    try {
      final headers = await _headers;
      final response = await http.put(
        Uri.parse("${baseUrl}products/$id"),
        headers: headers,
        body: json.encode(data),
      );
      final body = json.decode(response.body);
      if (response.statusCode == 200) {
        return {"success": true, "message": "Updated successfully!"};
      } else {
        return {"success": false, "message": body['message'] ?? "Error ${response.statusCode}"};
      }
    } catch (e) {
      return {"success": false, "message": "Connection error"};
    }
  }

  Future<bool> deleteProduct(int id) async {
    try {
      final headers = await _headers;
      final response = await http.delete(
        Uri.parse("${baseUrl}products/$id?force=true"),
        headers: headers,
      );
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  Future<List<Map<String, dynamic>>> getCategories() async {
    try {
      final headers = await _headers;
      final response = await http.get(Uri.parse("${baseUrl}products/categories?per_page=100"), headers: headers);
      if (response.statusCode == 200) {
        List<dynamic> data = json.decode(response.body);
        return data.map((json) => {
          "id": json['id'],
          "name": json['name'],
          "parent": json['parent'],
        }).toList();
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  Future<bool> updateOrderStatus(int id, String status) async {
    try {
      final headers = await _headers;
      final response = await http.put(
        Uri.parse("${baseUrl}orders/$id"),
        headers: headers,
        body: json.encode({"status": status}),
      );
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }
  Future<Map<String, dynamic>> getReport() async {
    try {
      final headers = await _headers;
      final response = await http.get(Uri.parse("${baseUrl}reports/sales?period=last_7days"), headers: headers);
      if (response.statusCode == 200) {
        return (json.decode(response.body) as List).first;
      }
      return {};
    } catch (e) {
      return {};
    }
  }
}
