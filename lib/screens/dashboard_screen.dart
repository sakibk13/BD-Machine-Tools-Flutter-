import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import '../services/api_service.dart';
import 'add_product_screen.dart';
import 'add_category_screen.dart';
import 'site_settings_screen.dart';
import 'login_screen.dart';

class DashboardScreen extends StatefulWidget {
  final Function(int) onTabChange;
  const DashboardScreen({super.key, required this.onTabChange});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 800));
    _fadeAnimation = CurvedAnimation(parent: _controller, curve: Curves.easeIn);
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('isLoggedIn');
    if (!mounted) return;
    Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const LoginScreen()));
  }

  Future<void> _launchWebsite() async {
    final Uri url = Uri.parse('https://bdmachinetools.com');
    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      throw Exception('Could not launch $url');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F7F7),
      body: FutureBuilder<Map<String, dynamic>>(
        future: ApiService().getReport(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: Color(0xFF073334)));
          }

          final data = snapshot.data ?? {};
          return FadeTransition(
            opacity: _fadeAnimation,
            child: CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                SliverToBoxAdapter(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 48),
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Color(0xFF073334), Color(0xFF0A4D4F)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(50),
                        bottomRight: Radius.circular(50),
                      ),
                      boxShadow: [
                        BoxShadow(color: Colors.black26, blurRadius: 25, offset: Offset(0, 15))
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Command Center",
                                  style: TextStyle(color: Colors.white, fontSize: 30, fontWeight: FontWeight.w900, letterSpacing: -1),
                                ),
                                Text(
                                  "Live Business Overview",
                                  style: TextStyle(color: Colors.white60, fontSize: 13, fontWeight: FontWeight.w500),
                                ),
                              ],
                            ),
                            Row(
                              children: [
                                Container(
                                  decoration: BoxDecoration(color: Colors.white12, borderRadius: BorderRadius.circular(15)),
                                  child: IconButton(
                                    icon: const Icon(Icons.language_rounded, color: Colors.white, size: 24),
                                    onPressed: _launchWebsite,
                                    tooltip: "Visit Website",
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Container(
                                  decoration: BoxDecoration(color: Colors.white12, borderRadius: BorderRadius.circular(15)),
                                  child: IconButton(
                                    icon: const Icon(Icons.power_settings_new_rounded, color: Colors.white, size: 24),
                                    onPressed: _logout,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 40),
                        Container(
                          padding: const EdgeInsets.all(28),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.08),
                            borderRadius: BorderRadius.circular(35),
                            border: Border.all(color: Colors.white.withOpacity(0.1)),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text("Total Revenue", style: TextStyle(color: Colors.white70, fontSize: 14, fontWeight: FontWeight.w600)),
                                  const SizedBox(height: 10),
                                  Row(
                                    crossAxisAlignment: CrossAxisAlignment.baseline,
                                    textBaseline: TextBaseline.alphabetic,
                                    children: [
                                      const Text("৳", style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
                                      const SizedBox(width: 8),
                                      Text(
                                        data['total_sales'] ?? '0.00',
                                        style: const TextStyle(color: Colors.white, fontSize: 40, fontWeight: FontWeight.w900, letterSpacing: -1.5),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              Container(
                                padding: const EdgeInsets.all(20),
                                decoration: const BoxDecoration(
                                  color: Colors.white,
                                  shape: BoxShape.circle,
                                  boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 15, offset: Offset(0, 8))]
                                ),
                                child: const Icon(Icons.insights_rounded, color: Color(0xFF073334), size: 30),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
                  sliver: SliverToBoxAdapter(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            _buildMiniStat("New Orders", "${data['total_orders'] ?? 0}", Icons.shopping_basket_rounded, Colors.orange),
                            const SizedBox(width: 20),
                            _buildMiniStat("Active Items", "${data['total_items'] ?? 0}", Icons.precision_manufacturing_rounded, Colors.teal),
                          ],
                        ),
                        const SizedBox(height: 50),
                        const Text(
                          "Operations Hub", 
                          style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: Color(0xFF073334), letterSpacing: -0.5)
                        ),
                        const SizedBox(height: 20),
                        _buildActionTile(context, Icons.add_circle_outline_rounded, "Add New Machine", "Instantly upload to your website", () async {
                           await Navigator.push(context, MaterialPageRoute(builder: (context) => const AddProductScreen()));
                        }),
                        _buildActionTile(context, Icons.account_tree_rounded, "Category Manager", "Organize machines and parts", () async {
                           await Navigator.push(context, MaterialPageRoute(builder: (context) => const AddCategoryScreen()));
                        }),
                        _buildActionTile(context, Icons.public_rounded, "Website Info", "Edit footer, contact and global details", () async {
                           await Navigator.push(context, MaterialPageRoute(builder: (context) => const SiteSettingsScreen()));
                        }),
                        _buildActionTile(context, Icons.badge_rounded, "Client Database", "Manage your registered customers", () {
                           widget.onTabChange(3);
                        }),
                        const SizedBox(height: 50),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildMiniStat(String title, String value, IconData icon, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(28),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(35),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 30, offset: const Offset(0, 15))
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: color.withOpacity(0.12), borderRadius: BorderRadius.circular(15)),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(height: 20),
            Text(value, style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w900, color: Color(0xFF073334))),
            Text(title, style: TextStyle(color: Colors.grey[500], fontSize: 13, fontWeight: FontWeight.w700, letterSpacing: 0.5)),
          ],
        ),
      ),
    );
  }

  Widget _buildActionTile(BuildContext context, IconData icon, String title, String subtitle, VoidCallback onTap) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 20, offset: const Offset(0, 10))
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: ListTile(
          onTap: onTap,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
          contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          leading: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF073334).withOpacity(0.06), 
              borderRadius: BorderRadius.circular(20)
            ),
            child: Icon(icon, color: const Color(0xFF073334), size: 26),
          ),
          title: Text(title, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 17, color: Color(0xFF073334))),
          subtitle: Text(subtitle, style: TextStyle(color: Colors.grey[500], fontSize: 13, fontWeight: FontWeight.w500)),
          trailing: Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: Colors.grey[50], shape: BoxShape.circle),
            child: const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: Color(0xFF073334)),
          ),
        ),
      ),
    );
  }
}
