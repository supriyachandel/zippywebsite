import 'package:flutter/material.dart';
import '../../utils/app_colors.dart';
import '../services/store_api_service.dart';

class DeliveryPartnerScreen extends StatefulWidget {
  const DeliveryPartnerScreen({super.key});

  @override
  State<DeliveryPartnerScreen> createState() => _DeliveryPartnerScreenState();
}

class _DeliveryPartnerScreenState extends State<DeliveryPartnerScreen> {
  List<Map<String, dynamic>> _partners = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _isLoading = true);
    try {
      final raw = await StoreApiService.getDeliveryPartners();
      if (mounted) {
        setState(() {
          _partners = raw.map((e) => e is Map<String, dynamic> ? e : <String, dynamic>{}).toList();
          _isLoading = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _addPartner() async {
    final result = await _showPartnerForm();
    if (result != null && mounted) {
      await StoreApiService.createDeliveryPartner(result);
      _load();
    }
  }

  Future<void> _editPartner(Map<String, dynamic> partner) async {
    final result = await _showPartnerForm(partner: partner);
    if (result != null && mounted) {
      final id = partner['id'] as int;
      await StoreApiService.updateDeliveryPartner(id, result);
      _load();
    }
  }

  Future<Map<String, dynamic>?> _showPartnerForm({Map<String, dynamic>? partner}) async {
    final nameCtrl = TextEditingController(text: partner?['name']?.toString() ?? '');
    final phoneCtrl = TextEditingController(text: partner?['phone']?.toString() ?? '');
    final vehicleCtrl = TextEditingController(text: partner?['vehicle']?.toString() ?? '');
    final isEdit = partner != null;

    return showDialog<Map<String, dynamic>>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(isEdit ? "Edit Partner" : "Add Partner"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameCtrl,
              decoration: const InputDecoration(labelText: "Name", border: OutlineInputBorder()),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: phoneCtrl,
              keyboardType: TextInputType.phone,
              decoration: const InputDecoration(labelText: "Phone", border: OutlineInputBorder()),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: vehicleCtrl,
              decoration: const InputDecoration(labelText: "Vehicle", border: OutlineInputBorder()),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("CANCEL")),
          TextButton(
            onPressed: () {
              if (nameCtrl.text.trim().isEmpty || phoneCtrl.text.trim().isEmpty) return;
              Navigator.pop(ctx, {
                'name': nameCtrl.text.trim(),
                'phone': phoneCtrl.text.trim(),
                'vehicle': vehicleCtrl.text.trim(),
                'active': true,
              });
            },
            child: const Text("SAVE", style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final activeCount = _partners.where((p) => p['active'] == true).length;
    final inactiveCount = _partners.where((p) => p['active'] != true).length;

    return Scaffold(
      backgroundColor: AppColors.offWhite,
      appBar: AppBar(
        title: const Text("DELIVERY PARTNERS"),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addPartner,
        backgroundColor: AppColors.primaryBlue,
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(20),
                  margin: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: AppColors.softGrey),
                  ),
                  child: Row(
                    children: [
                      _miniStat(activeCount.toString(), "Active", AppColors.successGreen),
                      const SizedBox(width: 12),
                      _miniStat(inactiveCount.toString(), "Inactive", Colors.grey),
                      const SizedBox(width: 12),
                      _miniStat(_partners.length.toString(), "Total", AppColors.primaryBlue),
                    ],
                  ),
                ),
                Expanded(
                  child: _partners.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.local_shipping_outlined, size: 60, color: Colors.grey.shade300),
                              const SizedBox(height: 16),
                              Text("No delivery partners", style: TextStyle(color: Colors.grey.shade500, fontWeight: FontWeight.bold)),
                              const SizedBox(height: 8),
                              ElevatedButton(onPressed: _addPartner, child: const Text("Add Partner")),
                            ],
                          ),
                        )
                      : RefreshIndicator(
                          onRefresh: _load,
                          child: ListView.builder(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            itemCount: _partners.length,
                            itemBuilder: (_, i) => _buildPartnerCard(_partners[i]),
                          ),
                        ),
                ),
              ],
            ),
    );
  }

  Widget _miniStat(String value, String label, Color color) {
    return Expanded(
      child: Column(
        children: [
          Text(value, style: TextStyle(fontWeight: FontWeight.w900, fontSize: 20, color: color)),
          Text(label, style: TextStyle(fontSize: 10, color: Colors.grey.shade600, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildPartnerCard(Map<String, dynamic> partner) {
    final name = partner['name']?.toString() ?? 'Unknown';
    final phone = partner['phone']?.toString() ?? '';
    final vehicle = partner['vehicle']?.toString() ?? '';
    final rating = partner['rating']?.toString() ?? '0';
    final isActive = partner['active'] == true;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.softGrey),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            CircleAvatar(
              radius: 24,
              backgroundColor: isActive ? AppColors.successGreen.withOpacity(0.1) : Colors.grey.shade100,
              child: Icon(Icons.local_shipping, color: isActive ? AppColors.successGreen : Colors.grey),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: isActive ? AppColors.successGreen.withOpacity(0.1) : Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          isActive ? "ACTIVE" : "INACTIVE",
                          style: TextStyle(fontSize: 8, fontWeight: FontWeight.bold, color: isActive ? AppColors.successGreen : Colors.grey),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.phone, size: 12, color: Colors.grey),
                      const SizedBox(width: 4),
                      Text(phone, style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
                      const SizedBox(width: 16),
                      const Icon(Icons.directions_bike, size: 12, color: Colors.grey),
                      const SizedBox(width: 4),
                      Expanded(child: Text(vehicle, style: TextStyle(fontSize: 12, color: Colors.grey.shade600), overflow: TextOverflow.ellipsis)),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.star, size: 12, color: Colors.amber),
                      const SizedBox(width: 4),
                      Text(rating, style: TextStyle(fontSize: 12, color: Colors.amber.shade700, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ],
              ),
            ),
            Column(
              children: [
                Switch(
                  value: isActive,
                  onChanged: (_) async {
                    final id = partner['id'] as int;
                    await StoreApiService.toggleDeliveryPartner(id);
                    _load();
                  },
                  activeColor: AppColors.successGreen,
                ),
                GestureDetector(
                  onTap: () => _editPartner(partner),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.primaryBlue.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Text("EDIT", style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: AppColors.primaryBlue)),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
