import 'package:flutter/material.dart';
import '../../utils/app_colors.dart';
import '../services/store_api_service.dart';
import '../services/shiprocket_service.dart';

class OrderDetailScreen extends StatefulWidget {
  final String orderId;
  final Map<String, dynamic>? orderData;

  const OrderDetailScreen({super.key, required this.orderId, this.orderData});

  @override
  State<OrderDetailScreen> createState() => _OrderDetailScreenState();
}

class _OrderDetailScreenState extends State<OrderDetailScreen> {
  Map<String, dynamic> _order = {};
  bool _isLoading = true;
  bool _actionLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.orderData != null && widget.orderData!.isNotEmpty) {
      _order = widget.orderData!;
      _isLoading = false;
    } else {
      _load();
    }
  }

  Future<void> _load() async {
    final id = int.tryParse(widget.orderId);
    if (id == null) {
      if (mounted) setState(() => _isLoading = false);
      return;
    }
    final data = await StoreApiService.getOrderDetails(id);
    if (mounted) {
      setState(() {
        _order = data;
        _isLoading = false;
      });
    }
  }

  String get _status => _order['status']?.toString() ?? 'pending';

  Future<void> _acceptOrder() async {
    setState(() => _actionLoading = true);
    final id = int.tryParse(widget.orderId);
    if (id != null) {
      final ok = await StoreApiService.acceptOrder(id);
      if (ok) _load();
    }
    if (mounted) setState(() => _actionLoading = false);
  }

  Future<void> _rejectOrder() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text("Reject Order"),
        content: Text("Reject order #${widget.orderId}?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text("CANCEL")),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text("REJECT", style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
    if (confirm != true) return;
    setState(() => _actionLoading = true);
    final id = int.tryParse(widget.orderId);
    if (id != null) {
      final ok = await StoreApiService.rejectOrder(id);
      if (ok) _load();
    }
    if (mounted) setState(() => _actionLoading = false);
  }

  Future<void> _markShipped() async {
    setState(() => _actionLoading = true);
    final id = int.tryParse(widget.orderId);
    if (id != null) {
      final ok = await StoreApiService.updateOrderStatus(id, 'shipped');
      if (ok) _load();
    }
    if (mounted) setState(() => _actionLoading = false);
  }

  Future<void> _markDelivered() async {
    setState(() => _actionLoading = true);
    final id = int.tryParse(widget.orderId);
    if (id != null) {
      final ok = await StoreApiService.updateOrderStatus(id, 'delivered');
      if (ok) _load();
    }
    if (mounted) setState(() => _actionLoading = false);
  }

  Future<void> _assignDelivery() async {
    final partners = await StoreApiService.getDeliveryPartners();
    if (!mounted) return;

    if (partners.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("No delivery partners available"), backgroundColor: Colors.orange),
      );
      return;
    }

    final partner = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (ctx) => SimpleDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text("Select Delivery Partner"),
        children: partners.map((p) {
          final m = p as Map<String, dynamic>;
          final name = m['name']?.toString() ?? 'Partner';
          final id = m['id'];
          return SimpleDialogOption(
            onPressed: () => Navigator.pop(ctx, m),
            child: ListTile(
              leading: CircleAvatar(child: Icon(Icons.local_shipping, color: AppColors.primaryDark)),
              title: Text(name, style: const TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Text(m['phone']?.toString() ?? ''),
            ),
          );
        }).toList(),
      ),
    );

    if (partner == null) return;
    setState(() => _actionLoading = true);
    final orderId = int.tryParse(widget.orderId);
    final partnerId = int.tryParse(partner['id'].toString());
    if (orderId != null && partnerId != null) {
      final ok = await StoreApiService.assignDeliveryPartner(orderId, partnerId);
      if (ok) _load();
    }
    if (mounted) setState(() => _actionLoading = false);
  }

  Future<void> _addTracking() async {
    final controller = TextEditingController();
    final courierCtrl = TextEditingController();
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text("Add Tracking Info"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: courierCtrl,
              decoration: const InputDecoration(
                labelText: "Courier / Carrier Name",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: controller,
              decoration: const InputDecoration(
                labelText: "Tracking Number",
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text("CANCEL")),
          TextButton(
            onPressed: () {
              if (controller.text.trim().isEmpty) return;
              Navigator.pop(ctx, true);
            },
            child: const Text("SAVE", style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
    if (ok != true) return;
    setState(() => _actionLoading = true);
    final orderId = int.tryParse(widget.orderId);
    if (orderId != null) {
      final result = await StoreApiService.addTrackingInfo(
        orderId,
        courierCtrl.text.trim().isNotEmpty ? courierCtrl.text.trim() : 'Courier',
        controller.text.trim(),
      );
      if (result) _load();
    }
    if (mounted) setState(() => _actionLoading = false);
  }

  Future<void> _shipViaShiprocket() async {
    final shop = await StoreApiService.getShopDetails(StoreApiService.shopId ?? 0);
    final shopData = shop['shop'] ?? shop['data'] ?? {};
    final deliveryZip = _order['shipping_address']?.toString().split(',').last.trim() ?? '560001';

    final couriers = await ShiprocketService.getAvailableCouriers(deliveryZip);
    if (!mounted) return;

    Map<String, dynamic>? selectedCourier;
    if (couriers.isNotEmpty) {
      selectedCourier = await showDialog<Map<String, dynamic>>(
        context: context,
        builder: (ctx) => SimpleDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Text("Select Courier"),
          children: couriers.map((c) => SimpleDialogOption(
            onPressed: () => Navigator.pop(ctx, c),
            child: ListTile(
              leading: const Icon(Icons.local_shipping, color: AppColors.primaryDark),
              title: Text(c['name'].toString(), style: const TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Text("₹${c['rate']} · ${c['etd']} · ★${c['rating']}"),
            ),
          )).toList(),
        ),
      );
      if (selectedCourier == null) return;
    }

    setState(() => _actionLoading = true);

    try {
      final result = await ShiprocketService.createShipment(
        orderId: int.parse(widget.orderId),
        orderNumber: widget.orderId,
        pickupName: shopData['name']?.toString() ?? 'Fashion Hub',
        pickupAddress: shopData['address']?.toString() ?? 'MG Road',
        pickupCity: shopData['city']?.toString() ?? 'Bengaluru',
        pickupState: shopData['state']?.toString() ?? 'Karnataka',
        pickupZip: shopData['zip']?.toString() ?? '560038',
        pickupPhone: shopData['phone']?.toString() ?? '9876543210',
        deliveryName: _order['customer_name']?.toString() ?? 'Customer',
        deliveryAddress: _order['shipping_address']?.toString() ?? '',
        deliveryCity: 'Bengaluru',
        deliveryState: 'Karnataka',
        deliveryZip: deliveryZip,
        deliveryPhone: _order['customer_phone']?.toString() ?? '',
        weight: 0.5,
        courierId: selectedCourier?['id'] ?? 1,
        orderAmount: double.tryParse(_order['total_amount']?.toString() ?? '0') ?? 0,
        orderItems: [],
      );

      if (mounted) {
        await showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            title: Row(
              children: [
                const Icon(Icons.check_circle, color: Colors.green),
                const SizedBox(width: 8),
                const Expanded(child: Text("Shipment Created")),
              ],
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _shipmentRow("Courier", result['courier_name'].toString()),
                const SizedBox(height: 8),
                _shipmentRow("AWB", result['awb'].toString()),
                if (result['label_url'] != null) ...[
                  const SizedBox(height: 8),
                  _shipmentRow("Label", result['label_url'].toString()),
                ],
                const SizedBox(height: 12),
                Text("Order marked as Shipped ✓", style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () { Navigator.pop(ctx); _load(); },
                child: const Text("OK", style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Shipment failed: $e"), backgroundColor: Colors.red),
        );
      }
    }

    if (mounted) setState(() => _actionLoading = false);
  }

  Widget _shipmentRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("$label: ", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
        Expanded(child: Text(value, style: TextStyle(fontSize: 13, color: Colors.grey.shade700))),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.offWhite,
      appBar: AppBar(
        title: Text("ORDER #${widget.orderId}"),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildStatusHeader(),
                  const SizedBox(height: 24),
                  _buildSectionTitle("ORDER TIMELINE"),
                  const SizedBox(height: 16),
                  _buildTimeline(),
                  const SizedBox(height: 32),
                  _buildSectionTitle("CUSTOMER DETAILS"),
                  const SizedBox(height: 16),
                  _buildCustomerInfo(),
                  const SizedBox(height: 32),
                  _buildSectionTitle("ORDERED ITEMS"),
                  const SizedBox(height: 16),
                  _buildOrderItems(),
                  if (_order['total_amount'] != null || _order['subtotal'] != null) ...[
                    const SizedBox(height: 32),
                    _buildSectionTitle("PAYMENT SUMMARY"),
                    const SizedBox(height: 16),
                    _buildPaymentSummary(),
                  ],
                  const SizedBox(height: 32),
                  _buildActions(),
                  const SizedBox(height: 40),
                ],
              ),
            ),
    );
  }

  Widget _buildActions() {
    final s = _status.toLowerCase();

    if (_actionLoading) {
      return const Center(child: Padding(
        padding: EdgeInsets.all(16),
        child: CircularProgressIndicator(),
      ));
    }

    final List<Widget> buttons = [];

    if (s == 'pending') {
      buttons.addAll([
        SizedBox(width: double.infinity, height: 50,
          child: ElevatedButton.icon(
            onPressed: _acceptOrder,
            icon: const Icon(Icons.check_circle_outline),
            label: const Text("ACCEPT ORDER", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            ),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(width: double.infinity, height: 50,
          child: OutlinedButton.icon(
            onPressed: _rejectOrder,
            icon: const Icon(Icons.cancel_outlined),
            label: const Text("REJECT ORDER", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.red,
              side: const BorderSide(color: Colors.red),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            ),
          ),
        ),
      ]);
    }

    if (s == 'accepted') {
      buttons.addAll([
        SizedBox(width: double.infinity, height: 50,
          child: ElevatedButton.icon(
            onPressed: _shipViaShiprocket,
            icon: const Icon(Icons.rocket_launch),
            label: const Text("SHIP VIA SHIPROCKET", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFE53935),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            ),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(width: double.infinity, height: 50,
          child: OutlinedButton.icon(
            onPressed: _assignDelivery,
            icon: const Icon(Icons.local_shipping),
            label: const Text("ASSIGN DELIVERY PARTNER", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.primaryDark,
              side: const BorderSide(color: AppColors.primaryDark),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            ),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(width: double.infinity, height: 50,
          child: OutlinedButton.icon(
            onPressed: _markShipped,
            icon: const Icon(Icons.check),
            label: const Text("MARK AS SHIPPED (MANUAL)", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.blue,
              side: const BorderSide(color: Colors.blue),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            ),
          ),
        ),
      ]);
    }

    if (s == 'shipped') {
      buttons.addAll([
        SizedBox(width: double.infinity, height: 50,
          child: ElevatedButton.icon(
            onPressed: _addTracking,
            icon: const Icon(Icons.track_changes),
            label: const Text("ADD TRACKING INFO", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.indigo,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            ),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(width: double.infinity, height: 50,
          child: OutlinedButton.icon(
            onPressed: _markDelivered,
            icon: const Icon(Icons.check_circle),
            label: const Text("MARK AS DELIVERED", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.green,
              side: const BorderSide(color: Colors.green),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            ),
          ),
        ),
      ]);
    }

    if (s == 'delivered') {
      buttons.add(
        Container(
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
          decoration: BoxDecoration(
            color: Colors.green.shade50,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: Colors.green.shade200),
          ),
          child: const Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            Icon(Icons.check_circle, color: Colors.green),
            SizedBox(width: 8),
            Text("DELIVERED", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.green, fontSize: 16)),
          ]),
        ),
      );
    }

    if (s == 'cancelled' || s == 'rejected') {
      buttons.add(
        Container(
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
          decoration: BoxDecoration(
            color: Colors.red.shade50,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: Colors.red.shade200),
          ),
          child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            Icon(Icons.cancel, color: Colors.red.shade700),
            const SizedBox(width: 8),
            Text(s.toUpperCase(), style: TextStyle(fontWeight: FontWeight.bold, color: Colors.red.shade700, fontSize: 16)),
          ]),
        ),
      );
    }

    return Column(children: buttons);
  }

  Widget _buildStatusHeader() {
    final status = _status;
    final statusColor = status.toLowerCase() == 'shipped' || status.toLowerCase() == 'delivered'
        ? Colors.green : status.toLowerCase() == 'cancelled' || status.toLowerCase() == 'rejected'
            ? Colors.red : Colors.orange;
    final statusIcon = status.toLowerCase() == 'shipped' || status.toLowerCase() == 'delivered'
        ? Icons.check_circle : status.toLowerCase() == 'cancelled' || status.toLowerCase() == 'rejected'
            ? Icons.cancel : Icons.access_time_filled_rounded;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: statusColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: statusColor.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          Icon(statusIcon, color: statusColor),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(status, style: TextStyle(fontWeight: FontWeight.bold, color: statusColor, fontSize: 16)),
                Text("Order #${widget.orderId}",
                  style: TextStyle(fontSize: 12, color: statusColor.withOpacity(0.7)),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          if (_order['delivery_partner'] != null) ...[
            const SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text("Delivery Partner", style: TextStyle(fontSize: 9, color: statusColor.withOpacity(0.5))),
                Text(_order['delivery_partner']?['name']?.toString() ?? '', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
              ],
            ),
          ],
          if (_order['tracking_number'] != null) ...[
            const SizedBox(height: 4),
            Text("Tracking: ${_order['tracking_number']}", style: TextStyle(fontSize: 9, color: statusColor.withOpacity(0.6))),
          ],
        ],
      ),
    );
  }

  Widget _buildTimeline() {
    final timeline = _order['timeline'] as List<dynamic>? ?? [];
    if (timeline.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.softGrey),
        ),
        child: Center(
          child: Text("No timeline available", style: TextStyle(color: Colors.grey.shade500, fontSize: 13)),
        ),
      );
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.softGrey),
      ),
      child: Column(
        children: List.generate(timeline.length, (i) {
          final entry = timeline[i] as Map<String, dynamic>;
          final status = entry['status']?.toString() ?? '';
          final time = entry['time']?.toString() ?? '';
          final note = entry['note']?.toString() ?? '';
          final isLast = i == timeline.length - 1;
          final color = status == 'delivered' || status == 'shipped'
              ? Colors.green
              : status == 'rejected' || status == 'cancelled'
                  ? Colors.red
                  : AppColors.primaryBlue;

          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                children: [
                  Container(
                    width: 20, height: 20,
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.15),
                      shape: BoxShape.circle,
                      border: Border.all(color: color, width: 2),
                    ),
                    child: Center(child: Icon(
                      status == 'delivered' || status == 'shipped'
                          ? Icons.check
                          : status == 'rejected' || status == 'cancelled'
                              ? Icons.close
                              : Icons.circle,
                      size: 8, color: color,
                    )),
                  ),
                  if (!isLast)
                    Container(width: 2, height: 40, color: color.withOpacity(0.3)),
                ],
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Padding(
                  padding: EdgeInsets.only(bottom: isLast ? 0 : 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(status.toUpperCase(), style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: color)),
                      if (time.isNotEmpty)
                        Text(_formatDate(time), style: TextStyle(fontSize: 10, color: Colors.grey.shade500)),
                      if (note.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(top: 2),
                          child: Text(note, style: TextStyle(fontSize: 11, color: Colors.grey.shade600)),
                        ),
                    ],
                  ),
                ),
              ),
            ],
          );
        }),
      ),
    );
  }

  Widget _buildCustomerInfo() {
    final name = _order['customer_name']?.toString() ??
        _order['user']?['name']?.toString() ??
        _order['name']?.toString() ??
        'Customer';
    final address = _order['shipping_address']?.toString() ??
        _order['address']?.toString() ??
        _order['customer_address']?.toString() ??
        'Address not available';
    final phone = _order['customer_phone']?.toString() ??
        _order['phone']?.toString() ??
        _order['user']?['phone']?.toString();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.softGrey),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            const Icon(Icons.person, size: 18, color: AppColors.primaryDark),
            const SizedBox(width: 8),
            Expanded(child: Text(name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16))),
          ]),
          if (phone != null) ...[
            const SizedBox(height: 12),
            Row(children: [
              const Icon(Icons.phone, size: 16, color: Colors.grey),
              const SizedBox(width: 8),
              Text(phone, style: const TextStyle(color: Colors.grey, fontSize: 14)),
              const Spacer(),
              _contactButton(Icons.call, "Call", () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text("Calling $phone..."), duration: const Duration(seconds: 2)),
                );
              }),
              const SizedBox(width: 8),
              _contactButton(Icons.message_outlined, "Message", () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text("Messaging $phone..."), duration: const Duration(seconds: 2)),
                );
              }),
            ]),
          ],
          const SizedBox(height: 12),
          Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Icon(Icons.location_on_outlined, size: 16, color: Colors.grey),
            const SizedBox(width: 8),
            Expanded(child: Text(address, style: const TextStyle(color: Colors.grey, fontSize: 14))),
          ]),
        ],
      ),
    );
  }

  Widget _contactButton(IconData icon, String label, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: AppColors.primaryBlue.withOpacity(0.1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 14, color: AppColors.primaryBlue),
            const SizedBox(width: 4),
            Text(label, style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.primaryBlue)),
          ],
        ),
      ),
    );
  }

  Widget _buildOrderItems() {
    final items = _order['items'] as List<dynamic>? ?? [];
    if (items.isEmpty) {
      final productName = _order['product_name']?.toString() ?? _order['item']?.toString();
      if (productName != null) {
        return _buildOrderItemCard(
          name: productName,
          variant: _order['variant']?.toString(),
          price: _order['total_amount']?.toString() ?? _order['price']?.toString() ?? '₹0',
          image: _order['product_image']?.toString() ?? _order['image']?.toString(),
        );
      }
      return Center(child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 24),
        child: Text("No items", style: TextStyle(color: AppColors.primaryDark.withOpacity(0.4))),
      ));
    }
    return Column(
      children: items.map((item) {
        final i = item as Map<String, dynamic>;
        return _buildOrderItemCard(
          name: i['name']?.toString() ?? i['product_name']?.toString() ?? 'Item',
          variant: i['variant']?.toString() ?? i['size']?.toString(),
          price: i['price']?.toString() ?? i['total']?.toString() ?? '₹0',
          image: i['image']?.toString(),
        );
      }).toList(),
    );
  }

  Widget _buildOrderItemCard({
    required String name,
    String? variant,
    required String price,
    String? image,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.softGrey),
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: image != null && image.isNotEmpty
                ? Image.network(image, width: 60, height: 75, fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      width: 60, height: 75, color: AppColors.softGrey,
                      child: const Icon(Icons.image, color: Colors.grey),
                    ),
                  )
                : Container(
                    width: 60, height: 75, color: AppColors.softGrey,
                    child: const Icon(Icons.image, color: Colors.grey),
                  ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: const TextStyle(fontWeight: FontWeight.bold)),
                if (variant != null) Text(variant, style: const TextStyle(fontSize: 12, color: Colors.grey)),
                const SizedBox(height: 4),
                Text(price, style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.primaryBlue)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentSummary() {
    final subtotal = _order['subtotal']?.toString() ?? _order['total_amount']?.toString() ?? '₹0';
    final shipping = _order['shipping_charge']?.toString() ?? _order['shipping']?.toString();
    final discount = _order['discount']?.toString();
    final total = _order['total_amount']?.toString() ?? _order['grand_total']?.toString() ?? subtotal;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.softGrey),
      ),
      child: Column(
        children: [
          _buildPriceRow("Item Total", subtotal),
          if (shipping != null) _buildPriceRow("Shipping", shipping),
          if (discount != null) _buildPriceRow("Discount", "-$discount"),
          const Divider(height: 24),
          _buildPriceRow("Total", total, isBold: true),
        ],
      ),
    );
  }

  Widget _buildPriceRow(String label, String value, {bool isBold = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(fontWeight: isBold ? FontWeight.bold : FontWeight.normal)),
          Text(value, style: TextStyle(fontWeight: isBold ? FontWeight.w900 : FontWeight.bold, fontSize: isBold ? 18 : 14)),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.bold,
        letterSpacing: 1.5,
        color: AppColors.primaryDark.withOpacity(0.5),
      ),
    );
  }

  String _formatDate(String date) {
    try {
      final dt = DateTime.parse(date);
      final months = ['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'];
      return "${dt.day} ${months[dt.month - 1]} ${dt.year}, ${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}";
    } catch (_) {
      return date;
    }
  }
}
