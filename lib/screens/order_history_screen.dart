import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/api_service.dart';
import '../services/mock_delivery_service.dart';
import '../services/prefs_service.dart';
import '../utils/app_colors.dart';
import 'order_confirmation_screen.dart';
import 'order_tracking_screen.dart';

class OrderHistoryScreen extends StatefulWidget {
  const OrderHistoryScreen({super.key});

  @override
  State<OrderHistoryScreen> createState() => _OrderHistoryScreenState();
}

class _OrderHistoryScreenState extends State<OrderHistoryScreen> {
  List<dynamic> _purchases = [];
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
      final list = await ApiService.getPurchases();
      if (mounted) setState(() { _purchases = list; _isLoading = false; });
    } catch (_) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _viewOrder(Map<String, dynamic> purchase) async {
    final deliveryId = await _getDeliveryId(purchase);
    if (mounted) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => OrderConfirmationScreen(
            purchase: purchase,
            deliveryId: deliveryId,
            fromHistory: true,
          ),
        ),
      );
    }
  }

  Future<String?> _getDeliveryId(Map<String, dynamic> purchase) async {
    final id = purchase['id']?.toString();
    if (id == null) return null;
    final stored = await PrefsService.getString('delivery_for_$id');
    if (stored != null) return stored;
    final delivery = await MockDeliveryService.getDeliveryByOrderId(id);
    return delivery?['deliveryId']?.toString();
  }

  Future<void> _trackOrder(Map<String, dynamic> purchase) async {
    final deliveryId = await _getDeliveryId(purchase);
    if (deliveryId == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Tracking info not available for this order")),
        );
      }
      return;
    }
    if (mounted) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => OrderTrackingScreen(deliveryId: deliveryId)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        title: Text(
          "My Orders",
          style: TextStyle(
            fontWeight: FontWeight.w900,
            fontSize: 22,
            color: cs.onSurface,
            letterSpacing: -0.5,
          ),
        ),
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator(color: cs.primary))
          : _purchases.isEmpty
              ? _buildEmptyState(cs)
              : RefreshIndicator(
                  onRefresh: _load,
                  color: cs.primary,
                  child: ListView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                    itemCount: _purchases.length,
                    itemBuilder: (context, i) => _buildOrderCard(_purchases[i], cs),
                  ),
                ),
    );
  }

  Widget _buildEmptyState(ColorScheme cs) {
    return Center(
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            color: cs.surfaceContainerHighest.withValues(alpha: 0.4),
            borderRadius: BorderRadius.circular(24),
          ),
          child: Icon(Icons.receipt_long_outlined, size: 36, color: cs.onSurface.withValues(alpha: 0.3)),
        ),
        const SizedBox(height: 16),
        Text(
          "No orders yet",
          style: TextStyle(color: cs.onSurface.withValues(alpha: 0.5), fontSize: 16, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 6),
        Text(
          "Your orders will appear here once you make a purchase",
          style: TextStyle(color: cs.onSurface.withValues(alpha: 0.35), fontSize: 13),
        ),
      ]),
    );
  }

  Widget _buildOrderCard(Map<String, dynamic> p, ColorScheme cs) {
    final products = p['purchased_products'] as List<dynamic>? ?? [];
    final pm = p['payment_method'] as Map<String, dynamic>?;
    final addr = p['address'] as Map<String, dynamic>?;
    final totalPaid = p['total_paid_price'] ?? '0';
    final date = p['created_at']?.toString() ?? '';
    final status = _orderStatus(p);

    final pmName = pm?['name']?.toString() ?? '';
    final paymentName = pmName.isNotEmpty ? pmName : (p['payment_id'] != null ? 'Razorpay (Online)' : 'Cash on Delivery');

    return GestureDetector(
      onTap: () => _viewOrder(p),
      child: Container(
        margin: const EdgeInsets.only(bottom: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 4,
                    height: 40,
                    decoration: BoxDecoration(
                      color: _statusColor(status).withValues(alpha: 0.6),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Order #${p['id']}",
                          style: TextStyle(fontWeight: FontWeight.w800, fontSize: 15, color: cs.onSurface, letterSpacing: -0.3),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          _formatDate(date),
                          style: TextStyle(fontSize: 11, color: cs.onSurface.withValues(alpha: 0.4), fontWeight: FontWeight.w500),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  _StatusBadge(status: status),
                  const SizedBox(width: 6),
                  _TrackButton(onTap: () => _trackOrder(p)),
                ],
              ),
              const SizedBox(height: 14),
              ...products.take(2).map((pp) {
                final m = pp as Map<String, dynamic>;
                final prod = m['product'] as Map<String, dynamic>?;
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        color: cs.surfaceContainerHighest.withValues(alpha: 0.4),
                      ),
                      clipBehavior: Clip.antiAlias,
                      child: Image.network(
                        prod?['image_url']?.toString() ?? 'https://via.placeholder.com/48',
                        width: 48,
                        height: 48,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Icon(Icons.image, size: 22, color: cs.onSurface.withValues(alpha: 0.2)),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            prod?['name']?.toString() ?? 'Product',
                            style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: cs.onSurface),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            "Qty: ${m['quantity'] ?? 1}",
                            style: TextStyle(fontSize: 11, color: cs.onSurface.withValues(alpha: 0.4)),
                          ),
                        ],
                      ),
                    ),
                    Text(
                      "₹${m['paid_price']}",
                      style: TextStyle(fontWeight: FontWeight.w800, fontSize: 14, color: cs.onSurface),
                    ),
                  ]),
                );
              }),
              if (products.length > 2)
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Text(
                    "+${products.length - 2} more item(s)",
                    style: TextStyle(fontSize: 12, color: cs.primary, fontWeight: FontWeight.w600),
                  ),
                ),
              Divider(height: 4, color: cs.outlineVariant.withValues(alpha: 0.5)),
              Padding(
                padding: const EdgeInsets.only(top: 12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.payment, size: 14, color: cs.onSurface.withValues(alpha: 0.45)),
                        const SizedBox(width: 4),
                        Text(
                          paymentName,
                          style: TextStyle(fontSize: 11, color: cs.onSurface.withValues(alpha: 0.45)),
                        ),
                        if (addr != null) ...[
                          const SizedBox(width: 12),
                          Icon(Icons.location_on, size: 14, color: cs.onSurface.withValues(alpha: 0.45)),
                          const SizedBox(width: 4),
                          Text(
                            "${addr['city']}",
                            style: TextStyle(fontSize: 11, color: cs.onSurface.withValues(alpha: 0.45)),
                          ),
                        ],
                      ],
                    ),
                    Text(
                      "₹$totalPaid",
                      style: TextStyle(fontWeight: FontWeight.w900, fontSize: 18, color: cs.onSurface, letterSpacing: -0.3),
                    ),
                  ],
                ),
              ),
              if (p['transaction_id'] != null || p['payment_id'] != null) ...[
                const SizedBox(height: 6),
                Text(
                  'Ref: ${p['transaction_id']?.toString() ?? p['payment_id']?.toString() ?? ''}',
                  style: TextStyle(fontSize: 9, color: cs.onSurface.withValues(alpha: 0.3), fontFamily: 'monospace'),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Color _statusColor(String status) {
    switch (status.toLowerCase()) {
      case 'delivered':
        return Colors.green;
      case 'shipped':
      case 'in-transit':
      case 'out-for-delivery':
        return Colors.blue;
      case 'processing':
      case 'picked-up':
        return Colors.indigo;
      case 'cancelled':
      case 'canceled':
        return Colors.red;
      case 'refunded':
        return Colors.orange;
      default:
        return Colors.orange;
    }
  }

  String _formatDate(String date) {
    try {
      final dt = DateTime.parse(date);
      final months = ['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'];
      return "${dt.day} ${months[dt.month - 1]} ${dt.year}";
    } catch (_) {
      return date;
    }
  }
}

String _orderStatus(Map<String, dynamic> p) {
  return p['status']?.toString() ??
         p['order_status']?.toString() ??
         p['delivery_status']?.toString() ??
         'placed';
}

class _StatusBadge extends StatelessWidget {
  final String status;
  const _StatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    final s = status.toLowerCase();
    Color bg;
    Color fg;
    String label;

    switch (s) {
      case 'delivered':
        bg = Colors.green.shade100;
        fg = Colors.green.shade700;
        label = 'DELIVERED';
        break;
      case 'shipped':
      case 'in-transit':
      case 'out-for-delivery':
        bg = Colors.blue.shade100;
        fg = Colors.blue.shade700;
        label = s == 'out-for-delivery' ? 'OUT FOR DELIVERY' : s.toUpperCase();
        break;
      case 'processing':
      case 'picked-up':
        bg = Colors.indigo.shade100;
        fg = Colors.indigo;
        label = s == 'picked-up' ? 'PICKED UP' : 'PROCESSING';
        break;
      case 'cancelled':
      case 'canceled':
        bg = Colors.red.shade100;
        fg = Colors.red;
        label = 'CANCELLED';
        break;
      case 'refunded':
        bg = Colors.orange.shade100;
        fg = Colors.orange.shade800;
        label = 'REFUNDED';
        break;
      default:
        bg = Colors.orange.shade100;
        fg = Colors.orange;
        label = s.toUpperCase();
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(6)),
      child: Text(label, style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: fg)),
    );
  }
}

class _TrackButton extends StatelessWidget {
  final VoidCallback onTap;
  const _TrackButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(6),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        decoration: BoxDecoration(color: Colors.blue.shade100, borderRadius: BorderRadius.circular(6)),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          Icon(Icons.location_searching, size: 11, color: Colors.blue.shade700),
          const SizedBox(width: 3),
          Text("TRACK", style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: Colors.blue.shade700)),
        ]),
      ),
    );
  }
}
