import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/api_models.dart';
import '../models/cart_state.dart';
import '../models/user_state.dart';
import '../services/api_service.dart';
import '../services/razorpay_service.dart';
import '../services/mock_delivery_service.dart';
import '../services/prefs_service.dart';
import 'add_address_screen.dart';
import 'order_confirmation_screen.dart';

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  bool _isLoading = true;
  List<ApiAddress> _addresses = [];
  ApiAddress? _selectedAddress;
  bool _isCOD = false;
  bool _isPlacing = false;
  String? _statusMessage;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      await ApiService.loadToken();
      final addresses = await ApiService.getAddresses();
      if (mounted) {
        setState(() {
          _addresses = addresses;
          _selectedAddress = addresses.firstOrNull;
          _isLoading = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _placeOrder() async {
    if (_selectedAddress == null) {
      _showSnack("Please select a delivery address");
      return;
    }

    setState(() => _isPlacing = true);

    final cart = context.read<CartState>();
    final orderId = 'ORD-${DateTime.now().millisecondsSinceEpoch}';
    final totalPaid = cart.items.fold<double>(0, (sum, item) {
      final p = item.product;
      return sum + ((p.discountPriceAsDouble > 0 ? p.discountPriceAsDouble : p.priceAsDouble) * item.quantity);
    });
    String? paymentId;
    String? transactionId;

    if (!_isCOD) {
      setState(() => _statusMessage = "Opening payment gateway...");

      final userState = context.read<UserState>();
      final result = await RazorpayService.openCheckout(
        amountInINR: totalPaid,
        receiptId: orderId,
        context: context,
        contact: _selectedAddress?.phone,
        email: userState.userEmail,
      );

      if (result == null || !mounted) {
        setState(() => _isPlacing = false);
        return;
      }

      paymentId = result.paymentId;
      transactionId = result.orderId ?? result.paymentId;
    }

    try {
      setState(() => _statusMessage = "Creating order...");

      final purchaseData = <String, dynamic>{
        'address_id': _selectedAddress!.id,
        'payment_method_id': _isCOD ? 1 : 2,
        'latitude': 19.0760,
        'longitude': 72.8777,
        'products': cart.items.map((item) => {
          'product_id': item.product.id,
          'price': item.product.priceAsDouble,
          'paid_price': item.product.discountPriceAsDouble > 0 ? item.product.discountPriceAsDouble : item.product.priceAsDouble,
        }).toList(),
      };

      if (paymentId != null) purchaseData['payment_id'] = paymentId;
      if (transactionId != null) purchaseData['transaction_id'] = transactionId;

      final purchaseResult = await ApiService.createPurchase(purchaseData);
      final apiPurchase = purchaseResult['purchase'] ?? purchaseResult;
      final purchaseId = apiPurchase['id']?.toString() ?? orderId;

      String? deliveryId;
      String? estimatedDelivery;

      try {
        setState(() => _statusMessage = "Assigning delivery agent...");

        final deliveryResult = await MockDeliveryService.createDelivery(
          orderId: purchaseId,
          customerName: _selectedAddress!.name,
          address: _selectedAddress!.address,
          city: _selectedAddress!.city,
          phone: _selectedAddress!.phone,
          weight: '1kg',
        );

        if (deliveryResult.success) {
          deliveryId = deliveryResult.deliveryId;
          estimatedDelivery = deliveryResult.estimatedDelivery;
          await PrefsService.setString('delivery_for_$purchaseId', deliveryId!);
        }
      } catch (_) {}

      final address = _selectedAddress!;
      final purchase = <String, dynamic>{
        'id': apiPurchase['id'] ?? purchaseId,
        'address': {
          'label': address.label,
          'name': address.name,
          'address': address.address,
          'city': address.city,
          'state': address.state,
          'zip': address.zip,
        },
        'payment_method': {
          'name': _isCOD ? 'Cash on Delivery' : 'Razorpay (Online)',
        },
        'purchased_products': cart.items.map((item) => {
          'product': {
            'name': item.product.name,
          },
          'paid_price': (item.product.discountPriceAsDouble > 0 ? item.product.discountPriceAsDouble : item.product.priceAsDouble) * item.quantity,
          'quantity': item.quantity,
        }).toList(),
        'total_paid_price': totalPaid.toStringAsFixed(0),
      };

      cart.clearCart();

      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => OrderConfirmationScreen(
              purchase: purchase,
              deliveryId: deliveryId,
              estimatedDelivery: estimatedDelivery,
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        _showSnack(e.toString().replaceAll('Exception: ', ''));
        setState(() => _isPlacing = false);
      }
    }
  }

  void _showSnack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), backgroundColor: Colors.red.shade700),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final cart = context.watch<CartState>();
    final total = cart.totalPrice;
    final totalPaid = cart.items.fold<double>(0, (sum, item) {
      final p = item.product;
      return sum + ((p.discountPriceAsDouble > 0 ? p.discountPriceAsDouble : p.priceAsDouble) * item.quantity);
    });
    final savings = total - totalPaid;

    return Scaffold(
      backgroundColor: cs.surface,
      body: Column(
        children: [
          _buildAppBar(cs),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : SingleChildScrollView(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _sectionTitle(cs, "DELIVERY ADDRESS"),
                        const SizedBox(height: 12),
                        _buildAddressCard(cs),
                        const SizedBox(height: 16),
                        _buildOtherAddresses(cs),
                        _buildAddAddressButton(cs),
                        const SizedBox(height: 24),
                        _sectionTitle(cs, "PAYMENT"),
                        const SizedBox(height: 12),
                        _buildPaymentToggle(cs),
                        const SizedBox(height: 24),
                        _sectionTitle(cs, "ORDER SUMMARY"),
                        const SizedBox(height: 12),
                        _buildOrderSummary(cart, total, totalPaid, savings, cs),
                        const SizedBox(height: 40),
                      ],
                    ),
                  ),
          ),
          if (_isPlacing && _statusMessage != null)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
              color: cs.primary.withValues(alpha: 0.1),
              child: Row(children: [
                const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)),
                const SizedBox(width: 12),
                Text(_statusMessage!, style: TextStyle(color: cs.primary, fontWeight: FontWeight.w600, fontSize: 13)),
              ]),
            ),
          _buildBottomBar(totalPaid, cs),
        ],
      ),
    );
  }

  Widget _buildAppBar(ColorScheme cs) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      color: cs.surface,
      child: Row(
        children: [
          IconButton(
            icon: Icon(Icons.arrow_back, color: cs.onSurface),
            onPressed: () => Navigator.pop(context),
          ),
          const SizedBox(width: 8),
          Text(
            "CHECKOUT",
            style: TextStyle(
              color: cs.onSurface,
              fontWeight: FontWeight.bold,
              fontSize: 20,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAddressCard(ColorScheme cs) {
    if (_selectedAddress == null) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: cs.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: cs.outlineVariant),
        ),
        child: const Row(children: [
          Icon(Icons.location_off_outlined, color: Colors.grey),
          const SizedBox(width: 12),
          Text("No address selected", style: TextStyle(color: Colors.grey)),
        ]),
      );
    }
    final a = _selectedAddress!;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.green.shade200),
      ),
      child: Row(children: [
        Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: Colors.green.shade50, borderRadius: BorderRadius.circular(12)),
          child: Icon(Icons.location_on, color: Colors.green.shade700, size: 20)),
        const SizedBox(width: 12),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Text(a.label, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
            const SizedBox(width: 8),
            if (a.isDefault) Container(padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2), decoration: BoxDecoration(color: Colors.green.shade100, borderRadius: BorderRadius.circular(4)),
              child: Text("DEFAULT", style: TextStyle(fontSize: 8, fontWeight: FontWeight.bold, color: Colors.green.shade800))),
          ]),
          const SizedBox(height: 4),
          Text("${a.name} - ${a.phone}", style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
          Text("${a.address}, ${a.city}, ${a.state} - ${a.zip}", style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
        ])),
        const Icon(Icons.chevron_right, color: Colors.grey),
      ]),
    );
  }

  Widget _buildOtherAddresses(ColorScheme cs) {
    final others = _addresses.where((a) => a.id != _selectedAddress?.id).toList();
    if (others.isEmpty) return const SizedBox.shrink();
    return Column(children: [
      ...others.map((a) => Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: InkWell(
          onTap: () => setState(() => _selectedAddress = a),
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: cs.surface,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: cs.outlineVariant,
                width: 1,
              ),
            ),
            child: Row(children: [
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text("${a.label} - ${a.name}", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                Text("${a.address}, ${a.city} - ${a.zip}", style: TextStyle(fontSize: 11, color: Colors.grey.shade600)),
              ])),
              const Icon(Icons.radio_button_unchecked, color: Colors.grey, size: 20),
            ]),
          ),
        ),
      )),
    ]);
  }

  Widget _buildAddAddressButton(ColorScheme cs) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: () async {
          final added = await Navigator.push<bool>(context, MaterialPageRoute(builder: (_) => const AddAddressScreen()));
          if (added == true) _loadData();
        },
        icon: const Icon(Icons.add),
        label: const Text("ADD NEW ADDRESS"),
        style: OutlinedButton.styleFrom(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          side: BorderSide(color: Colors.grey),
        ),
      ),
    );
  }

  Widget _buildPaymentToggle(ColorScheme cs) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: cs.outlineVariant, width: 1),
      ),
      child: Row(children: [
        Expanded(
          child: GestureDetector(
            onTap: () => setState(() => _isCOD = false),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(vertical: 14),
              decoration: BoxDecoration(
                color: !_isCOD ? cs.primary : Colors.transparent,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                Icon(Icons.credit_card, size: 18, color: !_isCOD ? cs.onPrimary : cs.onSurface),
                const SizedBox(width: 8),
                Text("Pay Online", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: !_isCOD ? cs.onPrimary : cs.onSurface)),
              ]),
            ),
          ),
        ),
        Expanded(
          child: GestureDetector(
            onTap: () => setState(() => _isCOD = true),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(vertical: 14),
              decoration: BoxDecoration(
                color: _isCOD ? cs.primary : Colors.transparent,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                Icon(Icons.money, size: 18, color: _isCOD ? cs.onPrimary : cs.onSurface),
                const SizedBox(width: 8),
                Text("Cash on Delivery", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: _isCOD ? cs.onPrimary : cs.onSurface)),
              ]),
            ),
          ),
        ),
      ]),
    );
  }

  Widget _buildOrderSummary(CartState cart, double total, double totalPaid, double savings, ColorScheme cs) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: cs.outlineVariant, width: 1),
      ),
      child: Column(children: [
        ...cart.items.map((item) => Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Row(children: [
            ClipRRect(borderRadius: BorderRadius.circular(12),
              child: Image.network(item.product.displayImage.isNotEmpty ? item.product.displayImage : 'https://via.placeholder.com/50', width: 50, height: 50, fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(width: 50, height: 50, color: cs.surfaceContainerHighest, child: const Icon(Icons.image, color: Colors.grey)),
              )),
            const SizedBox(width: 12),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(item.product.name, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13), maxLines: 1, overflow: TextOverflow.ellipsis),
              Text("Qty: ${item.quantity} | ${item.size}", style: TextStyle(fontSize: 11, color: Colors.grey.shade600)),
            ])),
            Text("₹${((item.product.discountPriceAsDouble > 0 ? item.product.discountPriceAsDouble : item.product.priceAsDouble) * item.quantity).toStringAsFixed(0)}",
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
          ]),
        )),
        const Divider(),
        _priceRow(cs, "Total MRP", "₹${total.toStringAsFixed(0)}"),
        if (savings > 0) _priceRow(cs, "Discount", "-₹${savings.toStringAsFixed(0)}", color: Colors.green),
        const Divider(),
        _priceRow(cs, "Total Amount", "₹${totalPaid.toStringAsFixed(0)}", bold: true, size: 16),
      ]),
    );
  }

  Widget _buildBottomBar(double totalPaid, ColorScheme cs) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
      decoration: BoxDecoration(
        color: cs.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, -4)
          ),
        ],
      ),
      child: SafeArea(
        child: SizedBox(width: double.infinity, height: 56,
          child: ElevatedButton(
            onPressed: (_isPlacing || _selectedAddress == null) ? null : _placeOrder,
            style: ElevatedButton.styleFrom(
              backgroundColor: cs.primary,
              foregroundColor: cs.onPrimary,
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            ),
            child: _isPlacing
                ? const Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                    SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)),
                    SizedBox(width: 12),
                    Text("PROCESSING...", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                  ])
                : Text(
                    _isCOD ? "PLACE ORDER (COD) • ₹${totalPaid.toStringAsFixed(0)}" : "PAY ₹${totalPaid.toStringAsFixed(0)}",
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
          ),
        ),
      ),
    );
  }

  Widget _sectionTitle(ColorScheme cs, String title) => Text(title, style: TextStyle(color: cs.onSurface.withOpacity(0.5), fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1.5));

  Widget _priceRow(ColorScheme cs, String label, String amount, {Color? color, bool bold = false, double size = 14}) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 3),
    child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
      Text(label, style: TextStyle(color: color ?? cs.onSurface, fontSize: size - 2, fontWeight: bold ? FontWeight.bold : FontWeight.normal)),
      Text(amount, style: TextStyle(color: color ?? cs.onSurface, fontSize: size, fontWeight: bold ? FontWeight.bold : FontWeight.w600)),
    ]),
  );
}
