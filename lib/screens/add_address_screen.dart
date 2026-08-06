import 'package:flutter/material.dart';
import '../models/api_models.dart';
import '../services/api_service.dart';
import '../utils/app_colors.dart';

class AddAddressScreen extends StatefulWidget {
  final ApiAddress? address;

  const AddAddressScreen({super.key, this.address});

  @override
  State<AddAddressScreen> createState() => _AddAddressScreenState();
}

class _AddAddressScreenState extends State<AddAddressScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  late String _selectedLabel;
  late TextEditingController _nameController;
  late TextEditingController _phoneController;
  late TextEditingController _addressController;
  late TextEditingController _cityController;
  late TextEditingController _stateController;
  late TextEditingController _zipController;
  late TextEditingController _countryController;

  bool get _isEditing => widget.address != null;

  @override
  void initState() {
    super.initState();
    final a = widget.address;
    _selectedLabel = a?.label ?? 'Home';
    _nameController = TextEditingController(text: a?.name ?? '');
    _phoneController = TextEditingController(text: a?.phone ?? '');
    _addressController = TextEditingController(text: a?.address ?? '');
    _cityController = TextEditingController(text: a?.city ?? '');
    _stateController = TextEditingController(text: a?.state ?? '');
    _zipController = TextEditingController(text: a?.zip ?? '');
    _countryController = TextEditingController(text: a?.country ?? 'India');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _cityController.dispose();
    _stateController.dispose();
    _zipController.dispose();
    _countryController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);
    try {
      final data = <String, dynamic>{
        'label': _selectedLabel,
        'name': _nameController.text,
        'phone': _phoneController.text,
        'address': _addressController.text,
        'city': _cityController.text,
        'state': _stateController.text,
        'zip': _zipController.text,
        'country': _countryController.text,
        'is_default': widget.address?.isDefault ?? false,
      };
      if (_isEditing) {
        await ApiService.updateAddress(widget.address!.id, data);
      } else {
        await ApiService.createAddress(data);
      }
      if (mounted) Navigator.pop(context, true);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString().replaceAll('Exception: ', '')), backgroundColor: Colors.red.shade700),
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
      appBar: AppBar(title: Text(_isEditing ? "EDIT ADDRESS" : "ADD ADDRESS")),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("SAVE AS", style: TextStyle(color: AppColors.primaryDark.withValues(alpha: 0.5), fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1)),
              const SizedBox(height: 12),
              Row(
                children: ['Home', 'Work', 'Other'].map((l) => Padding(
                  padding: const EdgeInsets.only(right: 10),
                  child: ChoiceChip(
                    label: Text(l),
                    selected: _selectedLabel == l,
                    onSelected: (_) => setState(() => _selectedLabel = l),
                    selectedColor: AppColors.primaryDark,
                    labelStyle: TextStyle(color: _selectedLabel == l ? Colors.white : AppColors.primaryDark, fontWeight: FontWeight.w600),
                  ),
                )).toList(),
              ),
              const SizedBox(height: 24),
              _buildField("FULL NAME *"), _buildTextField(_nameController, "John Doe"),
              const SizedBox(height: 16),
              _buildField("PHONE *"), _buildTextField(_phoneController, "9876543210", isNumber: true),
              const SizedBox(height: 16),
              _buildField("ADDRESS *"), _buildTextField(_addressController, "Street, building, area"),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    _buildField("CITY *"), _buildTextField(_cityController, "Mumbai"),
                  ])),
                  const SizedBox(width: 12),
                  Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    _buildField("STATE *"), _buildTextField(_stateController, "Maharashtra"),
                  ])),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    _buildField("ZIP CODE *"), _buildTextField(_zipController, "400001", isNumber: true),
                  ])),
                  const SizedBox(width: 12),
                  Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    _buildField("COUNTRY"), _buildTextField(_countryController, "India"),
                  ])),
                ],
              ),
              const SizedBox(height: 40),
              SizedBox(
                width: double.infinity, height: 56,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _save,
                  style: ElevatedButton.styleFrom(backgroundColor: AppColors.primaryDark, foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)), elevation: 0),
                  child: _isLoading ? const CircularProgressIndicator(color: Colors.white) : Text(_isEditing ? "UPDATE ADDRESS" : "SAVE ADDRESS", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildField(String label) => Padding(
    padding: const EdgeInsets.only(bottom: 8),
    child: Text(label, style: TextStyle(color: AppColors.primaryDark.withValues(alpha: 0.5), fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1)),
  );

  Widget _buildTextField(TextEditingController c, String hint, {bool isNumber = false}) => Container(
    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: AppColors.softGrey)),
    child: TextFormField(
      controller: c,
      keyboardType: isNumber ? TextInputType.phone : TextInputType.text,
      decoration: InputDecoration(hintText: hint, hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14), border: InputBorder.none, contentPadding: const EdgeInsets.all(16)),
      validator: (v) => (v == null || v.isEmpty) ? "Required" : null,
    ),
  );
}
