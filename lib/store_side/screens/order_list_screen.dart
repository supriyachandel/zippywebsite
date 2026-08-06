import 'package:flutter/material.dart';
import '../../utils/app_colors.dart';
import '../services/store_api_service.dart';
import 'order_detail_screen.dart';

class OrderListScreen extends StatefulWidget {
  const OrderListScreen({super.key});

  @override
  State<OrderListScreen> createState() => _OrderListScreenState();
}

class _OrderListScreenState extends State<OrderListScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<Map<String, dynamic>> _allOrders = [];
  bool _isLoading = true;

  static const _tabs = ['All', 'Pending', 'Accepted', 'Shipped', 'Delivered', 'Cancelled'];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _tabs.length, vsync: this);
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) setState(() {});
    });
    _load();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    final shopId = StoreApiService.shopId;
    if (shopId == null || shopId <= 0) {
      if (mounted) setState(() => _isLoading = false);
      return;
    }
    setState(() => _isLoading = true);
    try {
      final raw = await StoreApiService.getShopOrders(shopId);
      if (mounted) {
        setState(() {
          _allOrders = raw.map((e) => e is Map<String, dynamic> ? e : <String, dynamic>{}).toList();
          _isLoading = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  List<Map<String, dynamic>> get _filteredOrders {
    final tab = _tabs[_tabController.index];
    if (tab == 'All') return _allOrders;
    return _allOrders.where((o) {
      final status = (o['status']?.toString() ?? '').toLowerCase();
      return status == tab.toLowerCase();
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "ORDERS",
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w900,
                    color: AppColors.primaryDark,
                  ),
                ),
                IconButton(
                  onPressed: _load,
                  icon: const Icon(Icons.refresh, color: AppColors.primaryDark),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          TabBar(
            controller: _tabController,
            isScrollable: true,
            tabAlignment: TabAlignment.start,
            labelColor: Colors.white,
            unselectedLabelColor: AppColors.primaryDark.withValues(alpha: 0.5),
            indicator: BoxDecoration(
              color: AppColors.primaryDark,
              borderRadius: BorderRadius.circular(20),
            ),
            indicatorSize: TabBarIndicatorSize.tab,
            labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
            unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.normal, fontSize: 12),
            padding: const EdgeInsets.symmetric(horizontal: 16),
            dividerColor: Colors.transparent,
            tabs: _tabs.map((t) => Tab(text: t)).toList(),
          ),
          const SizedBox(height: 12),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _filteredOrders.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.receipt_long_outlined, size: 60, color: Colors.grey.shade300),
                            const SizedBox(height: 16),
                            Text("No ${_tabs[_tabController.index].toLowerCase()} orders",
                              style: TextStyle(color: Colors.grey.shade500, fontSize: 15, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      )
                    : RefreshIndicator(
                        onRefresh: _load,
                        child: ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          itemCount: _filteredOrders.length,
                          itemBuilder: (context, i) => _buildOrderCard(_filteredOrders[i]),
                        ),
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderCard(Map<String, dynamic> order) {
    final id = order['id']?.toString() ?? '#0000';
    final itemName = order['product_name']?.toString() ?? order['item']?.toString() ?? 'Order Item';
    final price = order['total_amount']?.toString() ?? order['amount']?.toString() ?? '₹0';
    final status = order['status']?.toString() ?? 'Pending';
    final date = order['created_at']?.toString() ?? '';
    final customerName = order['customer_name']?.toString() ?? order['user']?['name']?.toString() ?? 'Customer';
    final statusColor = status.toLowerCase() == 'shipped' || status.toLowerCase() == 'delivered'
        ? Colors.green : status.toLowerCase() == 'cancelled' ? Colors.red : Colors.orange;

    return GestureDetector(
      onTap: () async {
        await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => OrderDetailScreen(orderId: id, orderData: order),
          ),
        );
        _load();
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.softGrey),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("Order #$id", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                Text(status, style: TextStyle(color: statusColor, fontSize: 12, fontWeight: FontWeight.bold)),
              ],
            ),
            if (date.isNotEmpty) ...[
              const SizedBox(height: 2),
              Text(_formatDate(date), style: TextStyle(fontSize: 11, color: Colors.grey.shade500)),
            ],
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.person_outline, size: 14, color: Colors.grey),
                const SizedBox(width: 4),
                Text(customerName, style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
                const Spacer(),
                Text(price, style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.primaryBlue)),
              ],
            ),
          ],
        ),
      ),
    );
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
