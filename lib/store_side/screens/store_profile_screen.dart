import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import '../../utils/app_colors.dart';
import '../services/store_api_service.dart';
import '../services/store_auth_service.dart';


class StoreProfileScreen extends StatefulWidget {
  const StoreProfileScreen({super.key});

  @override
  State<StoreProfileScreen> createState() => _StoreProfileScreenState();
}

class _StoreProfileScreenState extends State<StoreProfileScreen> {
  Map<String, dynamic> _shop = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadShop();
  }

  void _loadShop() async {
    var id = StoreApiService.shopId;
    // If no shop ID saved, try fetching from user's shop
    if (id == null || id == 0) {
      try {
        final userData = await StoreApiService.getUserShop();
        if (userData != null) {
          id = userData['id'];
          if (id != null) await StoreApiService.setShopId(int.tryParse(id.toString()));
        }
      } catch (_) {}
    }
    if (id == null || id == 0) {
      if (mounted) setState(() => _isLoading = false);
      return;
    }
    try {
      final data = await StoreApiService.getShopDetails(id);
      if (mounted) {
        setState(() {
          _shop = data['shop'] ?? data['data'] ?? data;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Failed to load shop: ${e.toString().replaceAll('Exception: ', '')}"),
            backgroundColor: Colors.red.shade700,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  void _showShopDetails() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Icon(Icons.store, color: AppColors.primaryBlue, size: 28),
            const SizedBox(width: 10),
            const Text("Shop Details", style: TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (_shop['image'] != null && _shop['image'].toString().isNotEmpty)
                Center(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: Image.network(_shop['image'].toString(), width: 100, height: 100, fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => const SizedBox.shrink(),
                    ),
                  ),
                ),
              if (_shop['image'] != null && _shop['image'].toString().isNotEmpty)
                const SizedBox(height: 16),
              _detailText("Name", _shop['name']?.toString()),
              _detailText("ID", _shop['id']?.toString()),
              _detailText("Shop No.", _shop['shop_number']?.toString()),
              _detailText("Description", _shop['description']?.toString()),
              _detailText("Phone", _shop['phone']?.toString()),
              _detailText("Email", _shop['email']?.toString()),
              _detailText("GST", _shop['gst_number']?.toString()),
              _detailText("Address", _shop['address']?.toString()),
              _detailText("City", _shop['city']?.toString()),
              _detailText("State", _shop['state']?.toString()),
              _detailText("ZIP", _shop['zip']?.toString()),
              _detailText("Country", _shop['country']?.toString()),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("CLOSE", style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  Widget _detailText(String label, String? value) {
    if (value == null || value.isEmpty || value == 'Not Provided') return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text("$label:", style: TextStyle(color: Colors.grey.shade600, fontWeight: FontWeight.w500, fontSize: 13)),
          ),
          Expanded(child: Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13))),
        ],
      ),
    );
  }

  void _showInfo(String title, String message) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("OK", style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  void _showEditShopSheet() {
    final nameCtl = TextEditingController(text: _shop['name']?.toString() ?? '');
    final descCtl = TextEditingController(text: _shop['description']?.toString() ?? '');
    final phoneCtl = TextEditingController(text: _shop['phone']?.toString() ?? '');
    final emailCtl = TextEditingController(text: _shop['email']?.toString() ?? '');
    final gstCtl = TextEditingController(text: _shop['gst_number']?.toString() ?? '');
    final addressCtl = TextEditingController(text: _shop['address']?.toString() ?? '');
    final cityCtl = TextEditingController(text: _shop['city']?.toString() ?? '');
    final stateCtl = TextEditingController(text: _shop['state']?.toString() ?? '');
    final zipCtl = TextEditingController(text: _shop['zip']?.toString() ?? '');
    final countryCtl = TextEditingController(text: _shop['country']?.toString() ?? 'India');
    final shopNoCtl = TextEditingController(text: _shop['shop_number']?.toString() ?? '');
    final formKey = GlobalKey<FormState>();
    bool saving = false;
    File? selectedImage;
    final picker = ImagePicker();

    final currentImage = _shop['image']?.toString();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setSheetState) => Padding(
          padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
          child: Container(
            padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
            child: Form(
              key: formKey,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(child: Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(2)))),
                    const SizedBox(height: 16),
                    const Text("EDIT SHOP", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                    const SizedBox(height: 24),
                    GestureDetector(
                      onTap: () async {
                        final picked = await picker.pickImage(source: ImageSource.gallery, imageQuality: 85);
                        if (picked != null) setSheetState(() => selectedImage = File(picked.path));
                      },
                      child: Center(
                        child: Stack(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(20),
                              child: selectedImage != null
                                  ? Image.file(selectedImage!, width: 100, height: 100, fit: BoxFit.cover)
                                  : currentImage != null && currentImage.isNotEmpty
                                      ? Image.network(currentImage, width: 100, height: 100, fit: BoxFit.cover,
                                          errorBuilder: (_, __, ___) => Container(width: 100, height: 100, color: AppColors.softGrey, child: const Icon(Icons.store, size: 40)),
                                        )
                                      : Container(width: 100, height: 100, color: AppColors.softGrey, child: const Icon(Icons.store, size: 40)),
                            ),
                            Positioned(bottom: 0, right: 0,
                              child: Container(padding: const EdgeInsets.all(4), decoration: const BoxDecoration(color: AppColors.primaryDark, shape: BoxShape.circle),
                                child: const Icon(Icons.camera_alt, size: 18, color: Colors.white),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    if (selectedImage != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: Center(
                          child: Text("Tap to change image", style: TextStyle(color: AppColors.primaryDark.withValues(alpha: 0.5), fontSize: 11)),
                        ),
                      ),
                    const SizedBox(height: 24),
                    _editField("Shop Name", nameCtl, required: true),
                    const SizedBox(height: 14),
                    _editField("Shop No.", shopNoCtl),
                    const SizedBox(height: 14),
                    _editField("Description", descCtl, maxLines: 3),
                    const SizedBox(height: 14),
                    _editField("Phone", phoneCtl, isNumber: true),
                    const SizedBox(height: 14),
                    _editField("Email", emailCtl),
                    const SizedBox(height: 14),
                    _editField("GST Number", gstCtl),
                    const SizedBox(height: 14),
                    _editField("Address", addressCtl),
                    const SizedBox(height: 14),
                    Row(children: [
                      Expanded(child: _editField("City", cityCtl)),
                      const SizedBox(width: 12),
                      Expanded(child: _editField("State", stateCtl)),
                    ]),
                    const SizedBox(height: 14),
                    Row(children: [
                      Expanded(child: _editField("ZIP Code", zipCtl)),
                      const SizedBox(width: 12),
                      Expanded(child: _editField("Country", countryCtl)),
                    ]),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity, height: 52,
                      child: ElevatedButton(
                        onPressed: saving
                            ? null
                            : () async {
                                if (!formKey.currentState!.validate()) return;
                                setSheetState(() => saving = true);
                                try {
                                  final res = await StoreApiService.updateShop(int.parse(_shop['id'].toString()), {
                                    'name': nameCtl.text,
                                    'description': descCtl.text,
                                    'shop_number': shopNoCtl.text,
                                    'phone': phoneCtl.text,
                                    'email': emailCtl.text,
                                    'gst_number': gstCtl.text,
                                    'address': addressCtl.text,
                                    'city': cityCtl.text,
                                    'state': stateCtl.text,
                                    'zip': zipCtl.text,
                                    'country': countryCtl.text,
                                    'status': _shop['status'] ?? 'active',
                                  }, imageFile: selectedImage);
                                  final updated = res['shop'] ?? res['data'] ?? res;
                                  if (mounted) setState(() => _shop = updated is Map<String, dynamic> ? updated : _shop);
                                  Navigator.pop(ctx);
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text("Shop updated!"), behavior: SnackBarBehavior.floating, backgroundColor: Colors.green),
                                  );
                                } catch (e) {
                                  setSheetState(() => saving = false);
                                  ScaffoldMessenger.of(ctx).showSnackBar(
                                    SnackBar(content: Text(e.toString().replaceAll('Exception: ', '')), backgroundColor: Colors.red.shade700),
                                  );
                                }
                              },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primaryDark, foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)), elevation: 0,
                        ),
                        child: saving
                            ? const CircularProgressIndicator(color: Colors.white)
                            : const Text("SAVE CHANGES", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _editField(String label, TextEditingController c, {bool required = false, int maxLines = 1, bool isNumber = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(color: AppColors.primaryDark.withValues(alpha: 0.5), fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1)),
        const SizedBox(height: 6),
        Container(
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: AppColors.softGrey)),
          child: TextFormField(
            controller: c,
            maxLines: maxLines,
            keyboardType: isNumber ? TextInputType.phone : TextInputType.text,
            decoration: InputDecoration(
              hintText: label, hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14),
              border: InputBorder.none, contentPadding: const EdgeInsets.all(16),
            ),
            validator: required ? (v) => (v == null || v.isEmpty) ? "Required" : null : null,
          ),
        ),
      ],
    );
  }

  void _logout() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text("LOG OUT", style: TextStyle(fontWeight: FontWeight.bold)),
        content: const Text("Are you sure you want to log out?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("CANCEL", style: TextStyle(color: Colors.grey)),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(ctx);
              await StoreAuthService().logout();
              if (context.mounted) Navigator.pushReplacementNamed(context, '/');
            },
            child: const Text("LOG OUT", style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        backgroundColor: AppColors.offWhite,
        body: SafeArea(child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("SHOP PROFILE", style: GoogleFonts.inter(fontSize: 24, fontWeight: FontWeight.w900, color: AppColors.primaryDark)),
              const Spacer(),
              const Center(child: CircularProgressIndicator()),
              const Spacer(),
            ],
          ),
        )),
      );
    }

    final image = _shop['image']?.toString();
    final name = _shop['name']?.toString() ?? 'My Shop';
    final description = _shop['description']?.toString();
    final shopNumber = _shop['shop_number']?.toString();
    final phone = _shop['phone']?.toString();
    final email = _shop['email']?.toString();
    final gst = _shop['gst_number']?.toString();
    final address = _shop['address']?.toString();
    final city = _shop['city']?.toString();
    final state = _shop['state']?.toString();
    final zip = _shop['zip']?.toString();
    final country = _shop['country']?.toString();
    final shopId = _shop['id']?.toString() ?? StoreApiService.shopId?.toString() ?? '-';

    return Scaffold(
      backgroundColor: AppColors.offWhite,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "SHOP PROFILE",
                style: GoogleFonts.inter(fontSize: 24, fontWeight: FontWeight.w900, color: AppColors.primaryDark),
              ),
              const SizedBox(height: 8),
              Row(mainAxisAlignment: MainAxisAlignment.end, children: [
                TextButton.icon(
                  onPressed: _showEditShopSheet,
                  icon: const Icon(Icons.edit_outlined, size: 16),
                  label: const Text("EDIT", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                ),
              ]),
              const SizedBox(height: 8),

              _buildShopHeader(image, name, city, shopId),
              const SizedBox(height: 24),

              if (description != null && description.isNotEmpty) ...[
                _buildInfoSection("ABOUT", Text(description, style: const TextStyle(fontSize: 13, color: AppColors.primaryDark))),
                const SizedBox(height: 24),
              ],

              _buildInfoSection(
                "CONTACT & ADDRESS",
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildDetailRow(Icons.store_outlined, "Shop No.", shopNumber),
                    _buildDetailRow(Icons.phone_outlined, "Phone", phone),
                    _buildDetailRow(Icons.email_outlined, "Email", email),
                    _buildDetailRow(Icons.receipt_outlined, "GST", gst),
                    if (address != null) _buildDetailRow(Icons.location_on_outlined, "Address", address),
                    _buildDetailRow(Icons.location_city_outlined, "City", city),
                    _buildDetailRow(Icons.map_outlined, "State", state),
                    _buildDetailRow(Icons.markunread_mailbox_outlined, "ZIP", zip),
                    _buildDetailRow(Icons.public_outlined, "Country", country),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              _buildSectionTitle("BUSINESS SETTINGS"),
              const SizedBox(height: 16),
              _buildProfileOption(Icons.storefront_outlined, "Shop Details", "Name, Logo, Address",
                onTap: _showEditShopSheet,
              ),
              _buildProfileOption(Icons.payments_outlined, "Payout Settings", "Bank account, UPI",
                onTap: () => _showInfo("Payout Settings", "Payout settings will be available soon."),
              ),
              _buildProfileOption(Icons.notifications_none_rounded, "Notifications", "Order alerts, Updates",
                onTap: () => _showInfo("Notifications", "Notification preferences will be available soon."),
              ),

              const SizedBox(height: 32),
              _buildSectionTitle("SUPPORT & LEGAL"),
              const SizedBox(height: 16),
              _buildProfileOption(Icons.help_outline_rounded, "Help Center", "FAQs, Contact support",
                onTap: () => _showInfo("Help Center", "Contact support at support@thstyle.com\n\nFAQs will be available soon."),
              ),
              _buildProfileOption(Icons.policy_outlined, "Policies", "Returns, Seller terms",
                onTap: () => _showInfo("Policies", "Seller terms and return policies will be available soon."),
              ),

              const SizedBox(height: 40),
              ElevatedButton(
                onPressed: _logout,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red.withValues(alpha: 0.1),
                  foregroundColor: Colors.red,
                  minimumSize: const Size(double.infinity, 60),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  elevation: 0,
                ),
                child: const Text("LOGOUT ACCOUNT", style: TextStyle(fontWeight: FontWeight.bold)),
              ),
              const SizedBox(height: 100),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildShopHeader(String? image, String name, String? city, String shopId) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.softGrey),
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: image != null && image.isNotEmpty
                ? Image.network(image, width: 80, height: 80, fit: BoxFit.cover,
                    errorBuilder: (_, _, _) => Container(
                      width: 80, height: 80, color: AppColors.softGrey,
                      child: const Icon(Icons.store, color: AppColors.primaryDark, size: 40),
                    ),
                  )
                : Container(
                    width: 80, height: 80, color: AppColors.softGrey,
                    child: const Icon(Icons.store, color: AppColors.primaryDark, size: 40),
                  ),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                if (city != null && city.isNotEmpty && city != 'Not Provided')
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(city, style: TextStyle(color: AppColors.primaryDark.withValues(alpha: 0.5))),
                  ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.green.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text("ID: $shopId",
                    style: const TextStyle(color: Colors.green, fontSize: 10, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoSection(String title, Widget content) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.softGrey),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: GoogleFonts.inter(
            fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1.5,
            color: AppColors.primaryDark.withValues(alpha: 0.5),
          )),
          const SizedBox(height: 16),
          content,
        ],
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String? value) {
    if (value == null || value.isEmpty || value == 'Not Provided') return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Icon(icon, size: 16, color: AppColors.primaryDark.withValues(alpha: 0.4)),
          const SizedBox(width: 10),
          SizedBox(
            width: 70,
            child: Text(label,
              style: TextStyle(color: AppColors.primaryDark.withValues(alpha: 0.4), fontSize: 12, fontWeight: FontWeight.w500),
            ),
          ),
          Expanded(
            child: Text(value,
              style: const TextStyle(color: AppColors.primaryDark, fontSize: 13, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(title, style: GoogleFonts.inter(
      fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 1.5,
      color: AppColors.primaryDark.withValues(alpha: 0.5),
    ));
  }

  Widget _buildProfileOption(IconData icon, String title, String subtitle, {VoidCallback? onTap}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.softGrey),
      ),
      child: Material(
        color: Colors.transparent,
        child: ListTile(
          onTap: onTap ?? () {},
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          leading: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.softGrey,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: AppColors.primaryDark, size: 20),
          ),
          title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
          subtitle: Text(subtitle, style: const TextStyle(fontSize: 12)),
          trailing: const Icon(Icons.chevron_right, size: 20),
        ),
      ),
    );
  }
}
