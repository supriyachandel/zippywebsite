import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../utils/app_colors.dart';
import '../services/store_api_service.dart';

class ProductEditScreen extends StatefulWidget {
  final Map<String, dynamic>? product;

  const ProductEditScreen({super.key, this.product});

  @override
  State<ProductEditScreen> createState() => _ProductEditScreenState();
}

class _ProductEditScreenState extends State<ProductEditScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  final List<File> _imageFiles = [];
  final _picker = ImagePicker();

  late TextEditingController _nameController;
  late TextEditingController _priceController;
  late TextEditingController _discountPriceController;
  late TextEditingController _quantityController;
  late TextEditingController _skuController;
  late TextEditingController _barcodeController;
  late TextEditingController _weightController;
  late TextEditingController _sizeController;
  late TextEditingController _materialController;
  late TextEditingController _colorController;
  late TextEditingController _descriptionController;
  late TextEditingController _videoController;
  List<Map<String, dynamic>> _categories = [];
  List<int> _subCategoryIds = [];
  int? _selectedCategoryId;
  int? _selectedSubCategoryId;
  String _selectedGender = 'unisex';

  bool get _isEditing => widget.product != null;

  @override
  void initState() {
    super.initState();
    final p = widget.product;
    _nameController = TextEditingController(text: _str(p?['name']));
    _priceController = TextEditingController(text: _str(p?['price']));
    _discountPriceController = TextEditingController(text: _str(p?['discount_price']));
    _quantityController = TextEditingController(text: _str(p?['quantity']));
    _skuController = TextEditingController(text: _str(p?['sku']));
    _barcodeController = TextEditingController(text: _str(p?['barcode']));
    _weightController = TextEditingController(text: _str(p?['weight']));
    _sizeController = TextEditingController(text: _str(p?['size']));
    _materialController = TextEditingController(text: _str(p?['material']));
    _colorController = TextEditingController(text: _str(p?['color']));
    _descriptionController = TextEditingController(text: _str(p?['description']));
    _videoController = TextEditingController(text: _str(p?['video']));
    _selectedGender = _str(p?['gender']).isNotEmpty ? _str(p?['gender']) : 'unisex';
    _selectedCategoryId = p?['category_id'] is int ? p!['category_id'] as int : int.tryParse(_str(p?['category_id']));
    _selectedSubCategoryId = p?['sub_category_id'] is int ? p!['sub_category_id'] as int : int.tryParse(_str(p?['sub_category_id']));
    _loadCategories();
  }

  String _str(dynamic v) => v?.toString() ?? '';

  @override
  void dispose() {
    _nameController.dispose();
    _priceController.dispose();
    _discountPriceController.dispose();
    _quantityController.dispose();
    _skuController.dispose();
    _barcodeController.dispose();
    _weightController.dispose();
    _sizeController.dispose();
    _materialController.dispose();
    _colorController.dispose();
    _descriptionController.dispose();
    _videoController.dispose();
    super.dispose();
  }

  Future<void> _loadCategories() async {
    try {
      final cats = await StoreApiService.getCategories();
      final subIds = await StoreApiService.getAvailableSubCategoryIds();
      if (mounted) {
        setState(() {
          _categories = cats.cast<Map<String, dynamic>>();
          _subCategoryIds = subIds;
        });
      }
    } catch (_) {}
  }

  void _pickImages() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(2))),
              const SizedBox(height: 16),
              const Text("Add Images", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              const SizedBox(height: 16),
              ListTile(
                leading: const Icon(Icons.camera_alt_outlined),
                title: const Text("Take Photo"),
                onTap: () async {
                  Navigator.pop(ctx);
                  final picked = await _picker.pickImage(source: ImageSource.camera, imageQuality: 85);
                  if (picked != null) setState(() => _imageFiles.add(File(picked.path)));
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_outlined),
                title: const Text("Choose from Gallery"),
                onTap: () async {
                  Navigator.pop(ctx);
                  final picked = await _picker.pickImage(source: ImageSource.gallery, imageQuality: 85);
                  if (picked != null) setState(() => _imageFiles.add(File(picked.path)));
                },
              ),
              ListTile(
                leading: const Icon(Icons.collections_outlined),
                title: const Text("Choose Multiple"),
                onTap: () async {
                  Navigator.pop(ctx);
                  final picked = await _picker.pickMultiImage(imageQuality: 85);
                  if (picked.isNotEmpty) {
                    setState(() => _imageFiles.addAll(picked.map((x) => File(x.path))));
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _saveProduct() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedCategoryId == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Please select a category"), behavior: SnackBarBehavior.floating));
      return;
    }
    if (_selectedSubCategoryId == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Please select a sub-category"), behavior: SnackBarBehavior.floating));
      return;
    }

    setState(() => _isLoading = true);
    try {
      final data = <String, dynamic>{
        'name': _nameController.text,
        'price': double.tryParse(_priceController.text) ?? 0,
        'discount_price': double.tryParse(_discountPriceController.text) ?? 0,
        'quantity': int.tryParse(_quantityController.text) ?? 0,
        'sku': _skuController.text,
        'barcode': _barcodeController.text,
        'weight': _weightController.text,
        'size': _sizeController.text,
        'material': _materialController.text,
        'color': _colorController.text,
        'description': _descriptionController.text,
        'video': _videoController.text,
        'category_id': _selectedCategoryId ?? 1,
        'sub_category_id': _selectedSubCategoryId ?? 1,
        'shop_id': StoreApiService.shopId ?? 1,
        'status': 'active',
        'gender': _selectedGender,
      };

      if (_isEditing) {
        await StoreApiService.updateProduct(widget.product!['id'], productData: data, imageFiles: _imageFiles);
      } else {
        await StoreApiService.createProduct(productData: data, imageFiles: _imageFiles);
      }

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_isEditing ? "Product updated!" : "Product created!"),
          behavior: SnackBarBehavior.floating,
        ),
      );
      Navigator.pop(context, true);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString().replaceAll('Exception: ', '')),
            backgroundColor: Colors.red.shade700,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.offWhite,
      appBar: AppBar(
        title: Text(_isEditing ? "EDIT PRODUCT" : "ADD PRODUCT"),
        actions: [
          TextButton(
            onPressed: _isLoading ? null : _saveProduct,
            child: _isLoading
                ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                : Text(_isEditing ? "UPDATE" : "SAVE", style: const TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSectionHeader("PRODUCT IMAGES"),
              const SizedBox(height: 12),
              _buildImagePicker(),
              if (_imageFiles.isNotEmpty) ...[
                const SizedBox(height: 16),
                _buildImageGallery(),
              ],

              const SizedBox(height: 24),
              _buildSectionHeader("BASIC INFO"),
              const SizedBox(height: 12),
              _buildFieldLabel("PRODUCT NAME *"),
              _buildTextField(_nameController, "Enter product name"),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(child: _buildFieldLabel("PRICE *")),
                  const SizedBox(width: 16),
                  Expanded(child: _buildFieldLabel("DISCOUNT PRICE")),
                ],
              ),
              Row(
                children: [
                  Expanded(child: _buildTextField(_priceController, "0", isNumber: true)),
                  const SizedBox(width: 16),
                  Expanded(child: _buildTextField(_discountPriceController, "0", isNumber: true)),
                ],
              ),
              const SizedBox(height: 16),
              _buildFieldLabel("QUANTITY *"),
              _buildTextField(_quantityController, "Enter stock quantity", isNumber: true),

              const SizedBox(height: 24),
              _buildSectionHeader("GENDER"),
              const SizedBox(height: 12),
              Row(
                children: ['male', 'female', 'unisex'].map((g) => Padding(
                  padding: const EdgeInsets.only(right: 10),
                  child: ChoiceChip(
                    label: Text(g[0].toUpperCase() + g.substring(1)),
                    selected: _selectedGender == g,
                    onSelected: (_) => setState(() => _selectedGender = g),
                    selectedColor: AppColors.primaryDark,
                    labelStyle: TextStyle(color: _selectedGender == g ? Colors.white : AppColors.primaryDark, fontWeight: FontWeight.w600, fontSize: 13),
                  ),
                )).toList(),
              ),

              const SizedBox(height: 24),
              _buildSectionHeader("MEDIA"),
              const SizedBox(height: 12),
              _buildFieldLabel("VIDEO URL (Optional)"),
              _buildTextField(_videoController, "https://youtube.com/watch?v=..."),

              const SizedBox(height: 24),
              _buildSectionHeader("PRODUCT DETAILS"),
              const SizedBox(height: 12),
              _buildFieldLabel("DESCRIPTION"),
              _buildTextField(_descriptionController, "Enter product description", maxLines: 3),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(child: _buildFieldLabel("SKU")),
                  const SizedBox(width: 16),
                  Expanded(child: _buildFieldLabel("BARCODE")),
                ],
              ),
              Row(
                children: [
                  Expanded(child: _buildTextField(_skuController, "SKU-001")),
                  const SizedBox(width: 16),
                  Expanded(child: _buildTextField(_barcodeController, "123456789012")),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(child: _buildFieldLabel("WEIGHT")),
                  const SizedBox(width: 16),
                  Expanded(child: _buildFieldLabel("SIZE")),
                ],
              ),
              Row(
                children: [
                  Expanded(child: _buildTextField(_weightController, "e.g. 500g")),
                  const SizedBox(width: 16),
                  Expanded(child: _buildTextField(_sizeController, "e.g. S,M,L,XL")),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(child: _buildFieldLabel("MATERIAL")),
                  const SizedBox(width: 16),
                  Expanded(child: _buildFieldLabel("COLOR")),
                ],
              ),
              Row(
                children: [
                  Expanded(child: _buildTextField(_materialController, "e.g. Cotton")),
                  const SizedBox(width: 16),
                  Expanded(child: _buildTextField(_colorController, "e.g. Blue")),
                ],
              ),

              const SizedBox(height: 24),
              _buildSectionHeader("CATEGORY"),
              const SizedBox(height: 12),
              _buildDropdown(
                value: _selectedCategoryId,
                items: _categories
                    .map((c) => DropdownMenuItem(
                          value: int.tryParse(c['id']?.toString() ?? ''),
                          child: Text(c['category_name']?.toString() ?? ''),
                        ))
                    .toList(),
                hint: "Select Category",
                onChanged: (val) => setState(() => _selectedCategoryId = val),
              ),
              const SizedBox(height: 16),
              _buildDropdown(
                value: _selectedSubCategoryId,
                items: _subCategoryIds
                    .map((id) => DropdownMenuItem(value: id, child: Text("Type $id")))
                    .toList(),
                hint: "Select Sub-Category",
                onChanged: (val) => setState(() => _selectedSubCategoryId = val),
              ),

              const SizedBox(height: 40),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _saveProduct,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryDark,
                    foregroundColor: Colors.white,
                    minimumSize: const Size(double.infinity, 56),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    elevation: 0,
                  ),
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : Text(_isEditing ? "UPDATE PRODUCT" : "SAVE PRODUCT", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                ),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildImagePicker() {
    return GestureDetector(
      onTap: _pickImages,
      child: Container(
        height: 120,
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: _imageFiles.isNotEmpty ? AppColors.primaryDark : AppColors.softGrey,
            width: _imageFiles.isNotEmpty ? 2 : 1,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.add_a_photo_outlined, size: 36, color: Colors.grey.shade400),
            const SizedBox(height: 6),
            Text(
              _imageFiles.isEmpty ? "Tap to add images" : "Tap to add more",
              style: TextStyle(color: Colors.grey.shade400, fontSize: 13),
            ),
            if (_imageFiles.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 2),
                child: Text("${_imageFiles.length} selected", style: TextStyle(color: AppColors.primaryDark, fontSize: 11, fontWeight: FontWeight.w600)),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildImageGallery() {
    return SizedBox(
      height: 100,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: _imageFiles.length,
        separatorBuilder: (_, __) => const SizedBox(width: 10),
        itemBuilder: (context, index) {
          final file = _imageFiles[index];
          return Stack(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.file(file, width: 100, height: 100, fit: BoxFit.cover),
              ),
              Positioned(
                top: 4,
                right: 4,
                child: GestureDetector(
                  onTap: () => setState(() => _imageFiles.removeAt(index)),
                  child: Container(
                    padding: const EdgeInsets.all(2),
                    decoration: const BoxDecoration(
                      color: Colors.black54,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.close, size: 16, color: Colors.white),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(title, style: const TextStyle(
      fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.primaryDark, letterSpacing: 1.5,
    ));
  }

  Widget _buildFieldLabel(String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(label, style: TextStyle(
        color: AppColors.primaryDark.withValues(alpha: 0.5), fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1,
      )),
    );
  }

  Widget _buildDropdown({
    required dynamic value,
    required List<DropdownMenuItem> items,
    required String hint,
    required ValueChanged<dynamic> onChanged,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.softGrey),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: DropdownButtonHideUnderline(
        child: DropdownButton(
          value: value,
          isExpanded: true,
          hint: Text(hint, style: TextStyle(color: Colors.grey.shade400, fontSize: 14)),
          items: items,
          onChanged: onChanged,
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String hint, {bool isNumber = false, int maxLines = 1}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.softGrey),
      ),
      child: TextFormField(
        controller: controller,
        maxLines: maxLines,
        keyboardType: isNumber ? TextInputType.number : TextInputType.text,
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.all(16),
        ),
        validator: controller == _nameController || controller == _priceController || controller == _quantityController
            ? (value) {
                if (value == null || value.isEmpty) return "Required";
                return null;
              }
            : null,
      ),
    );
  }
}
