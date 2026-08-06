import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:async';
import '../models/cart_state.dart';
import '../models/user_state.dart';
import '../models/api_models.dart';
import '../services/api_service.dart';
import '../utils/app_colors.dart';
import '../utils/app_theme.dart';
import 'product_detail_screen.dart';
import 'profile_screen.dart';
import 'explore_screen.dart';
import 'shop_details_screen.dart';
import 'cart_screen.dart';
import 'search_screen.dart';
import 'add_address_screen.dart';
import 'order_history_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  final List<Widget> _pages = [
    const HomeContent(),
    const ExploreScreen(),
    const OrderHistoryScreen(),
    const ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Scaffold(
      backgroundColor: cs.surface,
      body: IndexedStack(
        index: _currentIndex,
        children: _pages,
      ),
      bottomNavigationBar: _buildBottomNav(cs),
    );
  }

  Widget _buildBottomNav(ColorScheme cs) {
    return Container(
      decoration: BoxDecoration(
        color: cs.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 20,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(12, 8, 12, 6),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _navItem(0, Icons.home_filled, Icons.home_filled, "Home", cs),
                _navItem(1, Icons.grid_view_rounded, Icons.category_sharp, "Explore", cs),
                _navItem(2, Icons.receipt_rounded, Icons.bookmark_border_rounded, "Orders", cs),
                _navItem(3, Icons.person_rounded, Icons.person, "Profile", cs),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _navItem(int index, IconData activeIcon, IconData inactiveIcon, String label, ColorScheme cs) {
    final isSelected = _currentIndex == index;
    return GestureDetector(
      onTap: () => setState(() => _currentIndex = index),
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? cs.primary.withValues(alpha: 0.1) : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isSelected ? activeIcon : inactiveIcon,
              color: isSelected ? cs.primary : cs.onSurface.withValues(alpha: 0.4),
              size: 22,
            ),
            if (isSelected) ...[
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: cs.primary,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class HomeContent extends StatefulWidget {
  const HomeContent({super.key});

  @override
  State<HomeContent> createState() => _HomeContentState();
}

class _HomeContentState extends State<HomeContent> with TickerProviderStateMixin {
  List<ApiProduct> _products = [];
  List<ApiShop> _shops = [];
  List<ApiAddress> _addresses = [];
  List<ApiCategory> _subCategories = [];
  ApiAddress? _selectedAddress;
  bool _isLoading = true;
  late PageController _productPageController;
  double _currentPage = 0;
  late PageController _bannerController;
  int _currentBanner = 0;
  Timer? _bannerTimer;

  final List<Map<String, String>> _banners = [
    {"image": "https://images.unsplash.com/photo-1441986300917-64674bd600d8?w=800&h=400&fit=crop", "title": "TRENDING NOW", "subtitle": "New arrivals just dropped"},
    {"image": "https://images.unsplash.com/photo-1556742049-0cfed4f6a45d?w=800&h=400&fit=crop", "title": "BEST DEALS", "subtitle": "Up to 60% off"},
    {"image": "https://images.unsplash.com/photo-1542291026-7eec264c27ff?w=800&h=400&fit=crop", "title": "STYLE HAUL", "subtitle": "Fresh picks for you"},
    {"image": "https://images.unsplash.com/photo-1558618666-fcd25c85f82e?w=800&h=400&fit=crop", "title": "NEW IN", "subtitle": "Shop the latest collection"},
  ];

  @override
  void initState() {
    super.initState();
    _productPageController = PageController(viewportFraction: 0.75)
      ..addListener(() {
        setState(() => _currentPage = _productPageController.page ?? 0);
      });
    _bannerController = PageController()
      ..addListener(() {
        final page = _bannerController.page?.round() ?? 0;
        if (page != _currentBanner) {
          setState(() => _currentBanner = page);
        }
      });
    _startBannerAutoPlay();
    _loadData();
  }

  void _startBannerAutoPlay() {
    _bannerTimer?.cancel();
    _bannerTimer = Timer.periodic(const Duration(seconds: 4), (_) {
      if (!mounted) return;
      if (_bannerController.hasClients) {
        final next = (_currentBanner + 1) % _banners.length;
        _bannerController.animateToPage(
          next,
          duration: const Duration(milliseconds: 400),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  @override
  void dispose() {
    _productPageController.dispose();
    _bannerController.dispose();
    _bannerTimer?.cancel();
    super.dispose();
  }

  Future<void> _loadData() async {
    try {
      await ApiService.loadToken();
      final results = await Future.wait([
        ApiService.getProducts(),
        ApiService.getShops(),
        ApiService.getAddresses(),
        ApiService.getSubCategories(),
      ]);
      if (mounted) {
        setState(() {
          _products = (results[0] as List<ApiProduct>)..sort((a, b) => b.createdAt.compareTo(a.createdAt));
          _shops = results[1] as List<ApiShop>;
          _addresses = results[2] as List<ApiAddress>;
          _subCategories = results[3] as List<ApiCategory>;
          _selectedAddress = _addresses.firstOrNull;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showAddressSelector() {
    final cs = Theme.of(context).colorScheme;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: cs.surface,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(28))),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 30),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: cs.outlineVariant,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Text(
                "Select Delivery Location",
                style: TextStyle(fontWeight: FontWeight.w900, fontSize: 20, color: cs.onSurface),
              ),
              const SizedBox(height: 12),
              Text(
                "Choose where you'd like your order delivered",
                style: TextStyle(fontSize: 13, color: cs.onSurface.withOpacity(0.6)),
              ),
              const SizedBox(height: 20),
              ..._addresses.map((a) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: ListTile(
                  tileColor: _selectedAddress?.id == a.id ? cs.primary.withOpacity(0.08) : cs.surfaceContainerLowest,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                    side: BorderSide(
                      color: _selectedAddress?.id == a.id ? cs.primary : cs.outlineVariant,
                      width: _selectedAddress?.id == a.id ? 2 : 1,
                    ),
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: cs.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      a.label.toLowerCase() == 'home' ? Icons.home : Icons.work,
                      color: cs.primary,
                      size: 20,
                    ),
                  ),
                  title: Text(a.label, style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14, color: cs.onSurface)),
                  subtitle: Text(
                    a.address,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(fontSize: 12, color: cs.onSurface.withOpacity(0.6)),
                  ),
                  trailing: Radio<int>(
                    value: a.id,
                    groupValue: _selectedAddress?.id,
                    activeColor: cs.primary,
                    onChanged: (val) {
                      setState(() => _selectedAddress = a);
                      Navigator.pop(ctx);
                    },
                  ),
                  onTap: () {
                    setState(() => _selectedAddress = a);
                    Navigator.pop(ctx);
                  },
                ),
              )),
              const SizedBox(height: 12),
              Divider(color: cs.outlineVariant),
              const SizedBox(height: 8),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: Icon(Icons.add_circle, color: cs.primary, size: 28),
                title: Text(
                  "Add New Address",
                  style: TextStyle(color: cs.primary, fontWeight: FontWeight.w700, fontSize: 15),
                ),
                onTap: () {
                  Navigator.pop(ctx);
                  Navigator.push(context, MaterialPageRoute(builder: (_) => const AddAddressScreen())).then((_) => _loadData());
                },
              )
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final userState = Provider.of<UserState>(context);
    final isFemale = userState.gender == Gender.female;

    if (_isLoading) {
      return Scaffold(
        backgroundColor: cs.surface,
        body: Center(
          child: CircularProgressIndicator(color: cs.primary),
        ),
      );
    }

    return Scaffold(
      backgroundColor: cs.surface,
      body: SafeArea(
        child: _buildContent(cs),
      ),
    );
  }

  Widget _buildContent(ColorScheme cs) {
    return RefreshIndicator(
      onRefresh: _loadData,
      color: cs.primary,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildCustomAppBar(cs),
            const SizedBox(height: 16),
            _buildSearchBar(cs),
            const SizedBox(height: 24),
            _buildBannerSlider(cs),
            const SizedBox(height: 28),
            _buildSectionHeader("Categories", cs),
            const SizedBox(height: 12),
            _buildCategoryCarousel(cs, _subCategories),
            const SizedBox(height: 28),
            _buildSectionHeader("Trending Now", cs),
            const SizedBox(height: 8),
            _buildProductSlider(cs),
            const SizedBox(height: 28),
            _buildSectionHeader("Stores Nearby", cs),
            const SizedBox(height: 12),
            _buildStoreShowcase(cs),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildCustomAppBar(ColorScheme cs) {
    final userName = Provider.of<UserState>(context).userName ?? 'User';
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              GestureDetector(
                onTap: _showAddressSelector,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: cs.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.location_on_rounded, size: 12, color: cs.primary),
                      const SizedBox(width: 3),
                      Text(
                        _selectedAddress?.city ?? "Select location",
                        style: TextStyle(
                          fontSize: 11,
                          color: cs.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(width: 2),
                      Icon(Icons.keyboard_arrow_down_rounded, size: 14, color: cs.primary),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                "Hello, $userName",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: cs.onSurface,
                  letterSpacing: -0.3,
                ),
              ),
            ],
          ),
          Row(
            children: [
              GestureDetector(
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const CartScreen())),
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: cs.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.04),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Consumer<CartState>(
                    builder: (context, cart, _) => Badge(
                      label: Text(
                        cart.totalItems.toString(),
                        style: const TextStyle(fontSize: 8, fontWeight: FontWeight.bold, color: Colors.white),
                      ),
                      isLabelVisible: cart.totalItems > 0,
                      child: Icon(Icons.shopping_bag_outlined, color: cs.onSurface, size: 20),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 6),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: cs.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.04),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Icon(Icons.notifications_none_rounded, color: cs.onSurface, size: 20),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar(ColorScheme cs) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: GestureDetector(
        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SearchScreen())),
        child: Container(
          height: 52,
          decoration: BoxDecoration(
            color: cs.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 16,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              Icon(Icons.search_rounded, color: cs.primary.withOpacity(0.5), size: 22),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  "Search for products, brands...",
                  style: TextStyle(
                    color: cs.onSurface.withOpacity(0.35),
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              Container(
                width: 1,
                height: 24,
                color: cs.outlineVariant.withOpacity(0.5),
              ),
              const SizedBox(width: 12),
              Icon(Icons.tune_rounded, color: cs.primary.withOpacity(0.6), size: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBannerSlider(ColorScheme cs) {
    return SizedBox(
      height: 140,
      child: Stack(
        children: [
          PageView.builder(
            controller: _bannerController,
            itemCount: _banners.length,
            onPageChanged: (i) => setState(() => _currentBanner = i),
            itemBuilder: (context, i) {
              final b = _banners[i];
              return Container(
                margin: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  color: cs.surfaceContainerHighest,
                ),
                clipBehavior: Clip.antiAlias,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    Image.network(
                      b["image"]!,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [cs.primary.withOpacity(0.6), cs.primary.withOpacity(0.3)],
                          ),
                        ),
                      ),
                    ),
                    Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.black.withValues(alpha: 0.1),
                            Colors.black.withValues(alpha: 0.6),
                          ],
                        ),
                      ),
                    ),
                    Positioned(
                      left: 20,
                      bottom: 20,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            b["title"]!,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 22,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 0.5,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            b["subtitle"]!,
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.85),
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
          Positioned(
            bottom: 8,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                _banners.length,
                (i) => AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  margin: const EdgeInsets.symmetric(horizontal: 3),
                  height: 6,
                  width: _currentBanner == i ? 24 : 6,
                  decoration: BoxDecoration(
                    color: _currentBanner == i ? Colors.white : Colors.white.withOpacity(0.5),
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, ColorScheme cs) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w900,
              color: cs.onSurface,
              letterSpacing: -0.5,
            ),
          ),
          TextButton(
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ExploreScreen())),
            style: TextButton.styleFrom(
              padding: EdgeInsets.zero,
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            child: Row(
              children: [
                Text("View All", style: TextStyle(color: cs.primary, fontWeight: FontWeight.w700, fontSize: 13)),
                const SizedBox(width: 2),
                Icon(Icons.chevron_right_rounded, color: cs.primary, size: 18),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryCarousel(ColorScheme cs, List<ApiCategory> categories) {
    final defaultCategories = [
      {"name": "Casual", "icon": Icons.checkroom},
      {"name": "Business", "icon": Icons.work},
      {"name": "Sport", "icon": Icons.sports_basketball},
      {"name": "Classic", "icon": Icons.star},
      {"name": "Trend", "icon": Icons.trending_up},
    ];

    final displayCategories = categories.isEmpty ? defaultCategories : categories;

    return SizedBox(
      height: 90,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: displayCategories.length.clamp(0, 12),
        separatorBuilder: (_, __) => const SizedBox(width: 16),
        itemBuilder: (context, i) {
          if (categories.isEmpty) {
            final cat = defaultCategories[i];
            return GestureDetector(
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ExploreScreen())),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 64,
                    height: 64,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(18),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.06),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Icon(cat["icon"] as IconData, color: cs.primary, size: 26),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    cat["name"] as String,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: cs.onSurface.withOpacity(0.8),
                    ),
                  ),
                ],
              ),
            );
          } else {
            final cat = categories[i];
            return GestureDetector(
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ExploreScreen())),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 64,
                    height: 64,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(18),
                      color: Colors.white,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.06),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                      image: cat.image != null
                          ? DecorationImage(
                              image: NetworkImage(ApiService.resolveImage(cat.image)),
                              fit: BoxFit.cover,
                            )
                          : null,
                    ),
                    child: cat.image == null
                        ? Icon(Icons.category_outlined, color: cs.primary, size: 26)
                        : null,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    cat.categoryName,
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: cs.onSurface.withOpacity(0.8),
                    ),
                  ),
                ],
              ),
            );
          }
        },
      ),
    );
  }

  Widget _buildProductSlider(ColorScheme cs) {
    if (_products.isEmpty) {
      return Container(
        height: 380,
        margin: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: cs.surfaceContainerHighest.withOpacity(0.3),
          borderRadius: BorderRadius.circular(28),
          border: Border.all(color: cs.outlineVariant.withOpacity(0.3)),
        ),
        alignment: Alignment.center,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.shopping_bag_outlined, size: 40, color: cs.onSurface.withOpacity(0.25)),
            const SizedBox(height: 12),
            Text(
              "No products available",
              style: TextStyle(color: cs.onSurface.withOpacity(0.4), fontWeight: FontWeight.bold),
            ),
          ],
        ),
      );
    }

    return SizedBox(
      height: 400,
      child: PageView.builder(
        controller: _productPageController,
        itemCount: _products.length,
        itemBuilder: (context, index) {
          double scale = (1 - ((_currentPage - index).abs() * 0.12)).clamp(0.88, 1.0);
          return TweenAnimationBuilder<double>(
            tween: Tween(begin: scale, end: scale),
            duration: const Duration(milliseconds: 200),
            builder: (context, value, child) {
              return Transform.scale(
                scale: value,
                child: child,
              );
            },
            child: _buildSliderProductCard(context, _products[index], cs),
          );
        },
      ),
    );
  }

  Widget _buildSliderProductCard(BuildContext context, ApiProduct product, ColorScheme cs) {
    final hasDiscount = product.discountPriceAsDouble > 0;
    final price = hasDiscount ? product.discountPriceAsDouble : product.priceAsDouble;
    final cartState = context.watch<CartState>();
    final qty = cartState.quantityOf(product.id);
    final outOfStock = product.isOutOfStock;
    final lowStock = product.isLowStock;
    final remaining = product.quantityAsInt - qty;

    return GestureDetector(
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => ProductDetailScreen(product: product))),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.07),
              blurRadius: 24,
              offset: const Offset(0, 10),
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
                    color: cs.surfaceContainerHighest.withOpacity(0.3),
                    child: Image.network(
                      ApiService.resolveImage(product.displayImage),
                      width: double.infinity,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Center(
                        child: Icon(Icons.image_not_supported_outlined, color: cs.onSurface.withOpacity(0.15), size: 40),
                      ),
                    ),
                  ),
                  if (outOfStock)
                    Positioned.fill(
                      child: Container(
                        color: Colors.white.withOpacity(0.7),
                        child: Center(
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                            decoration: BoxDecoration(
                              color: Colors.red.shade600,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Text(
                              "OUT OF STOCK",
                              style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w900, letterSpacing: 0.5),
                            ),
                          ),
                        ),
                      ),
                    ),
                  Positioned(
                    top: 12,
                    left: 12,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.6),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.star_rounded, color: Colors.amber, size: 13),
                          const SizedBox(width: 3),
                          Text(
                            "4.8",
                            style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w800),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Positioned(
                    top: 12,
                    right: 12,
                    child: Container(
                      height: 36,
                      width: 36,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.9),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.08),
                            blurRadius: 6,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Icon(Icons.favorite_border_rounded, color: cs.error.withOpacity(0.7), size: 18),
                    ),
                  ),
                  if (!outOfStock && hasDiscount)
                    Positioned(
                      bottom: 12,
                      left: 12,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: cs.primary,
                          borderRadius: BorderRadius.circular(8),
                          boxShadow: [
                            BoxShadow(
                              color: cs.primary.withOpacity(0.3),
                              blurRadius: 8,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: Text(
                          "${((product.priceAsDouble - product.discountPriceAsDouble) / product.priceAsDouble * 100).round()}% OFF",
                          style: TextStyle(color: cs.onPrimary, fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 0.3),
                        ),
                      ),
                    ),
                ],
              ),
            ),
            Expanded(
              flex: 4,
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          product.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w800,
                            color: outOfStock ? cs.onSurface.withOpacity(0.35) : cs.onSurface,
                            letterSpacing: -0.3,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          product.description ?? "Premium Quality",
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(fontSize: 12, color: cs.onSurface.withOpacity(0.4), fontWeight: FontWeight.w500),
                        ),
                        if (!outOfStock && lowStock) ...[
                          const SizedBox(height: 3),
                          Text(
                            "Only ${product.quantityAsInt} left!",
                            style: TextStyle(fontSize: 10, color: Colors.orange.shade700, fontWeight: FontWeight.w700),
                          ),
                        ],
                        if (!outOfStock && remaining > 0 && qty > 0 && remaining <= 5) ...[
                          const SizedBox(height: 3),
                          Text(
                            "Only $remaining left!",
                            style: TextStyle(fontSize: 10, color: Colors.orange.shade700, fontWeight: FontWeight.w700),
                          ),
                        ],
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  "₹${price.round()}",
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.w900,
                                    color: outOfStock ? cs.onSurface.withOpacity(0.25) : cs.onSurface,
                                    letterSpacing: -0.5,
                                  ),
                                ),
                                if (hasDiscount) ...[
                                  const SizedBox(width: 6),
                                  Text(
                                    "₹${product.priceAsDouble.round()}",
                                    style: TextStyle(
                                      fontSize: 11,
                                      decoration: TextDecoration.lineThrough,
                                      color: cs.onSurface.withOpacity(0.3),
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ],
                        ),
                        if (outOfStock)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: cs.errorContainer.withOpacity(0.25),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              "Sold Out",
                              style: TextStyle(color: cs.error, fontSize: 11, fontWeight: FontWeight.w800),
                            ),
                          )
                        else if (qty == 0)
                          GestureDetector(
                            onTap: () => cartState.incrementProduct(product),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                              decoration: BoxDecoration(
                                color: cs.primary,
                                borderRadius: BorderRadius.circular(12),
                                boxShadow: [
                                  BoxShadow(
                                    color: cs.primary.withOpacity(0.25),
                                    blurRadius: 8,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.add_shopping_cart_rounded, color: Colors.white, size: 14),
                                  const SizedBox(width: 4),
                                  Text(
                                    "ADD",
                                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 11),
                                  ),
                                ],
                              ),
                            ),
                          )
                        else
                          Container(
                            height: 34,
                            padding: const EdgeInsets.symmetric(horizontal: 4),
                            decoration: BoxDecoration(
                              color: cs.primary,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                GestureDetector(
                                  onTap: () => cartState.decrementProduct(product),
                                  child: const Padding(
                                    padding: EdgeInsets.symmetric(horizontal: 6),
                                    child: Icon(Icons.remove_rounded, color: Colors.white, size: 18),
                                  ),
                                ),
                                Text(
                                  "$qty",
                                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 13),
                                ),
                                GestureDetector(
                                  onTap: remaining > 1 ? () => cartState.incrementProduct(product) : null,
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 6),
                                    child: Icon(
                                      Icons.add_rounded,
                                      color: remaining > 1 ? Colors.white : Colors.white38,
                                      size: 18,
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
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStoreShowcase(ColorScheme cs) {
    if (_shops.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Container(
          height: 160,
          decoration: BoxDecoration(
            color: cs.surfaceContainerHighest.withOpacity(0.3),
            borderRadius: BorderRadius.circular(28),
            border: Border.all(color: cs.outlineVariant.withOpacity(0.3)),
          ),
          alignment: Alignment.center,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.storefront_rounded, size: 40, color: cs.onSurface.withOpacity(0.2)),
              const SizedBox(height: 12),
              Text(
                "No stores available",
                style: TextStyle(color: cs.onSurface.withOpacity(0.4), fontWeight: FontWeight.w600, fontSize: 14),
              ),
            ],
          ),
        ),
      );
    }

    return SizedBox(
      height: 185,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: _shops.length.clamp(0, 5),
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (context, i) => _buildStoreCard(_shops[i], cs),
      ),
    );
  }

  Widget _buildStoreCard(ApiShop shop, ColorScheme cs) {
    return GestureDetector(
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => ShopDetailsScreen(shop: shop))),
      child: Container(
        width: 200,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 90,
              width: double.infinity,
              color: cs.surfaceContainerHighest.withOpacity(0.5),
              child: Stack(
                children: [
                  Image.network(
                    ApiService.resolveImage(shop.image),
                    width: double.infinity,
                    height: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Center(
                      child: Icon(Icons.storefront_rounded, color: cs.onSurface.withOpacity(0.15), size: 30),
                    ),
                  ),
                  Positioned(
                    top: 8,
                    left: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.65),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.star_rounded, color: Colors.amber, size: 12),
                          const SizedBox(width: 3),
                          const Text(
                            "4.5",
                            style: TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.w900),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: AppColors.successGreen.withOpacity(0.9),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        "Verified",
                        style: TextStyle(color: Colors.white, fontSize: 8, fontWeight: FontWeight.w800),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    shop.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(fontWeight: FontWeight.w800, fontSize: 14, color: cs.onSurface),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    shop.description ?? "Specialty fashion store",
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(fontSize: 11, color: cs.onSurface.withOpacity(0.45), fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(Icons.delivery_dining_rounded, size: 12, color: AppColors.successGreen),
                      const SizedBox(width: 4),
                      Text(
                        "15 min",
                        style: TextStyle(color: AppColors.successGreen, fontSize: 10, fontWeight: FontWeight.w700),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        "Free delivery",
                        style: TextStyle(color: cs.onSurface.withOpacity(0.4), fontSize: 10, fontWeight: FontWeight.w500),
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
