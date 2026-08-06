import 'package:flutter/material.dart';
import '../models/api_models.dart';
import '../services/api_service.dart';
import '../utils/app_colors.dart';

class PaymentMethodsScreen extends StatefulWidget {
  const PaymentMethodsScreen({super.key});

  @override
  State<PaymentMethodsScreen> createState() => _PaymentMethodsScreenState();
}

class _PaymentMethodsScreenState extends State<PaymentMethodsScreen> {
  List<ApiPaymentMethod> _methods = [];
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
      final methods = await ApiService.getPaymentMethods();
      if (mounted) setState(() { _methods = methods; _isLoading = false; });
    } catch (_) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.offWhite,
      appBar: AppBar(title: const Text("PAYMENT METHODS")),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _methods.isEmpty
              ? Center(
                  child: Column(mainAxisSize: MainAxisSize.min, children: [
                    Icon(Icons.credit_card_outlined, size: 60, color: Colors.grey.shade300),
                    const SizedBox(height: 16),
                    Text("No payment methods", style: TextStyle(color: Colors.grey.shade500, fontSize: 16)),
                  ]),
                )
              : RefreshIndicator(
                  onRefresh: _load,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(20),
                    itemCount: _methods.length,
                    itemBuilder: (ctx, i) => _buildCard(_methods[i]),
                  ),
                ),
    );
  }

  Widget _buildCard(ApiPaymentMethod m) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), border: Border.all(color: AppColors.softGrey)),
      child: Row(children: [
        Container(padding: const EdgeInsets.all(10), decoration: BoxDecoration(color: AppColors.primaryDark.withValues(alpha: 0.08), borderRadius: BorderRadius.circular(14)),
          child: Icon(_icon(m.type), color: AppColors.primaryDark, size: 24)),
        const SizedBox(width: 14),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(m.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: AppColors.primaryDark)),
          if (m.description != null) Text(m.description!, style: TextStyle(fontSize: 12, color: Colors.grey.shade500)),
        ])),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: m.status == 'active' ? Colors.green.shade50 : Colors.grey.shade100,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            m.status == 'active' ? 'ACTIVE' : m.status.toUpperCase(),
            style: TextStyle(fontSize: 8, fontWeight: FontWeight.bold, color: m.status == 'active' ? Colors.green.shade700 : Colors.grey),
          ),
        ),
      ]),
    );
  }

  IconData _icon(String type) {
    switch (type) {
      case 'cash': return Icons.money;
      case 'upi': return Icons.phone_android;
      case 'credit_card': return Icons.credit_card;
      case 'debit_card': return Icons.credit_card_outlined;
      case 'wallet': return Icons.account_balance_wallet;
      default: return Icons.payment;
    }
  }
}
