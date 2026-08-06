import 'package:flutter/material.dart';
import '../services/mock_delivery_service.dart';
import '../utils/app_colors.dart';

class OrderTrackingScreen extends StatefulWidget {
  final String deliveryId;

  const OrderTrackingScreen({super.key, required this.deliveryId});

  @override
  State<OrderTrackingScreen> createState() => _OrderTrackingScreenState();
}

class _OrderTrackingScreenState extends State<OrderTrackingScreen> {
  MockDeliveryTracking? _tracking;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _isLoading = true);
    final t = await MockDeliveryService.trackDelivery(widget.deliveryId);
    if (mounted) setState(() { _tracking = t; _isLoading = false; });
  }

  static const _statusLabels = ['assigned', 'picked-up', 'in-transit', 'out-for-delivery', 'delivered'];
  static const _statusIcons = [
    Icons.person_outline,
    Icons.inventory_2_outlined,
    Icons.local_shipping_outlined,
    Icons.directions_walk_outlined,
    Icons.check_circle_outline,
  ];

  int _currentStepIndex() {
    if (_tracking == null) return 0;
    final idx = _statusLabels.indexOf(_tracking!.status);
    return idx >= 0 ? idx + 1 : 0;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.offWhite,
      appBar: AppBar(title: const Text("TRACK ORDER")),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _tracking == null
              ? const Center(child: Text("Tracking info not available"))
              : RefreshIndicator(
                  onRefresh: _load,
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildStatusCard(),
                        const SizedBox(height: 24),
                        _buildTimeline(),
                        const SizedBox(height: 24),
                        if (_tracking!.agentPhone != null) _buildAgentCard(),
                      ],
                    ),
                  ),
                ),
    );
  }

  Widget _buildStatusCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), border: Border.all(color: AppColors.softGrey)),
      child: Column(children: [
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Text("Delivery #${_tracking!.deliveryId}", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppColors.primaryDark)),
          _statusBadge(_tracking!.status),
        ]),
        const SizedBox(height: 12),
        if (_tracking!.estimatedDelivery != null) ...[
          Row(children: [
            Icon(Icons.calendar_today, size: 16, color: Colors.grey.shade600),
            const SizedBox(width: 8),
            Text("Estimated delivery: ${_tracking!.estimatedDelivery}", style: TextStyle(fontSize: 13, color: Colors.grey.shade600)),
          ]),
          const SizedBox(height: 6),
        ],
        if (_tracking!.currentLocation != null) ...[
          Row(children: [
            Icon(Icons.location_on, size: 16, color: Colors.grey.shade600),
            const SizedBox(width: 8),
            Expanded(child: Text("Current location: ${_tracking!.currentLocation}", style: TextStyle(fontSize: 13, color: Colors.grey.shade600))),
          ]),
        ],
      ]),
    );
  }

  Widget _buildTimeline() {
    final index = _currentStepIndex();
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), border: Border.all(color: AppColors.softGrey)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("STATUS UPDATE", style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1, color: Colors.grey)),
          const SizedBox(height: 16),
          ...List.generate(_statusLabels.length + 1, (i) {
            final isDone = i <= index;
            final isLast = i == _statusLabels.length;
            return _buildStep(
              icon: isLast ? Icons.check_circle : _statusIcons[i],
              label: isLast ? 'Delivered' : _statusLabels[i].replaceAll('-', ' ').toUpperCase(),
              isDone: isDone,
              isLast: isLast,
              showLine: !isLast,
            );
          }),
        ],
      ),
    );
  }

  Widget _buildStep({
    required IconData icon,
    required String label,
    required bool isDone,
    required bool isLast,
    bool showLine = true,
  }) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(children: [
            Container(
              width: 28, height: 28,
              decoration: BoxDecoration(
                color: isDone ? Colors.green : Colors.grey.shade300,
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 16, color: Colors.white),
            ),
            if (showLine)
              Container(width: 2, height: 30, color: isDone ? Colors.green.shade300 : Colors.grey.shade300),
          ]),
          const SizedBox(width: 14),
          Padding(
            padding: EdgeInsets.only(bottom: showLine ? 10 : 0),
            child: Text(label, style: TextStyle(
              fontSize: 13,
              fontWeight: isDone ? FontWeight.bold : FontWeight.normal,
              color: isDone ? Colors.green.shade700 : Colors.grey.shade500,
            )),
          ),
        ],
      ),
    );
  }

  Widget _buildAgentCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), border: Border.all(color: AppColors.softGrey)),
      child: Row(children: [
        Container(padding: const EdgeInsets.all(10), decoration: BoxDecoration(color: AppColors.softGrey, borderRadius: BorderRadius.circular(12)),
          child: const Icon(Icons.support_agent, color: AppColors.primaryDark, size: 24)),
        const SizedBox(width: 14),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text("Delivery Agent", style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1, color: Colors.grey)),
          const SizedBox(height: 4),
          Text(_tracking!.agentPhone!, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppColors.primaryDark)),
          Text("Call for delivery updates", style: TextStyle(fontSize: 12, color: Colors.grey.shade500)),
        ])),
      ]),
    );
  }

  Widget _statusBadge(String status) {
    Color c;
    switch (status) {
      case 'pending': c = Colors.orange; break;
      case 'assigned': c = Colors.blue; break;
      case 'picked-up': c = Colors.indigo; break;
      case 'in-transit': c = Colors.purple; break;
      case 'out-for-delivery': c = Colors.teal; break;
      case 'delivered': c = Colors.green; break;
      default: c = Colors.grey;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(color: c.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(20)),
      child: Text(status.replaceAll('-', ' ').toUpperCase(),
        style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: c, letterSpacing: 0.5)),
    );
  }
}
