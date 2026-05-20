import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../services/feedback_service.dart';

class AddCategoryScreen extends StatefulWidget {
  const AddCategoryScreen({super.key});

  @override
  State<AddCategoryScreen> createState() => _AddCategoryScreenState();
}

class _AddCategoryScreenState extends State<AddCategoryScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  
  List<Map<String, dynamic>> _categories = [];
  int? _parentCategoryId;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadCategories();
  }

  Future<void> _loadCategories() async {
    final cats = await ApiService().getCategories();
    setState(() {
      // Filter only top level categories for parents to keep it simple, 
      // or show all for sub-sub categories.
      _categories = cats;
    });
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final categoryData = {
      "name": _nameController.text,
      "description": _descriptionController.text,
      "parent": _parentCategoryId ?? 0,
    };

    final result = await ApiService().createCategory(categoryData);

    setState(() => _isLoading = false);

    if (!mounted) return;

    if (result['success']) {
      FeedbackService.show(context, result['message']);
      Navigator.pop(context, true);
    } else {
      FeedbackService.show(context, result['message'], isError: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F7F7),
      appBar: AppBar(
        title: const Text("New Category"),
        elevation: 0,
      ),
      body: _isLoading 
        ? const Center(child: CircularProgressIndicator(color: Color(0xFF073334)))
        : SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Create a new classification for your machines.",
                    style: TextStyle(color: Colors.grey, fontSize: 14),
                  ),
                  const SizedBox(height: 32),
                  _buildTextField(_nameController, "Category Name", Icons.category_rounded),
                  const SizedBox(height: 24),
                  DropdownButtonFormField<int>(
                    value: _parentCategoryId,
                    decoration: _buildInputDecoration("Parent Category (Optional)", Icons.account_tree_rounded),
                    items: [
                      const DropdownMenuItem<int>(
                        value: null,
                        child: Text("None (Top Level)"),
                      ),
                      ..._categories.map((cat) {
                        return DropdownMenuItem<int>(
                          value: cat['id'],
                          child: Text(cat['name']),
                        );
                      }),
                    ],
                    onChanged: (v) => setState(() => _parentCategoryId = v),
                  ),
                  const SizedBox(height: 24),
                  _buildTextField(_descriptionController, "Description (Optional)", Icons.description_rounded, maxLines: 3),
                  const SizedBox(height: 48),
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: _submit,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF073334),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        elevation: 4,
                      ),
                      child: const Text(
                        "SAVE CATEGORY",
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, letterSpacing: 1),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label, IconData icon, {int maxLines = 1}) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      decoration: _buildInputDecoration(label, icon),
      validator: (v) => (label.contains("Optional") || v!.isNotEmpty) ? null : "Required",
    );
  }

  InputDecoration _buildInputDecoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon, color: const Color(0xFF073334), size: 20),
      filled: true,
      fillColor: Colors.white,
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide(color: Colors.grey[200]!)),
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: Color(0xFF073334), width: 1.5)),
    );
  }
}
