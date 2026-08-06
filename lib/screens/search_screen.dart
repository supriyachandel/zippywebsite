import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/api_models.dart';
import '../models/cart_state.dart';
import '../services/api_service.dart';
import 'product_detail_screen.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final _searchController = TextEditingController();
  List<ApiProduct> _allProducts = [];
  List<ApiProduct> _results = [];
  List<ApiShop> _shops = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    try {
      await ApiService.loadToken();
      final results = await Future.wait([
        ApiService.getProducts(),
        ApiService.getShops(),
      ]);
      if (mounted) {
        setState(() {
          _allProducts = results[0] as List<ApiProduct>;
          _shops = results[1] as List<ApiShop>;
          _results = _allProducts;
          _isLoading = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  String _getShopName(int shopId) {
    try {
      return _shops.firstWhere((s) => s.id == shopId).name;
    } catch (_) {
      return 'Shop';
    }
  }

  void _onSearchChanged() {
    final query = _searchController.text.toLowerCase().trim();
    setState(() {
      if (query.isEmpty) {
        _results = _allProducts;
      } else {
        _results = _allProducts.where((p) {
          final nameMatch = p.name.toLowerCase().contains(query);
          final shopMatch = _getShopName(p.shopId).toLowerCase().contains(query);
          final descMatch = p.description?.toLowerCase().contains(query) ?? false;
          final materialMatch = p.material?.toLowerCase().contains(query) ?? false;
          final colorMatch = p.color?.toLowerCase().contains(query) ?? false;
          return nameMatch || shopMatch || descMatch || materialMatch || colorMatch;
        }).toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: cs.surface,
      body: SafeArea(
        child: Column(
          children: [
            _buildSearchBar(cs),
            if (_isLoading)
              const Expanded(child: Center(child: CircularProgressIndicator()))
            else if (_results.isEmpty)
              Expanded(
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.search_off, size: 64, color: cs.onSurface.withValues(alpha: 0.15)),
                      const SizedBox(height: 16),
                      Text(
                        _searchController.text.isEmpty ? 'No products available' : 'No results found',
                        style: TextStyle(color: cs.onSurface.withValues(alpha: 0.5), fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
              )
            else
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
                      child: Text(
                        "${_results.length} ${_results.length == 1 ? 'product' : 'products'} found",
                        style: TextStyle(color: cs.onSurface.withValues(alpha: 0.5), fontSize: 12, fontWeight: FontWeight.bold),
                      ),
                    ),
                    Expanded(
                      child: GridView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: _results.length,
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          childAspectRatio: 0.8,
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 12,
                        ),
                        itemBuilder: (context, index) => _buildProductCard(_results[index], cs),
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchBar(ColorScheme cs) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
      color: cs.surface,
      child: Row(
        children: [
          IconButton(
            icon: Icon(Icons.arrow_back, color: cs.onSurface),
            onPressed: () => Navigator.pop(context),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: TextField(
              controller: _searchController,
              autofocus: true,
              decoration: InputDecoration(
                hintText: 'Search products, brands...',
                hintStyle: TextStyle(color: cs.onSurface.withValues(alpha: 0.3)),
                border: InputBorder.none,
                filled: true,
                fillColor: cs.surfaceContainerHighest.withValues(alpha: 0.4),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                prefixIcon: Icon(Icons.search, color: cs.onSurface.withValues(alpha: 0.4)),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: Icon(Icons.clear, color: cs.onSurface.withValues(alpha: 0.4)),
                        onPressed: () {
                          _searchController.clear();
                        },
                      )
                    : null,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProductCard(ApiProduct product, ColorScheme cs) {
    final hasDiscount = product.discountPriceAsDouble > 0 &&
        product.discountPriceAsDouble < product.priceAsDouble;
    final imageUrl = ApiService.resolveImage(product.displayImage);
    final cartState = context.watch<CartState>();
    final qty = cartState.quantityOf(product.id);
    final outOfStock = product.isOutOfStock;
    final remaining = product.quantityAsInt - qty;

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => ProductDetailScreen(product: product)),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: cs.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: cs.outlineVariant.withValues(alpha: 0.4),
            width: 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    Image.network(
                      imageUrl,
                      fit: BoxFit.cover,
                      width: double.infinity,
                      errorBuilder: (context, error, stackTrace) => Container(
                        color: cs.surfaceContainerHighest.withOpacity(0.3),
                        child: Icon(Icons.image_not_supported_outlined, color: cs.onSurface.withOpacity(0.2)),
                      ),
                    ),
                    if (outOfStock)
                      Positioned.fill(
                        child: Container(
                          color: cs.surface.withOpacity(0.7),
                          child: Center(
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                              decoration: BoxDecoration(
                                color: Colors.red.shade600,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Text(
                                "OUT OF STOCK",
                                style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w900),
                              ),
                            ),
                          ),
                        ),
                      ),
                    if (!outOfStock && hasDiscount)
                      Positioned(
                        top: 8, left: 8,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                          decoration: BoxDecoration(
                            color: cs.primary,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            "${((1 - product.discountPriceAsDouble / product.priceAsDouble) * 100).round()}%",
                            style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: cs.onSurface,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    _getShopName(product.shopId),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(color: cs.onSurface.withValues(alpha: 0.4), fontSize: 10),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Text(
                        "₹${(hasDiscount ? product.discountPriceAsDouble : product.priceAsDouble).round()}",
                        style: TextStyle(
                          color: outOfStock ? cs.onSurface.withOpacity(0.3) : cs.onSurface,
                          fontWeight: FontWeight.w800,
                          fontSize: 14,
                        ),
                      ),
                      if (hasDiscount) ...[
                        const SizedBox(width: 4),
                        Text(
                          "₹${product.priceAsDouble.round()}",
                          style: TextStyle(
                            color: cs.onSurface.withValues(alpha: 0.4),
                            fontSize: 11,
                            decoration: TextDecoration.lineThrough,
                          ),
                        ),
                      ],
                      const Spacer(),
                      outOfStock
                          ? Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: cs.errorContainer.withOpacity(0.3),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                "Sold Out",
                                style: TextStyle(color: cs.error, fontSize: 9, fontWeight: FontWeight.w800),
                              ),
                            )
                          : qty == 0
                              ? GestureDetector(
                                  onTap: () => cartState.incrementProduct(product),
                                  child: Container(
                                    height: 28,
                                    width: 28,
                                    decoration: BoxDecoration(
                                      color: cs.primary,
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Icon(Icons.add, color: cs.onPrimary, size: 16),
                                  ),
                                )
                              : Container(
                                  height: 28,
                                  decoration: BoxDecoration(
                                    color: cs.primary,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      GestureDetector(
                                        onTap: () => cartState.decrementProduct(product),
                                        child: Padding(
                                          padding: const EdgeInsets.symmetric(horizontal: 6),
                                          child: Icon(Icons.remove, color: cs.onPrimary, size: 14),
                                        ),
                                      ),
                                      Text(
                                        "$qty",
                                        style: TextStyle(color: cs.onPrimary, fontWeight: FontWeight.bold, fontSize: 12),
                                      ),
                                      GestureDetector(
                                        onTap: remaining > 1 ? () => cartState.incrementProduct(product) : null,
                                        child: Padding(
                                          padding: const EdgeInsets.symmetric(horizontal: 6),
                                          child: Icon(
                                            Icons.add,
                                            color: remaining > 1 ? cs.onPrimary : cs.onPrimary.withOpacity(0.4),
                                            size: 14,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
