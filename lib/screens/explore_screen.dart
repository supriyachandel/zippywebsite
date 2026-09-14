import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/api_models.dart';
import '../models/cart_state.dart';
import '../services/api_service.dart';
import 'product_detail_screen.dart';
import 'search_screen.dart';

class ExploreScreen extends StatefulWidget {
  const ExploreScreen({super.key});

  @override
  State<ExploreScreen> createState() => _ExploreScreenState();
}

class _SidebarItem {
  final ApiCategory category;
  _SidebarItem.category(this.category);
}

class _ExploreScreenState extends State<ExploreScreen> {
  List<ApiCategory> _categories = [];
  List<ApiCategory> _subCategories = [];
  List<ApiProduct> _products = [];
  bool _isLoading = true;

  int? _selectedSubCatId;
  int _selectedSidebarIndex = 0;
  String? _selectedGender;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      await ApiService.loadToken();
      final results = await Future.wait([
        ApiService.getCategories(),
        ApiService.getProducts(),
        ApiService.getSubCategories(),
      ]);
      if (mounted) {
        setState(() {
          _categories = results[0] as List<ApiCategory>;
          _products = results[1] as List<ApiProduct>;
          _subCategories = results[2] as List<ApiCategory>;
          _isLoading = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  List<_SidebarItem> get _sidebarItems => _categories.map((cat) => _SidebarItem.category(cat)).toList();

  List<ApiCategory> _subCatsFor(_SidebarItem item) {
    final subs = _subCategories.where((s) => s.categoryId == item.category.id).toList();
    if (subs.isEmpty) {
      return [item.category];
    }
    return subs;
  }

  List<ApiProduct> get _filteredProducts {
    if (_selectedSubCatId != null) {
      var filtered = _products.where((p) => p.subCategoryId == _selectedSubCatId);
      if (filtered.isEmpty && _selectedSidebarIndex < _sidebarItems.length) {
        final catId = _sidebarItems[_selectedSidebarIndex].category.id;
        filtered = _products.where((p) => p.subCategoryId == catId);
      }
      if (_selectedGender != null) filtered = filtered.where((p) => p.gender == _selectedGender);
      return filtered.toList();
    }
    if (_selectedSidebarIndex < _sidebarItems.length) {
      final currentCatId = _sidebarItems[_selectedSidebarIndex].category.id;
      final subIds = _subCategories.where((s) => s.categoryId == currentCatId).map((s) => s.id).toSet();
      subIds.add(currentCatId);
      var filtered = _products.where((p) => subIds.contains(p.subCategoryId));
      if (_selectedGender != null) filtered = filtered.where((p) => p.gender == _selectedGender);
      return filtered.toList();
    }
    return _products;
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: _buildAppBar(cs),
      body: _isLoading
          ? Center(child: CircularProgressIndicator(color: cs.primary))
          : Row(
              children: [
                _buildSidebar(cs),
                const VerticalDivider(width: 1, color: Color(0xFFF0F0F0)),
                Expanded(child: _buildContent(cs)),
              ],
            ),
    );
  }

  PreferredSizeWidget _buildAppBar(ColorScheme cs) {
    return AppBar(
      backgroundColor: Colors.white,
      surfaceTintColor: Colors.white,
      elevation: 0,
      scrolledUnderElevation: 0,
      title: Text(
        "Categories",
        style: TextStyle(
          fontWeight: FontWeight.w900,
          fontSize: 22,
          color: cs.onSurface,
          letterSpacing: -0.5,
        ),
      ),
      actions: [
        GestureDetector(
          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SearchScreen())),
          child: Container(
            margin: const EdgeInsets.only(right: 12),
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: cs.surfaceContainerHighest.withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(Icons.search_rounded, color: cs.onSurface.withValues(alpha: 0.6), size: 22),
          ),
        ),
      ],
    );
  }

