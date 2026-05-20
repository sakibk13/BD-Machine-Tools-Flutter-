class Product {
  final int id;
  final String name;
  final String modelName;
  final String description;
  final String price; // Final price shown to user
  final String regularPrice;
  final String salePrice;
  final String sku;
  final int stockQuantity;
  final String stockStatus;
  final List<String> categories;
  final String imageUrl;

  Product({
    required this.id,
    required this.name,
    required this.modelName,
    required this.description,
    required this.price,
    required this.regularPrice,
    required this.salePrice,
    required this.sku,
    required this.stockQuantity,
    required this.stockStatus,
    required this.categories,
    required this.imageUrl,
  });

  bool get onSale => salePrice.isNotEmpty && salePrice != regularPrice;

  String get discountPercentage {
    if (!onSale) return "";
    double reg = double.tryParse(regularPrice) ?? 0;
    double sale = double.tryParse(salePrice) ?? 0;
    if (reg <= 0 || sale <= 0) return "";
    int percent = (((reg - sale) / reg) * 100).round();
    return "-$percent%";
  }

  factory Product.fromJson(Map<String, dynamic> json) {
    var cats = (json['categories'] as List? ?? [])
        .map((c) => c['name']?.toString() ?? '')
        .toList()
        .cast<String>();

    // Try to find "Model" attribute
    String model = "";
    var attrs = json['attributes'] as List? ?? [];
    for (var attr in attrs) {
      if (attr['name']?.toString().toLowerCase() == 'model') {
        var options = attr['options'] as List? ?? [];
        if (options.isNotEmpty) {
          model = options.first.toString();
        }
      }
    }

    return Product(
      id: json['id'] ?? 0,
      name: json['name']?.toString() ?? 'No Name',
      modelName: model,
      description: json['description']?.toString() ?? '',
      price: json['price']?.toString() ?? '0.00',
      regularPrice: json['regular_price']?.toString() ?? '',
      salePrice: json['sale_price']?.toString() ?? '',
      sku: json['sku']?.toString() ?? '',
      stockQuantity: json['stock_quantity'] ?? 0,
      stockStatus: json['stock_status']?.toString() ?? 'instock',
      categories: cats,
      imageUrl: (json['images'] != null && (json['images'] as List).isNotEmpty) 
          ? json['images'][0]['src']?.toString() ?? 'https://via.placeholder.com/150'
          : 'https://via.placeholder.com/150',
    );
  }
}
