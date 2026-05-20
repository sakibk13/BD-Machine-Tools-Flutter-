import 'package:flutter/material.dart';
import '../services/feedback_service.dart';

class SiteSettingsScreen extends StatefulWidget {
  const SiteSettingsScreen({super.key});

  @override
  State<SiteSettingsScreen> createState() => _SiteSettingsScreenState();
}

class _SiteSettingsScreenState extends State<SiteSettingsScreen> {
  final _footerController = TextEditingController(text: "© 2026 BD Machine Tools. All rights reserved.");
  final _addressController = TextEditingController(text: "123 Machine Plaza, Dhaka, Bangladesh");
  final _phoneController = TextEditingController(text: "+880 1234 567890");
  final _emailController = TextEditingController(text: "info@bdmachinetools.com");
  bool _isLoading = false;

  void _saveSettings() async {
    setState(() => _isLoading = true);
    // In a real scenario, this would call ApiService to update site options or a specific page.
    // For now, we simulate the success.
    await Future.delayed(const Duration(seconds: 1));
    setState(() => _isLoading = false);
    
    if (!mounted) return;
    FeedbackService.show(context, "Website footer and contact info updated!");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F7F7),
      appBar: AppBar(
        title: const Text("Website Management"),
      ),
      body: _isLoading 
        ? const Center(child: CircularProgressIndicator(color: Color(0xFF073334)))
        : SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Configure global information shown on your website footer and contact pages.",
                  style: TextStyle(color: Colors.grey, fontSize: 14),
                ),
                const SizedBox(height: 32),
                _buildSectionTitle("Footer Information"),
                _buildTextField(_footerController, "Copyright Text", Icons.copyright_rounded, maxLines: 2),
                const SizedBox(height: 32),
                _buildSectionTitle("Contact Details"),
                _buildTextField(_addressController, "Physical Address", Icons.location_on_rounded),
                const SizedBox(height: 16),
                _buildTextField(_phoneController, "Support Hotline", Icons.phone_android_rounded),
                const SizedBox(height: 16),
                _buildTextField(_emailController, "Business Email", Icons.email_rounded),
                const SizedBox(height: 48),
                SizedBox(
                  width: double.infinity,
                  height: 60,
                  child: ElevatedButton(
                    onPressed: _saveSettings,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF073334),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                      elevation: 8,
                    ),
                    child: const Text("UPDATE WEBSITE INFO", style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 1)),
                  ),
                ),
              ],
            ),
          ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16, left: 4),
      child: Text(title, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w900, color: Color(0xFF073334), letterSpacing: 1.2)),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label, IconData icon, {int maxLines = 1}) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: const Color(0xFF073334), size: 20),
        filled: true,
        fillColor: Colors.white,
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(20), borderSide: BorderSide(color: Colors.grey[200]!)),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(20), borderSide: const BorderSide(color: Color(0xFF073334), width: 1.5)),
      ),
    );
  }
}
