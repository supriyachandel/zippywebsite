import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/api_models.dart';
import '../models/cart_state.dart';
import '../services/api_service.dart';
import '../utils/app_theme.dart';
import 'product_detail_screen.dart';
import 'cart_screen.dart';

class ShopDetailsScreen extends StatefulWidget {
  final ApiShop shop;
  const ShopDetailsScreen({super.key, required this.shop});

  @override
  State<ShopDetailsScreen> createState() => _ShopDetailsScreenState();
}

class _ShopDetailsScreenState extends State<ShopDetailsScreen> {
  List<ApiProduct> _shopProducts = [];
  List<ApiProduct> _filteredProducts = [];
  List<ApiCategory> _subCategories = [];
  bool _isLoading = true;
  int? _selectedSubCategory;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    try {
      final results = await Future.wait([
        ApiService.getShopProducts(widget.shop.id),
        ApiService.getSubCategories(),
      ]);
      if (mounted) {
        setState(() {
          _shopProducts = results[0] as List<ApiProduct>;
          _subCategories = results[1] as List<ApiCategory>;
          _subCategories.sort((a, b) => a.categoryName.compareTo(b.categoryName));
          _filteredProducts = List.from(_shopProducts);
          _isLoading = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _filterBySubCategory(int? subCategoryId) {
    setState(() {
      _selectedSubCategory = subCategoryId;
      _applyFilters();
    });
  }

  void _onSearchChanged(String query) {
    _applyFilters();
  }

  void _applyFilters() {
    final query = _searchController.text.toLowerCase();
    List<ApiProduct> results = _shopProducts;

    if (_selectedSubCategory != null) {
      results = results.where((p) => p.subCategoryId == _selectedSubCategory).toList();
    }

    if (query.isNotEmpty) {
      results = results.where((p) =>
        p.name.toLowerCase().contains(query) ||
        (p.description?.toLowerCase().contains(query) ?? false)
      ).toList();
    }

    setState(() => _filteredProducts = results);
  }

  Set<int> get _availableSubCategoryIds =>
      _shopProducts.map((p) => p.subCategoryId).toSet();

  void _showShopInfo(BuildContext context) {
    final shop = widget.shop;
    final cs = Theme.of(context).colorScheme;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: cs.surface,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.6,
          maxChildSize: 0.85,
          expand: false,
          builder: (context, scrollController) {
            return Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
              child: ListView(
                controller: scrollController,
                children: [
                  Center(child: Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(2)))),
                  const SizedBox(height: 20),
                  Text("Shop Information", style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: cs.primary)),
                  const SizedBox(height: 20),
                  _infoTile(cs, Icons.storefront, "Shop Name", shop.name),
                  _infoTile(cs, Icons.info_outline, "About", shop.description),
                  _infoTile(cs, Icons.location_on_outlined, "Address", [shop.address, shop.city, shop.state].where((s) => s != null).join(', ')),
                  _infoTile(cs, Icons.receipt_long, "GST Number", shop.gstNumber),
                  _infoTile(cs, Icons.email_outlined, "Contact Email", shop.email),
                  _infoTile(cs, Icons.language, "Website", shop.website),
                  const SizedBox(height: 20),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _infoTile(ColorScheme cs, IconData icon, String label, String? value) {
    if (value == null || value.isEmpty) return const SizedBox.shrink();
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: cs.surfaceContainerHighest.withValues(alpha: 0.5), borderRadius: BorderRadius.circular(12)),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: cs.primary),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: cs.onSurface.withValues(alpha: 0.5))),
                Text(value, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: cs.onSurface)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final shop = widget.shop;
    final imageUrl = ApiService.resolveImage(shop.image);
    final cartState = context.watch<CartState>();

    return Scaffold(
      backgroundColor: cs.surface,
      body: Stack(
        children: [
          _buildContent(shop, imageUrl, cs, cartState),
          if (cartState.totalItems > 0) _buildFloatingCartBar(cartState, cs),
        ],
      ),
    );
  }

  Widget _buildContent(ApiShop shop, String imageUrl, ColorScheme cs, CartState cartState) {
    return CustomScrollView(
      slivers: [
        _buildModernAppBar(shop, imageUrl, cs),
        SliverToBoxAdapter(child: _buildSearchBar(cs)),
        if (_subCategories.isNotEmpty)
          SliverToBoxAdapter(child: _buildSubCategoryFilters(cs)),
        if (_filteredProducts.isNotEmpty)
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
              child: Text(
                _selectedSubCategory != null
                    ? '${_filteredProducts.length} item(s)'
                    : '${_shopProducts.length} items available',
                style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16, color: cs.onSurface),
              ),
            ),
          ),
        _isLoading
            ? SliverFillRemaining(child: Center(child: CircularProgressIndicator(color: Theme.of(context).colorScheme.primary)))
            : _filteredProducts.isEmpty
            ? SliverFillRemaining(
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.search_off_rounded, size: 48, color: cs.onSurface.withOpacity(0.2)),
                      const SizedBox(height: 12),
                      Text("No products found", style: TextStyle(color: cs.onSurface.withOpacity(0.4), fontWeight: FontWeight.w600)),
                    ],
                  ),
                ),
              )
            : SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                sliver: SliverGrid(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 0.65,
                    mainAxisSpacing: 12,
                    crossAxisSpacing: 12,
                  ),
                  delegate: SliverChildBuilderDelegate(
                    (context, index) => _buildZeptoCard(context, _filteredProducts[index], cs),
                    childCount: _filteredProducts.length,
                  ),
                ),
              ),
        const SliverToBoxAdapter(child: SizedBox(height: 100)),
      ],
    );
  }

  Widget _buildSearchBar(ColorScheme cs) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 6),
      child: TextField(
        controller: _searchController,
        onChanged: (v) => _onSearchChanged(v),
        style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: cs.onSurface, letterSpacing: -0.2),
        decoration: InputDecoration(
          hintText: "Search in ${widget.shop.name}",
          hintStyle: TextStyle(color: cs.onSurface.withOpacity(0.3), fontSize: 14, fontWeight: FontWeight.w400),
          prefixIcon: Icon(Icons.search_rounded, color: cs.onSurface.withOpacity(0.3), size: 20),
          prefixIconConstraints: const BoxConstraints(minWidth: 40, minHeight: 40),
          suffixIcon: _searchController.text.isNotEmpty
              ? IconButton(
                  onPressed: () {
                    _searchController.clear();
                    _applyFilters();
                  },
                  icon: Icon(Icons.close_rounded, size: 18, color: cs.onSurface.withOpacity(0.3)),
                )
              : null,
          filled: true,
          fillColor: cs.surfaceContainerHighest.withOpacity(0.4),
          contentPadding: const EdgeInsets.symmetric(horizontal: 4, vertical: 14),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20),
            borderSide: BorderSide(color: cs.primary.withOpacity(0.4), width: 1.5),
          ),
        ),
      ),
    );
  }

  Widget _buildSubCategoryFilters(ColorScheme cs) {
    final availableIds = _availableSubCategoryIds;
    final filtered = _subCategories.where((s) => availableIds.contains(s.id)).toList();

    if (filtered.isEmpty) return const SizedBox.shrink();

    return SizedBox(
      height: 36,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: filtered.length + 1,
        separatorBuilder: (_, __) => const SizedBox(width: 6),
        itemBuilder: (context, i) {
          final isAll = i == 0;
          final isSelected = isAll ? _selectedSubCategory == null : _selectedSubCategory == filtered[i - 1].id;
          final label = isAll ? "All" : filtered[i - 1].categoryName;

          return GestureDetector(
            onTap: () => _filterBySubCategory(isAll ? null : filtered[i - 1].id),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 14),
              decoration: BoxDecoration(
                color: isSelected ? cs.primary : cs.surface,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isSelected ? cs.primary : cs.outlineVariant.withOpacity(0.5),
                  width: 1,
                ),
                boxShadow: isSelected
                    ? [BoxShadow(color: cs.primary.withOpacity(0.25), blurRadius: 8, offset: const Offset(0, 2))]
                    : null,
              ),
              alignment: Alignment.center,
              child: Text(
                label,
                style: TextStyle(
                  color: isSelected ? cs.onPrimary : cs.onSurface.withOpacity(0.55),
                  fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                  fontSize: 12,
                  letterSpacing: -0.2,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildZeptoCard(BuildContext context, ApiProduct product, ColorScheme cs) {
    final cartState = context.read<CartState>();
    final qty = cartState.quantityOf(product.id);
    final hasDiscount = product.discountPriceAsDouble > 0;
    final displayPrice = hasDiscount ? product.discountPriceAsDouble : product.priceAsDouble;
    final outOfStock = product.isOutOfStock;
    final lowStock = product.isLowStock;
    final remaining = product.quantityAsInt - qty;

    return GestureDetector(
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => ProductDetailScreen(product: product))),
      child: Container(
        decoration: BoxDecoration(
          color: cs.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: cs.outlineVariant.withOpacity(0.4),
            width: 1,
          ),
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 6,
              child: Stack(
                children: [
                  Container(
                    width: double.infinity,
                    color: cs.surfaceContainerHighest.withOpacity(0.2),
                    child: Image.network(
                      ApiService.resolveImage(product.displayImage),
                      fit: BoxFit.contain,
                      errorBuilder: (_, __, ___) => Center(
                        child: Icon(Icons.image_outlined, color: cs.onSurface.withOpacity(0.15), size: 36),
                      ),
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
                              style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 0.5),
                            ),
                          ),
                        ),
                      ),
                    )
                  else if (hasDiscount)
                    Positioned(
                      top: 6,
                      left: 6,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.red,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          "${((product.priceAsDouble - product.discountPriceAsDouble) / product.priceAsDouble * 100).round()}% OFF",
                          style: const TextStyle(color: Colors.white, fontSize: 8, fontWeight: FontWeight.w800),
                        ),
                      ),
                    ),
                  Positioned(
                    top: 6,
                    right: 6,
                    child: Container(
                      height: 26,
                      width: 26,
                      decoration: BoxDecoration(
                        color: cs.surface.withOpacity(0.85),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(Icons.favorite_border_rounded, color: cs.onSurface.withOpacity(0.4), size: 14),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              flex: 4,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(8, 6, 8, 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      product.name,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        height: 1.2,
                        color: outOfStock ? cs.onSurface.withOpacity(0.4) : cs.onSurface,
                      ),
                    ),
                    Text(
                      product.size ?? "1 unit",
                      style: TextStyle(fontSize: 10, color: cs.onSurface.withOpacity(0.4), fontWeight: FontWeight.w500),
                    ),
                    if (!outOfStock && lowStock)
                      Text(
                        "Only ${product.quantityAsInt} left!",
                        style: TextStyle(fontSize: 9, color: Colors.orange.shade700, fontWeight: FontWeight.w700),
                      ),
                    if (!outOfStock && remaining > 0 && qty > 0 && remaining <= 5)
                      Text(
                        "Only $remaining left!",
                        style: TextStyle(fontSize: 9, color: Colors.orange.shade700, fontWeight: FontWeight.w700),
                      ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (hasDiscount)
                              Text(
                                "₹${product.priceAsDouble.round()}",
                                style: TextStyle(
                                  fontSize: 10,
                                  decoration: TextDecoration.lineThrough,
                                  color: cs.onSurface.withOpacity(0.3),
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            Text(
                              "₹${displayPrice.round()}",
                              style: TextStyle(
                                fontWeight: FontWeight.w900,
                                fontSize: 15,
                                color: outOfStock ? cs.onSurface.withOpacity(0.3) : cs.onSurface,
                              ),
                            ),
                          ],
                        ),
                        outOfStock
                            ? Container(
                                height: 30,
                                padding: const EdgeInsets.symmetric(horizontal: 10),
                                decoration: BoxDecoration(
                                  color: cs.errorContainer.withOpacity(0.3),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Center(
                                  child: Text(
                                    "Sold Out",
                                    style: TextStyle(color: cs.error, fontSize: 10, fontWeight: FontWeight.w800),
                                  ),
                                ),
                              )
                            : qty == 0
                                ? GestureDetector(
                                    onTap: () => cartState.incrementProduct(product),
                                    child: Container(
                                      height: 30,
                                      width: 30,
                                      decoration: BoxDecoration(
                                        color: cs.primary,
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: const Icon(Icons.add, color: Colors.white, size: 18),
                                    ),
                                  )
                                : Container(
                                    height: 30,
                                    width: 80,
                                    decoration: BoxDecoration(
                                      color: cs.primary,
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                      children: [
                                        GestureDetector(
                                          onTap: () => cartState.decrementProduct(product),
                                          child: const Icon(Icons.remove, color: Colors.white, size: 16),
                                        ),
                                        Text(
                                          "$qty",
                                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 13),
                                        ),
                                        GestureDetector(
                                          onTap: remaining > 1 ? () => cartState.incrementProduct(product) : null,
                                          child: Icon(
                                            Icons.add,
                                            color: remaining > 1 ? Colors.white : Colors.white38,
                                            size: 16,
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
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFloatingCartBar(CartState cartState, ColorScheme cs) {
    return Positioned(
      bottom: 20, left: 16, right: 16,
      child: Container(
        height: 48,
        padding: const EdgeInsets.symmetric(horizontal: 14),
        decoration: BoxDecoration(
          color: cs.primary,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: cs.primary.withValues(alpha: 0.3),
              blurRadius: 10,
              offset: const Offset(0, 3)
            ),
          ],
        ),
        child: Row(
          children: [
            Icon(Icons.shopping_bag_outlined, color: cs.onPrimary.withValues(alpha: 0.8), size: 16),
            const SizedBox(width: 8),
            Text("${cartState.totalItems} item${cartState.totalItems > 1 ? 's' : ''}", style: TextStyle(color: cs.onPrimary, fontWeight: FontWeight.bold, fontSize: 12)),
            const Spacer(),
            Text("₹${cartState.totalPrice.round()}", style: TextStyle(color: cs.onPrimary, fontWeight: FontWeight.w900, fontSize: 14)),
            const SizedBox(width: 12),
            Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5), decoration: BoxDecoration(color: cs.onPrimary.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(20)),
              child: Row(mainAxisSize: MainAxisSize.min, children: [
                Text("VIEW", style: TextStyle(color: cs.onPrimary, fontWeight: FontWeight.w900, fontSize: 10, letterSpacing: 0.5)),
                const SizedBox(width: 2),
                Icon(Icons.arrow_forward_ios, color: cs.onPrimary, size: 8),
              ]),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildModernAppBar(ApiShop shop, String imageUrl, ColorScheme cs) {
    return SliverAppBar(
      expandedHeight: 150,
      pinned: true,
      elevation: 0,
      backgroundColor: cs.surface,
      leading: IconButton(
        icon: CircleAvatar(backgroundColor: cs.surface.withOpacity(0.8), child: Icon(Icons.arrow_back, color: cs.onSurface, size: 20)),
        onPressed: () => Navigator.pop(context),
      ),
      actions: [
        IconButton(
          icon: CircleAvatar(backgroundColor: cs.surface.withOpacity(0.8), child: Icon(Icons.info_outline, color: cs.onSurface, size: 20)),
          onPressed: () => _showShopInfo(context),
        ),
        const SizedBox(width: 8),
      ],
      flexibleSpace: FlexibleSpaceBar(
        background: Stack(
          fit: StackFit.expand,
          children: [
            Image.network(imageUrl, fit: BoxFit.cover, errorBuilder: (_, __, ___) => Container(color: Colors.grey[200])),
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.black.withOpacity(0.1), Colors.black.withOpacity(0.6)],
                ),
              ),
            ),
            Positioned(
              bottom: 12,
              left: 16,
              right: 16,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(shop.name, style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w900)),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(Icons.timer_outlined, color: Colors.greenAccent, size: 14),
                      const SizedBox(width: 4),
                      Text("Delivery in 10-15 mins", style: TextStyle(color: Colors.greenAccent, fontWeight: FontWeight.bold, fontSize: 12)),
                      const SizedBox(width: 10),
                      const Icon(Icons.star, color: Colors.amber, size: 14),
                      const SizedBox(width: 4),
                      const Text("4.5", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)),
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