  Widget _buildSidebar(ColorScheme cs) {
    return Container(
      width: 88,
      color: const Color(0xFFFAFAFA),
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(vertical: 8),
        itemCount: _sidebarItems.length,
        itemBuilder: (context, i) {
          final isSelected = _selectedSidebarIndex == i;
          final item = _sidebarItems[i];

          return GestureDetector(
            onTap: () => setState(() {
              _selectedSidebarIndex = i;
              _selectedSubCatId = null;
              _selectedGender = null;
            }),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
              decoration: BoxDecoration(
                color: isSelected ? Colors.white : Colors.transparent,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isSelected ? cs.primary.withValues(alpha: 0.15) : Colors.transparent,
                  width: 1,
                ),
                boxShadow: isSelected
                    ? [
                        BoxShadow(
                          color: cs.primary.withValues(alpha: 0.08),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ]
                    : null,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    height: 48,
                    width: 48,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isSelected ? Colors.white : const Color(0xFFF5F5F5),
                      image: item.category.image != null
                          ? DecorationImage(
                              image: NetworkImage(ApiService.resolveImage(item.category.image)),
                              fit: BoxFit.cover,
                            )
                          : null,
                    ),
                    child: item.category.image == null
                        ? Icon(Icons.category_outlined, color: cs.primary, size: 22)
                        : null,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    item.category.categoryName,
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: isSelected ? FontWeight.w800 : FontWeight.w500,
                      color: isSelected ? cs.primary : cs.onSurface.withValues(alpha: 0.6),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildContent(ColorScheme cs) {
    if (_sidebarItems.isEmpty) return const SizedBox();
    if (_selectedSubCatId != null) return _buildProductGrid(cs);

    final item = _sidebarItems[_selectedSidebarIndex];
    final subs = _subCatsFor(item);

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Row(
          children: [
            Text(
              item.category.categoryName,
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: cs.onSurface, letterSpacing: -0.5),
            ),
            const Spacer(),
            Text(
              "${subs.length} subcategories",
              style: TextStyle(fontSize: 12, color: cs.onSurface.withValues(alpha: 0.4), fontWeight: FontWeight.w500),
            ),
          ],
        ),
        const SizedBox(height: 16),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: subs.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: 0.75,
          ),
          itemBuilder: (context, i) => _buildSubCategoryIcon(subs[i], cs),
        ),
      ],
    );
  }

  Widget _buildSubCategoryIcon(ApiCategory sub, ColorScheme cs) {
    return GestureDetector(
      onTap: () => setState(() => _selectedSubCatId = sub.id),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            height: 72,
            width: 72,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.06),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
              image: sub.image != null
                  ? DecorationImage(
                      image: NetworkImage(ApiService.resolveImage(sub.image)),
                      fit: BoxFit.cover,
                    )
                  : null,
            ),
            child: sub.image == null
                ? Icon(Icons.category_outlined, color: cs.primary, size: 28)
                : null,
          ),
          const SizedBox(height: 8),
          Text(
            sub.categoryName,
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: cs.onSurface.withValues(alpha: 0.8)),
          ),
        ],
      ),
    );
  }

  Widget _buildProductGrid(ColorScheme cs) {
    final products = _filteredProducts;
    final subCat = _subCategories.where((s) => s.id == _selectedSubCatId).firstOrNull;
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(8, 8, 12, 0),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: cs.primary.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: GestureDetector(
                  onTap: () => setState(() => _selectedSubCatId = null),
                  child: Icon(Icons.arrow_back_ios_new_rounded, size: 16, color: cs.primary),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  subCat?.categoryName ?? "",
                  style: TextStyle(fontWeight: FontWeight.w900, fontSize: 18, color: cs.onSurface, letterSpacing: -0.3),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: cs.surfaceContainerHighest.withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  "${products.length} items",
                  style: TextStyle(color: cs.onSurface.withValues(alpha: 0.5), fontSize: 11, fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(12, 8, 12, 4),
          child: Row(children: [
            _genderChip('male', "MEN", cs),
            const SizedBox(width: 8),
            _genderChip('female', "WOMEN", cs),
            const SizedBox(width: 8),
            _genderChip('kids', "KIDS", cs),
          ]),
        ),
        Expanded(
          child: GridView.builder(
            padding: const EdgeInsets.fromLTRB(12, 4, 12, 12),
            itemCount: products.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 0.62,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
            ),
            itemBuilder: (context, index) => _buildProductCard(products[index], cs),
          ),
        ),
      ],
    );
  }

  Widget _genderChip(String gender, String label, ColorScheme cs) {
    final selected = _selectedGender == gender;
    return GestureDetector(
      onTap: () => setState(() => _selectedGender = selected ? null : gender),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        decoration: BoxDecoration(
          color: selected ? cs.primary : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: selected ? cs.primary : cs.outline.withValues(alpha: 0.5),
            width: 1.5,
          ),
          boxShadow: selected
              ? [
                  BoxShadow(
                    color: cs.primary.withValues(alpha: 0.25),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ]
              : null,
        ),
        child: Text(
          label,
          style: TextStyle(
            color: selected ? cs.onPrimary : cs.onSurface.withValues(alpha: 0.7),
            fontWeight: FontWeight.w700,
            fontSize: 12,
          ),
        ),
      ),
    );
  }

  Widget _buildProductCard(ApiProduct product, ColorScheme cs) {
    final cartState = context.watch<CartState>();
    final qty = cartState.quantityOf(product.id);
    final hasDiscount = product.discountPriceAsDouble > 0;
    final outOfStock = product.isOutOfStock;
    final lowStock = product.isLowStock;
    final remaining = product.quantityAsInt - qty;

    return GestureDetector(
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => ProductDetailScreen(product: product))),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
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
                    color: cs.surfaceContainerHighest.withValues(alpha: 0.3),
                    child: Image.network(
                      ApiService.resolveImage(product.displayImage),
                      width: double.infinity,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                        color: cs.surfaceContainerHighest.withValues(alpha: 0.3),
                        child: Icon(Icons.image_not_supported_outlined, color: cs.onSurface.withValues(alpha: 0.2)),
                      ),
                    ),
                  ),
                  if (outOfStock)
                    Positioned.fill(
                      child: Container(
                        color: Colors.white.withValues(alpha: 0.7),
                        child: Center(
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: Colors.red.shade600,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Text(
                              "OUT OF STOCK",
                              style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 0.5),
                            ),
                          ),
                        ),
                      ),
                    ),
                  if (!outOfStock)
                    Positioned(
                      top: 8,
                      right: 8,
                      child: Container(
                        height: 30,
                        width: 30,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.9),
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.06),
                              blurRadius: 6,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Icon(Icons.favorite_border_rounded, color: cs.error.withValues(alpha: 0.7), size: 15),
                      ),
                    ),
                  if (!outOfStock && hasDiscount)
                    Positioned(
                      bottom: 8,
                      left: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: cs.primary,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          "${((product.priceAsDouble - product.discountPriceAsDouble) / product.priceAsDouble * 100).round()}% OFF",
                          style: TextStyle(color: cs.onPrimary, fontSize: 9, fontWeight: FontWeight.w900),
                        ),
                      ),
                    ),
                ],
              ),
            ),
            Expanded(
              flex: 5,
              child: Padding(
                padding: const EdgeInsets.all(10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          product.name,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: outOfStock ? cs.onSurface.withValues(alpha: 0.35) : cs.onSurface,
                          ),
                        ),
                        if (!outOfStock && lowStock)
                          Padding(
                            padding: const EdgeInsets.only(top: 2),
                            child: Text(
                              "Only ${product.quantityAsInt} left!",
                              style: TextStyle(fontSize: 9, color: Colors.orange.shade700, fontWeight: FontWeight.w700),
                            ),
                          ),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "₹${product.discountPriceAsDouble.round()}",
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w900,
                                color: outOfStock ? cs.onSurface.withValues(alpha: 0.25) : cs.onSurface,
                              ),
                            ),
                            if (hasDiscount)
                              Text(
                                "₹${product.priceAsDouble.round()}",
                                style: TextStyle(
                                  fontSize: 10,
                                  decoration: TextDecoration.lineThrough,
                                  color: cs.onSurface.withValues(alpha: 0.3),
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                          ],
                        ),
                        if (outOfStock)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                            decoration: BoxDecoration(
                              color: cs.errorContainer.withValues(alpha: 0.3),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text("Sold Out", style: TextStyle(color: cs.error, fontSize: 10, fontWeight: FontWeight.w800)),
                          )
                        else
                          GestureDetector(
                            onTap: qty == 0 ? () => cartState.incrementProduct(product) : null,
                            child: Container(
                              height: 30,
                              padding: EdgeInsets.symmetric(horizontal: qty == 0 ? 12 : 4),
                              decoration: BoxDecoration(
                                color: qty == 0 ? cs.primary : cs.primary.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: qty == 0
                                  ? Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(Icons.add, color: cs.onPrimary, size: 14),
                                        const SizedBox(width: 3),
                                        Text(
                                          "ADD",
                                          style: TextStyle(color: cs.onPrimary, fontWeight: FontWeight.w900, fontSize: 11),
                                        ),
                                      ],
                                    )
                                  : Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        GestureDetector(
                                          onTap: () => cartState.decrementProduct(product),
                                          child: const Padding(
                                            padding: EdgeInsets.symmetric(horizontal: 5),
                                            child: Icon(Icons.remove_rounded, color: Colors.black54, size: 16),
                                          ),
                                        ),
                                        Text(
                                          "$qty",
                                          style: TextStyle(color: cs.onSurface, fontWeight: FontWeight.w900, fontSize: 12),
                                        ),
                                        GestureDetector(
                                          onTap: remaining > 1 ? () => cartState.incrementProduct(product) : null,
                                          child: Padding(
                                            padding: const EdgeInsets.symmetric(horizontal: 5),
                                            child: Icon(
                                              Icons.add_rounded,
                                              color: remaining > 1 ? Colors.black54 : Colors.black26,
                                              size: 16,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
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
}
