import 'package:flutter/material.dart';
import 'dashboard_screen.dart';
import 'product_list_screen.dart';
import 'order_screen.dart';
import 'customer_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  String _getTitle() {
    switch (_selectedIndex) {
      case 0: return "Dashboard";
      case 1: return "Inventory";
      case 2: return "Orders";
      case 3: return "Customers";
      default: return "Dashboard";
    }
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> screens = [
      DashboardScreen(onTabChange: (index) => setState(() => _selectedIndex = index)),
      const ProductListScreen(),
      const OrderScreen(),
      const CustomerScreen(),
    ];

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 4)],
              ),
              child: ClipOval(
                child: Image.asset('assets/logo.jpeg', height: 48, width: 48, fit: BoxFit.cover),
              ),
            ),
            const SizedBox(width: 12),
            Text(_getTitle(), style: const TextStyle(fontWeight: FontWeight.w900, letterSpacing: 0.5)),
          ],
        ),
      ),
      body: screens[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: const Color(0xFF073334),
        unselectedItemColor: Colors.grey,
        onTap: (index) => setState(() => _selectedIndex = index),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.dashboard), label: "Dash"),
          BottomNavigationBarItem(icon: Icon(Icons.inventory), label: "Stock"),
          BottomNavigationBarItem(icon: Icon(Icons.shopping_cart), label: "Orders"),
          BottomNavigationBarItem(icon: Icon(Icons.people), label: "Users"),
        ],
      ),
    );
  }
}
