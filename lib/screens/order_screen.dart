import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../services/feedback_service.dart';
import '../models/order.dart';

class OrderScreen extends StatefulWidget {
  const OrderScreen({super.key});

  @override
  State<OrderScreen> createState() => _OrderScreenState();
}

class _OrderScreenState extends State<OrderScreen> {
  late Future<List<Order>> futureOrders;

  @override
  void initState() {
    super.initState();
    _refreshOrders();
  }

  void _refreshOrders() {
    setState(() {
      futureOrders = ApiService().getOrders();
    });
  }

  Future<void> _updateStatus(int orderId, String newStatus) async {
    setState(() {}); // Trigger rebuild for loading indicator

    final success = await ApiService().updateOrderStatus(orderId, newStatus);
    
    if (!mounted) return;

    if (success) {
      FeedbackService.show(context, "Order #$orderId updated to ${newStatus.toUpperCase()} successfully.");
      _refreshOrders();
    } else {
      FeedbackService.show(context, "Failed to update order status.", isError: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F7F7),
      body: FutureBuilder<List<Order>>(
        future: futureOrders,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: Color(0xFF073334)));
          } else if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.assignment_turned_in_rounded, size: 64, color: Colors.grey),
                  SizedBox(height: 16),
                  Text("No orders to display", style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold)),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(24),
            itemCount: snapshot.data!.length,
            itemBuilder: (context, index) {
              final order = snapshot.data![index];
              Color statusColor = order.status == 'completed' ? Colors.green : (order.status == 'cancelled' ? Colors.red : Colors.orange);
              
              return Container(
                margin: const EdgeInsets.only(bottom: 20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(30),
                  boxShadow: [
                    BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 20, offset: const Offset(0, 10)),
                  ],
                ),
                child: Theme(
                  data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
                  child: ExpansionTile(
                    tilePadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    title: Text(
                      "Order #${order.id}",
                      style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 17, color: Color(0xFF073334)),
                    ),
                    subtitle: Padding(
                      padding: const EdgeInsets.only(top: 6.0),
                      child: Text(order.customerName, style: TextStyle(color: Colors.grey[600], fontWeight: FontWeight.w600, fontSize: 13)),
                    ),
                    trailing: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          "৳${order.total}",
                          style: const TextStyle(color: Color(0xFF073334), fontWeight: FontWeight.w900, fontSize: 18, letterSpacing: -0.5),
                        ),
                        const SizedBox(height: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: statusColor.withOpacity(0.12),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            order.status.toUpperCase(),
                            style: TextStyle(color: statusColor, fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 0.5),
                          ),
                        ),
                      ],
                    ),
                    children: [
                      const Divider(height: 1, indent: 24, endIndent: 24, color: Color(0xFFF0F4F4)),
                      ...order.items.map((item) => ListTile(
                        contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 4),
                        dense: true,
                        title: Text(item.name, style: const TextStyle(fontWeight: FontWeight.w700, color: Color(0xFF073334))),
                        subtitle: Text("Quantity: ${item.quantity}", style: const TextStyle(fontWeight: FontWeight.w600)),
                        trailing: Text("৳${item.total}", style: const TextStyle(fontWeight: FontWeight.w900, color: Color(0xFF073334))),
                      )).toList(),
                      const SizedBox(height: 16),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF8F9FA),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text("Update Status", style: TextStyle(fontWeight: FontWeight.w800, color: Colors.grey, fontSize: 13)),
                              DropdownButton<String>(
                                value: order.status,
                                underline: Container(),
                                icon: const Icon(Icons.keyboard_arrow_down_rounded, color: Color(0xFF073334)),
                                style: const TextStyle(color: Color(0xFF073334), fontWeight: FontWeight.w900, fontSize: 14),
                                items: const [
                                  DropdownMenuItem(value: "pending", child: Text("Pending")),
                                  DropdownMenuItem(value: "processing", child: Text("Processing")),
                                  DropdownMenuItem(value: "completed", child: Text("Completed")),
                                  DropdownMenuItem(value: "cancelled", child: Text("Cancelled")),
                                ],
                                onChanged: (newStatus) {
                                  if (newStatus != null && newStatus != order.status) {
                                    _updateStatus(order.id, newStatus);
                                  }
                                },
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
