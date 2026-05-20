class Customer {
  final int id;
  final String email;
  final String firstName;
  final String lastName;
  final String role;
  final int ordersCount;
  final String totalSpent;

  Customer({
    required this.id,
    required this.email,
    required this.firstName,
    required this.lastName,
    required this.role,
    required this.ordersCount,
    required this.totalSpent,
  });

  factory Customer.fromJson(Map<String, dynamic> json) {
    return Customer(
      id: json['id'] ?? 0,
      email: json['email']?.toString() ?? '',
      firstName: json['first_name']?.toString() ?? '',
      lastName: json['last_name']?.toString() ?? '',
      role: json['role']?.toString() ?? '',
      ordersCount: json['orders_count'] ?? 0,
      totalSpent: json['total_spent']?.toString() ?? '0.00',
    );
  }
}
