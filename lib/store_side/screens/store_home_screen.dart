import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../utils/app_colors.dart';
import '../services/store_api_service.dart';
import 'category_detail_screen.dart';
import 'product_edit_screen.dart';
import 'order_detail_screen.dart';
import 'order_list_screen.dart';
import 'store_profile_screen.dart';
import 'inventory_screen.dart';
import 'delivery_partner_screen.dart';

class StoreHomeScreen extends StatefulWidget {
  const StoreHomeScreen({super.key});

  @override
  State<StoreHomeScreen> createState() => _StoreHomeScreenState();
}

class _StoreHomeScreenState extends State<StoreHomeScreen> {
  int _currentIndex = 0;

  void switchToTab(int index) {
    if (index >= 0 && index < _pages.length) {
      setState(() => _currentIndex = index);
    }
  }

  final List<Widget> _pages = [
    const StoreDashboard(),
    const OrderListScreen(),
    const ProductManagement(),
    const StoreProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.offWhite,
      body: _pages[_currentIndex],
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: AppColors.pureWhite,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 4,
              offset: const Offset(0, -1),
            ),
          ],
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildNavItem(0, Icons.dashboard_rounded, "Dash"),
                _buildNavItem(1, Icons.receipt_long_rounded, "Orders"),
                _buildNavItem(2, Icons.inventory_2_rounded, "Items"),
                _buildNavItem(3, Icons.store_rounded, "Shop"),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(int index, IconData icon, String label) {
    final isSelected = _currentIndex == index;
    return GestureDetector(
      onTap: () => setState(() => _currentIndex = index),
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: isSelected
                  ? AppColors.primaryBlue
                  : AppColors.primaryDark.withOpacity(0.4),
              size: 24,
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                color: isSelected
                    ? AppColors.primaryBlue
                    : AppColors.primaryDark.withOpacity(0.4),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// DASHBOARD
// ─────────────────────────────────────────────────────────────────────────────
class StoreDashboard extends StatefulWidget {
  const StoreDashboard({super.key});

  @override
  State<StoreDashboard> createState() => _StoreDashboardState();
}

class _StoreDashboardState extends State<StoreDashboard> {
  Map<String, dynamic> _stats = {};
  List<Map<String, dynamic>> _orders = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _isLoading = true);
    final shopId = StoreApiService.shopId;
    if (shopId == null || shopId <= 0) {
      if (mounted) setState(() => _isLoading = false);
      return;
    }
    final stats = await StoreApiService.getShopStats(shopId);
    final orders = await StoreApiService.getShopOrders(shopId);
    if (mounted) {
      setState(() {
        _stats = stats;
        _orders = orders
            .map((e) => e is Map<String, dynamic> ? e : <String, dynamic>{})
            .toList();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "WELCOME BACK,",
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.5,
                        color: AppColors.primaryDark.withOpacity(0.5),
                      ),
                    ),
                    Text(
                      _stats['shop_name']?.toString() ?? 'My Shop',
                      style: GoogleFonts.inter(
                        fontSize: 24,
                        fontWeight: FontWeight.w900,
                        color: AppColors.primaryDark,
                      ),
                    ),
                  ],
                ),
                CircleAvatar(
                  radius: 25,
                  backgroundColor: AppColors.primaryBlue.withOpacity(0.1),
                  backgroundImage: _stats['shop_image'] != null
                      ? NetworkImage(_stats['shop_image'].toString())
                      : null,
                  child: _stats['shop_image'] == null
                      ? const Icon(Icons.store, color: AppColors.primaryBlue)
                      : null,
                ),
              ],
            ),
            const SizedBox(height: 32),

            if (_isLoading)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(40),
                  child: CircularProgressIndicator(),
                ),
              )
            else ...[
              // Stats Row
              Row(
                children: [
                  _buildStatCard(
                    "Total Orders",
                    _stats['total_orders']?.toString() ?? '0',
                    Icons.shopping_bag,
                    Colors.blue,
                  ),
                  const SizedBox(width: 16),
                  _buildStatCard(
                    "Revenue",
                    _stats['total_revenue']?.toString() ?? '₹0',
                    Icons.payments,
                    Colors.green,
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  _buildStatCard(
                    "Active Items",
                    _stats['total_products']?.toString() ?? '0',
                    Icons.inventory,
                    Colors.orange,
                  ),
                  const SizedBox(width: 16),
                  _buildStatCard(
                    "Rating",
                    "${_stats['rating'] ?? '0'} ★",
                    Icons.star,
                    Colors.amber,
                  ),
                ],
              ),

              const SizedBox(height: 32),
              // Quick Actions
              Row(
                children: [
                  _buildQuickAction("Inventory", Icons.inventory_rounded, AppColors.primaryBlue, () {
                    Navigator.push(context, MaterialPageRoute(builder: (_) => const InventoryScreen()));
                  }),
                  const SizedBox(width: 16),
                  _buildQuickAction("Analytics", Icons.analytics_rounded, Colors.purple, () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Analytics coming soon!"), backgroundColor: Colors.purple),
                    );
                  }),
                  const SizedBox(width: 16),
                  _buildQuickAction("Delivery\nPartners", Icons.local_shipping_rounded, AppColors.successGreen, () {
                    Navigator.push(context, MaterialPageRoute(builder: (_) => const DeliveryPartnerScreen()));
                  }),
                ],
              ),
              const SizedBox(height: 32),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "RECENT ORDERS",
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1,
                      color: AppColors.primaryDark,
                    ),
                  ),
                  if (_orders.isNotEmpty)
                    GestureDetector(
                      onTap: () {
                        final homeState = context
                            .findAncestorStateOfType<_StoreHomeScreenState>();
                        homeState?.switchToTab(1);
                      },
                      child: Text(
                        "View All",
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.primaryBlue,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 16),
              if (_orders.isEmpty)
                Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 24),
                    child: Text(
                      "No orders yet",
                      style: TextStyle(
                        color: AppColors.primaryDark.withOpacity(0.4),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                )
              else
                ..._orders.take(5).map((o) => _buildRecentOrder(context, o)),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.softGrey),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 12),
            Text(
              value,
              style: GoogleFonts.inter(
                fontSize: 20,
                fontWeight: FontWeight.w900,
                color: AppColors.primaryDark,
              ),
            ),
            Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 11,
                color: AppColors.primaryDark.withOpacity(0.5),
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickAction(String label, IconData icon, Color color, VoidCallback onTap) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.softGrey),
          ),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: 24),
              ),
              const SizedBox(height: 8),
              Text(
                label,
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primaryDark,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRecentOrder(BuildContext context, Map<String, dynamic> order) {
    final id = order['id']?.toString() ?? '#0000';
    final itemName =
        order['product_name']?.toString() ??
        order['item']?.toString() ??
        'Order Item';
    final price =
        order['total_amount']?.toString() ??
        order['amount']?.toString() ??
        '₹0';
    final status = order['status']?.toString() ?? 'Pending';
    final statusColor =
        status.toLowerCase() == 'shipped' || status.toLowerCase() == 'delivered'
        ? Colors.green
        : status.toLowerCase() == 'cancelled'
        ? Colors.red
        : Colors.orange;

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) =>
                OrderDetailScreen(orderId: id, orderData: order),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.softGrey),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColors.softGrey,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.local_shipping_outlined,
                color: AppColors.primaryDark,
                size: 20,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    itemName,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                  Text(
                    "Order #$id",
                    style: TextStyle(
                      color: AppColors.primaryDark.withOpacity(0.5),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  price,
                  style: const TextStyle(
                    fontWeight: FontWeight.w900,
                    color: AppColors.primaryBlue,
                  ),
                ),
                Text(
                  status,
                  style: TextStyle(
                    color: statusColor,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
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

// ─────────────────────────────────────────────────────────────────────────────
// CATEGORY MANAGEMENT
// ─────────────────────────────────────────────────────────────────────────────
class CategoryManagement extends StatefulWidget {
  const CategoryManagement({super.key});

  @override
  State<CategoryManagement> createState() => _CategoryManagementState();
}

class _CategoryManagementState extends State<CategoryManagement> {
  List<Map<String, dynamic>> _categories = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _isLoading = true);
    try {
      final raw = await StoreApiService.getCategories();
      if (mounted) {
        setState(() {
          _categories = raw
              .map((e) => e is Map<String, dynamic> ? e : <String, dynamic>{})
              .toList();
          _isLoading = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "CATEGORIES",
              style: GoogleFonts.inter(
                fontSize: 24,
                fontWeight: FontWeight.w900,
                color: AppColors.primaryDark,
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _categories.isEmpty
                  ? Center(
                      child: Text(
                        "No categories found",
                        style: TextStyle(
                          color: AppColors.primaryDark.withOpacity(0.4),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    )
                  : RefreshIndicator(
                      onRefresh: _load,
                      child: ListView.builder(
                        itemCount: _categories.length,
                        itemBuilder: (context, index) {
                          final c = _categories[index];
                          final name =
                              c['category_name']?.toString() ??
                              c['name']?.toString() ??
                              'Category';
                          final id = c['id']?.toString() ?? '0';
                          final image = c['image']?.toString();
                          return _buildCategoryItem(context, name, id, image);
                        },
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryItem(
    BuildContext context,
    String name,
    String id,
    String? image,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.softGrey),
      ),
      child: Material(
        color: Colors.transparent,
        child: ListTile(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) =>
                    CategoryDetailScreen(categoryId: id, categoryName: name),
              ),
            );
          },
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          contentPadding: const EdgeInsets.all(12),
          leading: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: image != null && image.isNotEmpty
                ? Image.network(
                    image,
                    width: 60,
                    height: 60,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      width: 60,
                      height: 60,
                      color: AppColors.softGrey,
                      child: const Icon(Icons.category, color: Colors.grey),
                    ),
                  )
                : Container(
                    width: 60,
                    height: 60,
                    color: AppColors.softGrey,
                    child: const Icon(Icons.category, color: Colors.grey),
                  ),
          ),
          title: Text(
            name,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          subtitle: Text("ID: $id", style: const TextStyle(fontSize: 12)),
          trailing: const Icon(Icons.chevron_right),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// PRODUCT MANAGEMENT
// ─────────────────────────────────────────────────────────────────────────────
class ProductManagement extends StatefulWidget {
  const ProductManagement({super.key});

  @override
  State<ProductManagement> createState() => _ProductManagementState();
}

class _ProductManagementState extends State<ProductManagement> {
  List<Map<String, dynamic>> _products = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadProducts();
  }

  Future<void> _loadProducts() async {
    setState(() => _isLoading = true);
    try {
      final shopId = StoreApiService.shopId;
      if (shopId == null || shopId <= 0) {
        if (mounted)
          setState(() {
            _products = [];
            _isLoading = false;
          });
        return;
      }
      final raw = await StoreApiService.getShopProducts(shopId);
      if (mounted) {
        setState(() {
          _products = raw
              .map((e) => e is Map<String, dynamic> ? e : <String, dynamic>{})
              .toList();
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted)
        setState(() {
          _error = e.toString();
          _isLoading = false;
        });
    }
  }

  Future<void> _deleteProduct(int index) async {
    final p = _products[index];
    final id = p['id']?.toString();
    if (id == null) return;
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text("Delete Product"),
        content: Text("Remove \"${p['name'] ?? 'this product'}\"?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text("CANCEL"),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text(
              "DELETE",
              style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
    if (confirm == true) {
      final deleted = await StoreApiService.deleteProduct(int.parse(id));
      if (deleted) _loadProducts();
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "INVENTORY",
                  style: GoogleFonts.inter(
                    fontSize: 24,
                    fontWeight: FontWeight.w900,
                    color: AppColors.primaryDark,
                  ),
                ),
                Row(
                  children: [
                    IconButton(
                      onPressed: _loadProducts,
                      icon: const Icon(
                        Icons.refresh,
                        color: AppColors.primaryDark,
                        size: 24,
                      ),
                    ),
                    IconButton(
                      onPressed: () async {
                        final result = await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const ProductEditScreen(),
                          ),
                        );
                        if (result == true) _loadProducts();
                      },
                      icon: const Icon(
                        Icons.add_circle,
                        color: AppColors.primaryBlue,
                        size: 32,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 20),
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _error != null
                  ? Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.error_outline,
                            color: Colors.red,
                            size: 40,
                          ),
                          const SizedBox(height: 12),
                          const Text("Failed to load products"),
                          const SizedBox(height: 8),
                          ElevatedButton(
                            onPressed: _loadProducts,
                            child: const Text("Retry"),
                          ),
                        ],
                      ),
                    )
                  : _products.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.inventory_2_outlined,
                            size: 60,
                            color: AppColors.primaryDark.withValues(
                              alpha: 0.15,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            "No products yet",
                            style: TextStyle(
                              color: AppColors.primaryDark.withValues(
                                alpha: 0.5,
                              ),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          ElevatedButton(
                            onPressed: () async {
                              final result = await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      const ProductEditScreen(),
                                ),
                              );
                              if (result == true) _loadProducts();
                            },
                            child: const Text("Add First Product"),
                          ),
                        ],
                      ),
                    )
                  : RefreshIndicator(
                      onRefresh: _loadProducts,
                      child: ListView.builder(
                        itemCount: _products.length,
                        itemBuilder: (context, index) {
                          final p = _products[index];
                          return _buildProductItem(
                            context,
                            index: index,
                            product: p,
                            name: p['name']?.toString() ?? 'Unknown',
                            price: p['price']?.toString() ?? '0',
                            discountPrice: p['discount_price']?.toString(),
                            stock: p['quantity']?.toString() ?? '0',
                            image: p['image']?.toString(),
                            images: p['images'] is List
                                ? (p['images'] as List)
                                      .map((e) => e.toString())
                                      .toList()
                                : null,
                            material: p['material']?.toString(),
                            color: p['color']?.toString(),
                            size: p['size']?.toString(),
                            onTap: () async {
                              final result = await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => ProductEditScreen(product: p),
                                ),
                              );
                              if (result == true) _loadProducts();
                            },
                          );
                        },
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProductItem(
    BuildContext context, {
    required int index,
    required Map<String, dynamic> product,
    required String name,
    required String price,
    String? discountPrice,
    required String stock,
    String? image,
    List<String>? images,
    String? material,
    String? color,
    String? size,
    VoidCallback? onTap,
  }) {
    final hasDiscount =
        discountPrice != null &&
        discountPrice.isNotEmpty &&
        double.tryParse(discountPrice)! > 0 &&
        double.tryParse(discountPrice)! < double.tryParse(price)!;
    final showPrice = hasDiscount ? discountPrice! : price;
    final displayImage = images != null && images.isNotEmpty
        ? images.first
        : image;

    return Dismissible(
      key: ValueKey('product_${_products[index]['id'] ?? index}'),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 24),
        decoration: BoxDecoration(
          color: Colors.red.shade50,
          borderRadius: BorderRadius.circular(20),
        ),
        child: const Icon(Icons.delete_outline, color: Colors.red),
      ),
      confirmDismiss: (_) async {
        await _deleteProduct(index);
        return false;
      },
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          margin: const EdgeInsets.only(bottom: 16),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppColors.softGrey),
          ),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: displayImage != null && displayImage.isNotEmpty
                    ? Image.network(
                        displayImage,
                        width: 80,
                        height: 100,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Container(
                          width: 80,
                          height: 100,
                          color: Colors.grey[200],
                          child: const Icon(
                            Icons.image_not_supported_outlined,
                            color: Colors.grey,
                          ),
                        ),
                      )
                    : Container(
                        width: 80,
                        height: 100,
                        color: Colors.grey[200],
                        child: const Icon(
                          Icons.inventory_2_outlined,
                          color: Colors.grey,
                        ),
                      ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        Text(
                          "₹${double.tryParse(showPrice)?.round() ?? showPrice}",
                          style: const TextStyle(
                            color: AppColors.primaryBlue,
                            fontWeight: FontWeight.w900,
                            fontSize: 15,
                          ),
                        ),
                        if (hasDiscount) ...[
                          const SizedBox(width: 6),
                          Text(
                            "₹${double.tryParse(price)?.round() ?? price}",
                            style: TextStyle(
                              color: AppColors.primaryDark.withValues(
                                alpha: 0.4,
                              ),
                              fontSize: 12,
                              decoration: TextDecoration.lineThrough,
                            ),
                          ),
                        ],
                      ],
                    ),
                    if (material != null || color != null || size != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        [
                          material,
                          color,
                          size,
                        ].where((s) => s != null && s.isNotEmpty).join(' | '),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: AppColors.primaryDark.withValues(alpha: 0.5),
                          fontSize: 11,
                        ),
                      ),
                    ],
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color:
                            int.tryParse(stock) != null && int.parse(stock) > 10
                            ? AppColors.successGreen.withValues(alpha: 0.1)
                            : AppColors.sunsetOrange.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        "$stock in stock",
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color:
                              int.tryParse(stock) != null &&
                                  int.parse(stock) > 10
                              ? AppColors.successGreen
                              : AppColors.sunsetOrange,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right, color: Colors.grey),
            ],
          ),
        ),
      ),
    );
  }
}
