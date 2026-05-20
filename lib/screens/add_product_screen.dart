import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../services/api_service.dart';
import '../services/feedback_service.dart';
import 'scanner_screen.dart';

class AddProductScreen extends StatefulWidget {
  const AddProductScreen({super.key});

  @override
  State<AddProductScreen> createState() => _AddProductScreenState();
}

class _AddProductScreenState extends State<AddProductScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _modelController = TextEditingController();
  final _regularPriceController = TextEditingController();
  final _salePriceController = TextEditingController();
  final _skuController = TextEditingController();
  final _stockController = TextEditingController();
  final _descriptionController = TextEditingController();
  
  List<Map<String, dynamic>> _categories = [];
  int? _selectedCategoryId;
  bool _isLoading = false;
  File? _imageFile;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _loadCategories();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _modelController.dispose();
    _regularPriceController.dispose();
    _salePriceController.dispose();
    _skuController.dispose();
    _stockController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _loadCategories() async {
    final cats = await ApiService().getCategories();
    setState(() {
      _categories = cats;
    });
  }

  Future<void> _pickImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        _imageFile = File(image.path);
      });
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    String? imageUrl;
    if (_imageFile != null) {
      imageUrl = await ApiService().uploadImage(_imageFile!);
    }

    final productData = {
      "name": _nameController.text,
      "type": "simple",
      "regular_price": _regularPriceController.text,
      "sale_price": _salePriceController.text,
      "sku": _skuController.text,
      "manage_stock": true,
      "stock_quantity": int.tryParse(_stockController.text) ?? 0,
      "description": _descriptionController.text,
      "categories": _selectedCategoryId != null ? [{"id": _selectedCategoryId}] : [],
      "images": imageUrl != null ? [{"src": imageUrl}] : [],
      "attributes": [
        {
          "name": "Model",
          "visible": true,
          "variation": false,
          "options": [_modelController.text]
        }
      ]
    };

    final success = await ApiService().createProduct(productData);

    setState(() => _isLoading = false);

    if (!mounted) return;

    if (success) {
      FeedbackService.show(context, "Machine successfully uploaded to website!");
      Navigator.pop(context, true);
    } else {
      FeedbackService.show(context, "Could not upload machine. Check your connection.", isError: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F7F7),
      appBar: AppBar(
        title: const Text("New Machine Entry"),
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
                  GestureDetector(
                    onTap: _pickImage,
                    child: Container(
                      height: 200,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(30),
                        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 20)],
                      ),
                      child: _imageFile != null
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(30),
                              child: Image.file(_imageFile!, fit: BoxFit.cover),
                            )
                          : Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(color: const Color(0xFF073334).withOpacity(0.05), shape: BoxShape.circle),
                                  child: const Icon(Icons.add_a_photo_rounded, size: 40, color: Color(0xFF073334)),
                                ),
                                const SizedBox(height: 12),
                                const Text("ADD MACHINE PHOTO", style: TextStyle(color: Color(0xFF073334), fontWeight: FontWeight.w900, fontSize: 12, letterSpacing: 1)),
                              ],
                            ),
                    ),
                  ),
                  const SizedBox(height: 32),
                  _buildSectionTitle("General Details"),
                  _buildTextField(_nameController, "Model or Machine Name", Icons.settings_suggest_rounded),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(child: _buildTextField(_skuController, "SKU or Model Number", Icons.qr_code_rounded)),
                      const SizedBox(width: 12),

                      Container(
                        height: 56,
                        width: 56,
                        decoration: BoxDecoration(
                          color: const Color(0xFF073334).withOpacity(0.08),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: IconButton(
                          icon: const Icon(Icons.qr_code_scanner_rounded, color: Color(0xFF073334)),
                          onPressed: () async {
                            final code = await Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => const ScannerScreen()),
                            );
                            if (code != null) {
                              setState(() => _skuController.text = code);
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),
                  _buildSectionTitle("Pricing (৳)"),
                  Row(
                    children: [
                      Expanded(child: _buildTextField(_regularPriceController, "Regular Price", Icons.payments_rounded, isNumber: true)),
                      const SizedBox(width: 16),
                      Expanded(child: _buildTextField(_salePriceController, "Offer Price", Icons.local_offer_rounded, isNumber: true)),
                    ],
                  ),
                  const SizedBox(height: 32),
                  _buildSectionTitle("Inventory"),
                  Row(
                    children: [
                      Expanded(child: _buildTextField(_stockController, "Stock Quantity", Icons.inventory_2_rounded, isNumber: true)),
                      const SizedBox(width: 16),
                      Expanded(
                        child: DropdownButtonFormField<int>(
                          value: _selectedCategoryId,
                          decoration: _buildInputDecoration("Category", Icons.category_rounded),
                          items: _categories.map((cat) {
                            bool isSub = cat['parent'] != 0;
                            return DropdownMenuItem<int>(
                              value: cat['id'],
                              child: Text(isSub ? "  -- ${cat['name']}" : cat['name'], overflow: TextOverflow.ellipsis),
                            );
                          }).toList(),
                          onChanged: (v) => setState(() => _selectedCategoryId = v),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),
                  _buildSectionTitle("Technical Description"),
                  _buildTextField(_descriptionController, "Full machine specifications...", Icons.description_rounded, maxLines: 5),
                  const SizedBox(height: 48),
                  SizedBox(
                    width: double.infinity,
                    height: 60,
                    child: ElevatedButton(
                      onPressed: _submit,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF073334),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                        elevation: 10,
                        shadowColor: const Color(0xFF073334).withOpacity(0.4),
                      ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.publish_rounded),
                          SizedBox(width: 12),
                          Text("UPLOAD TO WEBSITE", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900, letterSpacing: 1.5)),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 40),
                ],
              ),
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

  Widget _buildTextField(TextEditingController controller, String label, IconData icon, {bool isNumber = false, int maxLines = 1}) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      keyboardType: isNumber ? TextInputType.number : TextInputType.text,
      decoration: _buildInputDecoration(label, icon),
      validator: (v) => (label.contains("Offer") || label.contains("Model") || v!.isNotEmpty) ? null : "Required",
    );
  }

  InputDecoration _buildInputDecoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon, color: const Color(0xFF073334), size: 20),
      filled: true,
      fillColor: Colors.white,
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(20), borderSide: BorderSide(color: Colors.grey[200]!)),
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(20), borderSide: const BorderSide(color: Color(0xFF073334), width: 1.5)),
    );
  }
}
