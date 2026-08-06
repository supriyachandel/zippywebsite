import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../utils/app_colors.dart';
import '../services/store_api_service.dart';

class CategoryDetailScreen extends StatefulWidget {
  final String categoryId;
  final String categoryName;

  const CategoryDetailScreen({
    super.key,
    required this.categoryId,
    required this.categoryName,
  });

  @override
  State<CategoryDetailScreen> createState() => _CategoryDetailScreenState();
}

class _CategoryDetailScreenState extends State<CategoryDetailScreen> {
  List<Map<String, dynamic>> _products = [];
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
    try {
      final raw = await StoreApiService.getShopProducts(shopId);
      final catId = int.tryParse(widget.categoryId);
      if (mounted) {
        setState(() {
          _products = raw
              .map((e) => e is Map<String, dynamic> ? e : <String, dynamic>{})
              .where((p) {
                final pid = p['category_id'];
                if (pid != null) return int.tryParse(pid.toString()) == catId;
                return false;
              })
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
    return Scaffold(
      backgroundColor: AppColors.offWhite,
      appBar: AppBar(
        title: Text(widget.categoryName.toUpperCase()),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _products.isEmpty
              ? Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.inventory_2_outlined, size: 60,
                        color: AppColors.primaryDark.withValues(alpha: 0.15)),
                      const SizedBox(height: 16),
                      Text("No products in this category",
                        style: TextStyle(color: AppColors.primaryDark.withValues(alpha: 0.5), fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _load,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(24),
                    itemCount: _products.length,
                    itemBuilder: (context, index) {
                      final p = _products[index];
                      return _buildProductItem(
                        name: p['name']?.toString() ?? 'Unknown',
                        price: p['price']?.toString() ?? '0',
                        image: p['image']?.toString(),
                        stock: p['quantity']?.toString() ?? '0',
                      );
                    },
                  ),
                ),
    );
  }

  Widget _buildProductItem({
    required String name,
    required String price,
    String? image,
    required String stock,
  }) {
    return Container(
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
            child: image != null && image.isNotEmpty
                ? Image.network(image, width: 60, height: 75, fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      width: 60, height: 75, color: AppColors.softGrey,
                      child: const Icon(Icons.image, color: Colors.grey),
                    ),
                  )
                : Container(
                    width: 60, height: 75, color: AppColors.softGrey,
                    child: const Icon(Icons.inventory_2_outlined, color: Colors.grey),
                  ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                const SizedBox(height: 4),
                Text("₹${double.tryParse(price)?.round() ?? price}",
                  style: const TextStyle(color: AppColors.primaryBlue, fontWeight: FontWeight.w900, fontSize: 15),
                ),
                const SizedBox(height: 6),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: int.tryParse(stock) != null && int.parse(stock) > 5
                        ? Colors.green.withOpacity(0.1) : Colors.orange.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text("$stock in stock",
                    style: TextStyle(
                      fontSize: 10, fontWeight: FontWeight.bold,
                      color: int.tryParse(stock) != null && int.parse(stock) > 5 ? Colors.green : Colors.orange,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
