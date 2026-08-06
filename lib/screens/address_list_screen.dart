import 'package:flutter/material.dart';
import '../models/api_models.dart';
import '../services/api_service.dart';
import '../utils/app_colors.dart';
import 'add_address_screen.dart';

Future<bool?> _confirmDelete(BuildContext context) => showDialog<bool>(
  context: context,
  builder: (ctx) => AlertDialog(
    title: const Text("Delete address?"),
    content: const Text("This action cannot be undone."),
    actions: [
      TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text("CANCEL")),
      TextButton(onPressed: () => Navigator.pop(ctx, true), child: Text("DELETE", style: TextStyle(color: Colors.red.shade700))),
    ],
  ),
);

class AddressListScreen extends StatefulWidget {
  const AddressListScreen({super.key});

  @override
  State<AddressListScreen> createState() => _AddressListScreenState();
}

class _AddressListScreenState extends State<AddressListScreen> {
  List<ApiAddress> _addresses = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _isLoading = true);
    try {
      await ApiService.loadToken();
      final list = await ApiService.getAddresses();
      if (mounted) setState(() { _addresses = list; _isLoading = false; });
    } catch (_) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.offWhite,
      appBar: AppBar(title: const Text("SAVED ADDRESSES")),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final added = await Navigator.push<bool>(context, MaterialPageRoute(builder: (_) => const AddAddressScreen()));
          if (added == true) _load();
        },
        backgroundColor: AppColors.primaryDark,
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _addresses.isEmpty
              ? Center(
                  child: Column(mainAxisSize: MainAxisSize.min, children: [
                    Icon(Icons.location_off_outlined, size: 60, color: Colors.grey.shade300),
                    const SizedBox(height: 16),
                    Text("No saved addresses", style: TextStyle(color: Colors.grey.shade500, fontSize: 16)),
                    const SizedBox(height: 16),
                    ElevatedButton.icon(
                      onPressed: () async {
                        final added = await Navigator.push<bool>(context, MaterialPageRoute(builder: (_) => const AddAddressScreen()));
                        if (added == true) _load();
                      },
                      icon: const Icon(Icons.add),
                      label: const Text("ADD ADDRESS"),
                    ),
                  ]),
                )
              : RefreshIndicator(
                  onRefresh: _load,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(20),
                    itemCount: _addresses.length,
                    itemBuilder: (context, i) {
                      final a = _addresses[i];
                      return Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(18), border: Border.all(color: AppColors.softGrey)),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(padding: const EdgeInsets.all(10), decoration: BoxDecoration(color: AppColors.softGrey, borderRadius: BorderRadius.circular(12)),
                              child: Icon(_labelIcon(a.label), color: AppColors.primaryDark, size: 22)),
                            const SizedBox(width: 14),
                            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                              Row(children: [
                                Text(a.label, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                                const SizedBox(width: 8),
                                if (a.isDefault) Container(padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2), decoration: BoxDecoration(color: Colors.green.shade100, borderRadius: BorderRadius.circular(4)),
                                  child: Text("DEFAULT", style: TextStyle(fontSize: 8, fontWeight: FontWeight.bold, color: Colors.green.shade800))),
                              ]),
                              const SizedBox(height: 4),
                              Text("${a.name} - ${a.phone}", style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
                              Text("${a.address}, ${a.city}, ${a.state} - ${a.zip}", style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
                              const SizedBox(height: 8),
                              Row(children: [
                                GestureDetector(
                                  onTap: () async {
                                    final edited = await Navigator.push<bool>(context, MaterialPageRoute(builder: (_) => AddAddressScreen(address: a)));
                                    if (edited == true) _load();
                                  },
                                  child: Container(padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                    decoration: BoxDecoration(border: Border.all(color: AppColors.softGrey), borderRadius: BorderRadius.circular(8)),
                                    child: Row(mainAxisSize: MainAxisSize.min, children: [
                                      Icon(Icons.edit_outlined, size: 14, color: AppColors.primaryDark),
                                      const SizedBox(width: 4),
                                      Text("Edit", style: TextStyle(fontSize: 12, color: AppColors.primaryDark, fontWeight: FontWeight.w600)),
                                    ]),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                GestureDetector(
                                  onTap: () async {
                                    final ok = await _confirmDelete(context);
                                    if (ok != true) return;
                                    try {
                                      await ApiService.deleteAddress(a.id);
                                      if (mounted) _load();
                                    } catch (e) {
                                      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("$e"), backgroundColor: Colors.red.shade700));
                                    }
                                  },
                                  child: Container(padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                    decoration: BoxDecoration(border: Border.all(color: Colors.red.shade200), borderRadius: BorderRadius.circular(8)),
                                    child: Row(mainAxisSize: MainAxisSize.min, children: [
                                      Icon(Icons.delete_outline, size: 14, color: Colors.red.shade600),
                                      const SizedBox(width: 4),
                                      Text("Delete", style: TextStyle(fontSize: 12, color: Colors.red.shade600, fontWeight: FontWeight.w600)),
                                    ]),
                                  ),
                                ),
                              ]),
                            ])),
                          ],
                        ),
                      );
                    },
                  ),
                ),
    );
  }

  IconData _labelIcon(String label) {
    switch (label.toLowerCase()) {
      case 'home': return Icons.home_outlined;
      case 'work': return Icons.work_outlined;
      default: return Icons.location_on_outlined;
    }
  }
}
