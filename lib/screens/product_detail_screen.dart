import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:share_plus/share_plus.dart';
import '../models/product.dart';
import '../services/api_service.dart';
import '../services/feedback_service.dart';

class ProductDetailScreen extends StatefulWidget {
  final Product product;
  const ProductDetailScreen({super.key, required this.product});

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _regularPriceController;
  late TextEditingController _salePriceController;
  late TextEditingController _skuController;
  late TextEditingController _stockController;
  late TextEditingController _descriptionController;
  late String _stockStatus;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.product.name);
    _regularPriceController = TextEditingController(text: widget.product.regularPrice);
    _salePriceController = TextEditingController(text: widget.product.salePrice);
    _skuController = TextEditingController(text: widget.product.sku);
    _stockController = TextEditingController(text: widget.product.stockQuantity.toString());
    _descriptionController = TextEditingController(text: widget.product.description);
    _stockStatus = widget.product.stockStatus;
  }

  Future<void> _update() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);
    
    final success = await ApiService().updateProduct(widget.product.id, {
      "name": _nameController.text,
      "regular_price": _regularPriceController.text,
      "sale_price": _salePriceController.text,
      "sku": _skuController.text,
      "manage_stock": true,
      "stock_quantity": int.tryParse(_stockController.text) ?? 0,
      "stock_status": _stockStatus,
      "description": _descriptionController.text,
    });

    setState(() => _isLoading = false);
    if (!mounted) return;

    if (success) {
      FeedbackService.show(context, "Website updated instantly! Changes are now live.");
      Navigator.pop(context, true);
    } else {
      FeedbackService.show(context, "Connection failed. Please check your internet.", isError: true);
    }
  }

  void _shareMachine() {
    final String text = "Check out this machine at BD Machine Tools:\n\n"
        "Name: ${widget.product.name}\n"
        "Code: ${widget.product.sku}\n"
        "Price: ৳${widget.product.price}\n\n"
        "Visit: https://bdmachinetools.com/?p=${widget.product.id}";
    Share.share(text);
  }

  Future<void> _delete() async {
    final confirm = await showGeneralDialog<bool>(
      context: context,
      barrierDismissible: true,
      barrierLabel: '',
      barrierColor: Colors.black54,
      transitionDuration: const Duration(milliseconds: 300),
      pageBuilder: (context, anim1, anim2) => Center(
        child: Container(
          margin: const EdgeInsets.all(32),
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(24)),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.warning_amber_rounded, color: Colors.red, size: 64),
              const SizedBox(height: 16),
              const Text("Permanently Delete?", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              const Text("This machine will be removed from your website forever.", textAlign: TextAlign.center, style: TextStyle(color: Colors.grey)),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(child: TextButton(onPressed: () => Navigator.pop(context, false), child: const Text("CANCEL"))),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(context, true),
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
                      child: const Text("DELETE"),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );

    if (confirm != true) return;

    setState(() => _isLoading = true);
    final success = await ApiService().deleteProduct(widget.product.id);
    setState(() => _isLoading = false);

    if (!mounted) return;

    if (success) {
      FeedbackService.show(context, "Product removed from website successfully.");
      Navigator.pop(context, true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F7F7),
      appBar: AppBar(
        title: const Text("Edit Machine"),
        actions: [
          IconButton(icon: const Icon(Icons.share_rounded, color: Colors.white), onPressed: _shareMachine),
          IconButton(icon: const Icon(Icons.delete_outline_rounded, color: Colors.white), onPressed: _delete),
        ],
      ),
      body: _isLoading 
        ? const Center(child: CircularProgressIndicator(color: Color(0xFF073334)))
        : SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    height: 220,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(30),
                      boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 25, offset: const Offset(0, 10))],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(30),
                      child: CachedNetworkImage(
                        imageUrl: widget.product.imageUrl,
                        fit: BoxFit.cover,
                        placeholder: (context, url) => Container(color: Colors.white),
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                  _buildSectionTitle("Identification"),
                  _buildTextField(_nameController, "Model or Machine Name", Icons.title_rounded),
                  const SizedBox(height: 16),
                  _buildTextField(_skuController, "SKU or Model Number", Icons.qr_code_scanner_rounded),
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
                  _buildSectionTitle("Inventory Control"),
                  Row(
                    children: [
                      Expanded(child: _buildTextField(_stockController, "Quantity", Icons.inventory_rounded, isNumber: true)),
                      const SizedBox(width: 16),
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          value: _stockStatus,
                          decoration: _buildInputDecoration("Status", Icons.analytics_rounded),
                          items: const [
                            DropdownMenuItem(value: "instock", child: Text("In Stock")),
                            DropdownMenuItem(value: "outofstock", child: Text("Out of Stock")),
                          ],
                          onChanged: (v) => setState(() => _stockStatus = v!),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),
                  _buildSectionTitle("Detailed Specifications"),
                  _buildTextField(_descriptionController, "Full machine details", Icons.description_rounded, maxLines: 5),
                  const SizedBox(height: 48),
                  SizedBox(
                    width: double.infinity,
                    height: 60,
                    child: ElevatedButton(
                      onPressed: _update,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF073334),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                        elevation: 10,
                        shadowColor: const Color(0xFF073334).withOpacity(0.4),
                      ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.check_circle_rounded),
                          SizedBox(width: 12),
                          Text("PUBLISH CHANGES", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900, letterSpacing: 1)),
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
