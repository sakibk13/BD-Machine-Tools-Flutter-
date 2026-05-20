class Order {
  final int id;
  final String status;
  final String total;
  final String dateCreated;
  final String customerName;
  final List<OrderItem> items;

  Order({
    required this.id,
    required this.status,
    required this.total,
    required this.dateCreated,
    required this.customerName,
    required this.items,
  });

  factory Order.fromJson(Map<String, dynamic> json) {
    var list = json['line_items'] as List? ?? [];
    List<OrderItem> itemsList = list.map((i) => OrderItem.fromJson(i)).toList();

    String firstName = json['billing']?['first_name']?.toString() ?? '';
    String lastName = json['billing']?['last_name']?.toString() ?? '';

    return Order(
      id: json['id'] ?? 0,
      status: json['status']?.toString() ?? 'pending',
      total: json['total']?.toString() ?? '0.00',
      dateCreated: json['date_created']?.toString() ?? '',
      customerName: firstName.isEmpty && lastName.isEmpty ? "Guest" : "$firstName $lastName",
      items: itemsList,
    );
  }
}

class OrderItem {
  final String name;
  final int quantity;
  final String total;

  OrderItem({required this.name, required this.quantity, required this.total});

  factory OrderItem.fromJson(Map<String, dynamic> json) {
    return OrderItem(
      name: json['name']?.toString() ?? 'Unknown Item',
      quantity: json['quantity'] ?? 0,
      total: json['total']?.toString() ?? '0.00',
    );
  }
}
