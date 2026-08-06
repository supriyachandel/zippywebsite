import 'package:flutter/material.dart';
import '../../utils/app_colors.dart';
import '../services/store_api_service.dart';

class InventoryScreen extends StatefulWidget {
  const InventoryScreen({super.key});

  @override
  State<InventoryScreen> createState() => _InventoryScreenState();
}

class _InventoryScreenState extends State<InventoryScreen> {
  List<Map<String, dynamic>> _allProducts = [];
  bool _isLoading = true;
  String _searchQuery = '';
  String _stockFilter = 'All';
  final _searchController = TextEditingController();

  static const _filters = ['All', 'In Stock', 'Low Stock', 'Out of Stock'];

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() => _isLoading = true);
    final shopId = StoreApiService.shopId;
    if (shopId == null || shopId <= 0) {
      if (mounted) setState(() => _isLoading = false);
      return;
    }
    try {
      final raw = await StoreApiService.getShopProducts(shopId);
      if (mounted) {
        setState(() {
          _allProducts = raw.map((e) => e is Map<String, dynamic> ? e : <String, dynamic>{}).toList();
          _isLoading = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  List<Map<String, dynamic>> get _filteredProducts {
    var list = _allProducts;
    if (_searchQuery.isNotEmpty) {
      final q = _searchQuery.toLowerCase();
      list = list.where((p) {
        final name = p['name']?.toString().toLowerCase() ?? '';
        final sku = p['sku']?.toString().toLowerCase() ?? '';
        return name.contains(q) || sku.contains(q);
      }).toList();
    }
    if (_stockFilter != 'All') {
      list = list.where((p) {
        final qty = int.tryParse(p['quantity']?.toString() ?? '0') ?? 0;
        switch (_stockFilter) {
          case 'In Stock': return qty > 10;
          case 'Low Stock': return qty > 0 && qty <= 10;
          case 'Out of Stock': return qty == 0;
          default: return true;
        }
      }).toList();
    }
    return list;
  }

  int get _lowStockCount => _allProducts.where((p) {
    final qty = int.tryParse(p['quantity']?.toString() ?? '0') ?? 0;
    return qty > 0 && qty <= 10;
  }).length;

  int get _outOfStockCount => _allProducts.where((p) {
    final qty = int.tryParse(p['quantity']?.toString() ?? '0') ?? 0;
    return qty == 0;
  }).length;

  Future<void> _editStock(Map<String, dynamic> product) async {
    final currentQty = int.tryParse(product['quantity']?.toString() ?? '0') ?? 0;
    final controller = TextEditingController(text: currentQty.toString());
    final result = await showDialog<int>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text("Edit Stock: ${product['name']}"),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(
            labelText: "Quantity",
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("CANCEL")),
          TextButton(
            onPressed: () {
              final qty = int.tryParse(controller.text.trim());
              if (qty != null && qty >= 0) Navigator.pop(ctx, qty);
            },
            child: const Text("SAVE", style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
    if (result != null && mounted) {
      final productId = int.tryParse(product['id'].toString());
      if (productId != null) {
        await StoreApiService.updateProduct(productId, productData: {
          'quantity': result.toString(),
          'name': product['name'],
          'price': product['price'],
          'sku': product['sku'],
        });
        _load();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.offWhite,
      appBar: AppBar(
        title: const Text("INVENTORY"),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                _buildStatsBanner(),
                _buildSearchBar(),
                _buildFilterChips(),
                Expanded(
                  child: _filteredProducts.isEmpty
                      ? _buildEmptyState()
                      : RefreshIndicator(
                          onRefresh: _load,
                          child: ListView.builder(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            itemCount: _filteredProducts.length,
                            itemBuilder: (_, i) => _buildProductCard(_filteredProducts[i]),
                          ),
                        ),
                ),
              ],
            ),
    );
  }

  Widget _buildStatsBanner() {
    final total = _allProducts.length;
    return Container(
      padding: const EdgeInsets.all(20),
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.softGrey),
      ),
      child: Row(
        children: [
          _statCircle(total.toString(), "Total", AppColors.primaryBlue),
          const SizedBox(width: 12),
          _statCircle(_lowStockCount.toString(), "Low", AppColors.sunsetOrange),
          const SizedBox(width: 12),
          _statCircle(_outOfStockCount.toString(), "OOS", Colors.red),
        ],
      ),
    );
  }

  Widget _statCircle(String value, String label, Color color) {
    return Expanded(
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(value, style: TextStyle(fontWeight: FontWeight.w900, fontSize: 18, color: color)),
          ),
          const SizedBox(height: 4),
          Text(label, style: TextStyle(fontSize: 10, color: Colors.grey.shade600, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      child: TextField(
        controller: _searchController,
        onChanged: (v) => setState(() => _searchQuery = v),
        decoration: InputDecoration(
          hintText: "Search by name or SKU...",
          prefixIcon: const Icon(Icons.search, size: 20),
          suffixIcon: _searchQuery.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear, size: 18),
                  onPressed: () {
                    _searchController.clear();
                    setState(() => _searchQuery = '');
                  },
                )
              : null,
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 16),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide(color: AppColors.softGrey),
          ),
        ),
      ),
    );
  }

  Widget _buildFilterChips() {
    return Container(
      height: 48,
      margin: const EdgeInsets.symmetric(vertical: 12),
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        children: _filters.map((f) {
          final selected = _stockFilter == f;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ChoiceChip(
              label: Text(f, style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: selected ? Colors.white : AppColors.primaryDark)),
              selected: selected,
              onSelected: (_) => setState(() => _stockFilter = f),
              selectedColor: AppColors.primaryBlue,
              backgroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              side: BorderSide(color: selected ? AppColors.primaryBlue : AppColors.softGrey),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.inventory_2_outlined, size: 60, color: Colors.grey.shade300),
          const SizedBox(height: 16),
          Text(
            _searchQuery.isNotEmpty ? "No products match your search" : "No products found",
            style: TextStyle(color: Colors.grey.shade500, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _buildProductCard(Map<String, dynamic> product) {
    final name = product['name']?.toString() ?? 'Unknown';
    final price = product['price']?.toString() ?? '0';
    final qty = int.tryParse(product['quantity']?.toString() ?? '0') ?? 0;
    final sku = product['sku']?.toString() ?? '';
    final image = product['image']?.toString();
    final images = product['images'] is List
        ? (product['images'] as List).map((e) => e.toString()).toList()
        : null;
    final displayImage = images != null && images.isNotEmpty ? images.first : image;

    Color stockColor;
    String stockLabel;
    if (qty == 0) {
      stockColor = Colors.red;
      stockLabel = 'OUT OF STOCK';
    } else if (qty <= 10) {
      stockColor = AppColors.sunsetOrange;
      stockLabel = 'LOW ($qty)';
    } else {
      stockColor = AppColors.successGreen;
      stockLabel = '$qty IN STOCK';
    }

    return GestureDetector(
      onTap: () => _editStock(product),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.softGrey),
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: displayImage != null && displayImage.isNotEmpty
                  ? Image.network(displayImage, width: 60, height: 75, fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                        width: 60, height: 75, color: Colors.grey[200],
                        child: const Icon(Icons.image_not_supported_outlined, color: Colors.grey),
                      ),
                    )
                  : Container(
                      width: 60, height: 75, color: Colors.grey[200],
                      child: const Icon(Icons.inventory_2_outlined, color: Colors.grey),
                    ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14), maxLines: 1, overflow: TextOverflow.ellipsis),
                  if (sku.isNotEmpty) Text(sku, style: TextStyle(fontSize: 10, color: Colors.grey.shade500)),
                  const SizedBox(height: 4),
                  Text("₹${double.tryParse(price)?.round() ?? price}", style: const TextStyle(fontWeight: FontWeight.w900, color: AppColors.primaryBlue, fontSize: 14)),
                  const SizedBox(height: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: stockColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(stockLabel, style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: stockColor)),
                  ),
                ],
              ),
            ),
            Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.primaryBlue.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.edit, size: 16, color: AppColors.primaryBlue),
                ),
                const SizedBox(height: 4),
                Text("Qty: $qty", style: TextStyle(fontSize: 9, color: Colors.grey.shade500)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
