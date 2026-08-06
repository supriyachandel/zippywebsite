import 'package:flutter/material.dart';
import 'order_tracking_screen.dart';

class OrderConfirmationScreen extends StatelessWidget {
  final Map<String, dynamic> purchase;
  final String? deliveryId;
  final String? estimatedDelivery;
  final bool fromHistory;

  const OrderConfirmationScreen({
    super.key,
    required this.purchase,
    this.deliveryId,
    this.estimatedDelivery,
    this.fromHistory = false,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final id = purchase['id'] ?? '-';
    final address = purchase['address'] as Map<String, dynamic>?;
    final paymentMethod = purchase['payment_method'] as Map<String, dynamic>?;
    final products = purchase['purchased_products'] as List<dynamic>? ?? [];
    final totalPaid = purchase['total_paid_price'] ?? '0';

    return Scaffold(
      backgroundColor: cs.surface,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              if (!fromHistory) ...[
                const SizedBox(height: 40),
                Container(
                  width: 80, height: 80,
                  decoration: BoxDecoration(color: cs.primaryContainer, shape: BoxShape.circle),
                  child: Icon(Icons.check_circle, color: cs.primary, size: 50),
                ),
                const SizedBox(height: 20),
                Text("ORDER PLACED!", style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: cs.onSurface)),
                const SizedBox(height: 8),
              ],
              if (fromHistory) const SizedBox(height: 20),
              Text("Order #$id", style: TextStyle(fontSize: 14, color: cs.onSurface.withValues(alpha: 0.5))),
              const SizedBox(height: 4),
              Text("Total paid: ₹$totalPaid", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: cs.onSurface)),
              const SizedBox(height: 30),

              if (deliveryId != null) _buildDeliveryCard(context, cs),
              if (deliveryId != null) const SizedBox(height: 16),

              if (address != null)
                _buildInfoCard(cs, "DELIVERING TO",
                  "${address['label']} - ${address['name']}\n${address['address']}, ${address['city']}\n${address['state']} - ${address['zip']}",
                  Icons.location_on,
                ),
              const SizedBox(height: 16),

              if (paymentMethod != null)
                _buildInfoCard(cs, "PAYMENT METHOD",
                  paymentMethod['name']?.toString() ?? '',
                  Icons.payment,
                ),
              const SizedBox(height: 16),

              _buildInfoCard(cs, "ITEMS (${products.length})",
                products.map((p) {
                  final product = (p as Map<String, dynamic>)['product'] as Map<String, dynamic>?;
                  return "• ${product?['name'] ?? 'Product'}";
                }).join('\n'),
                Icons.shopping_bag_outlined,
              ),
              const SizedBox(height: 40),

              SizedBox(
                width: double.infinity, height: 56,
                child: ElevatedButton(
                  onPressed: () => fromHistory ? Navigator.pop(context) : Navigator.pushNamedAndRemoveUntil(context, '/home', (route) => false),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: cs.primary,
                    foregroundColor: cs.onPrimary,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    elevation: 0,
                  ),
                  child: const Text("BACK TO HOME", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                ),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDeliveryCard(BuildContext context, ColorScheme cs) {
    return InkWell(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => OrderTrackingScreen(deliveryId: deliveryId!)),
      ),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: cs.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: cs.primary.withValues(alpha: 0.3)),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(color: cs.primaryContainer, borderRadius: BorderRadius.circular(12)),
              child: Icon(Icons.local_shipping, color: cs.primary, size: 22),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Delivery #$deliveryId", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: cs.onSurface)),
                  if (estimatedDelivery != null)
                    Text("Est. delivery: $estimatedDelivery", style: TextStyle(fontSize: 12, color: cs.onSurface.withValues(alpha: 0.5))),
                  Text("Tap to track", style: TextStyle(fontSize: 11, color: cs.primary)),
                ],
              ),
            ),
            Icon(Icons.chevron_right, color: cs.onSurface.withValues(alpha: 0.4)),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard(ColorScheme cs, String title, String content, IconData icon) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: cs.outlineVariant),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: cs.surfaceContainerHighest, borderRadius: BorderRadius.circular(10)),
            child: Icon(icon, color: cs.onSurface, size: 20),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: TextStyle(color: cs.onSurface.withValues(alpha: 0.5), fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1)),
                const SizedBox(height: 6),
                Text(content, style: TextStyle(color: cs.onSurface, fontSize: 13, fontWeight: FontWeight.w500)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
