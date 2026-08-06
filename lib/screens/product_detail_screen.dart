import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import '../models/cart_state.dart';
import '../models/api_models.dart';
import '../services/api_service.dart';
import '../utils/app_theme.dart';
import 'shop_details_screen.dart';
import 'cart_screen.dart';

class ProductDetailScreen extends StatefulWidget {
  final ApiProduct product;
  const ProductDetailScreen({super.key, required this.product});

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  String _selectedSize = 'M';
  int _imageIndex = 0;
  ApiShop? _shop;

  @override
  void initState() {
    super.initState();
    _selectedSize = widget.product.size?.split(',').first.trim() ?? 'M';
    _loadShop();
  }

  Future<void> _loadShop() async {
    try {
      final shops = await ApiService.getShops();
      if (mounted) {
        setState(() {
          _shop = shops.where((s) => s.id == widget.product.shopId).firstOrNull;
        });
      }
    } catch (_) {}
  }

  void _showBhavNegotiation() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => BhavNegotiationSheet(
        product: widget.product,
        selectedSize: _selectedSize,
      ),
    );
  }

  List<String> get _images {
    if (widget.product.imageUrls.isNotEmpty) return widget.product.imageUrls;
    final img = widget.product.image;
    return (img == null || img.isEmpty) ? [] : [img];
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final hasDiscount = widget.product.discountPriceAsDouble > 0 &&
        widget.product.discountPriceAsDouble < widget.product.priceAsDouble;

    return Scaffold(
      backgroundColor: cs.surface,
      body: _buildBody(cs, hasDiscount),
    );
  }

  Widget _buildBody(ColorScheme cs, bool hasDiscount) {
    return Stack(
      children: [
        CustomScrollView(
          slivers: [
            _buildSliverAppBar(cs),
            SliverToBoxAdapter(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildMainInfo(hasDiscount, cs),
                  Divider(thickness: 8, color: cs.surfaceContainerHighest),
                  _buildShopCard(cs),
                  Divider(thickness: 8, color: cs.surfaceContainerHighest),
                  _buildSizeSelector(cs),
                  _buildColorSelector(cs),
                  _buildDescription(cs),
                  _buildBargainSection(cs),
                  const SizedBox(height: 120),
                ],
              ),
            ),
          ],
        ),
        _buildFloatingBottomBar(hasDiscount, cs),
      ],
    );
  }

  Widget _buildSliverAppBar(ColorScheme cs) {
    final images = _images;
    return SliverAppBar(
      expandedHeight: MediaQuery.of(context).size.width,
      backgroundColor: cs.surface,
      elevation: 0,
      leading: Padding(
        padding: const EdgeInsets.all(8.0),
        child: CircleAvatar(
          backgroundColor: cs.surface.withOpacity(0.9),
          child: IconButton(
            icon: Icon(Icons.arrow_back, color: cs.onSurface),
            onPressed: () => Navigator.pop(context),
          ),
        ),
      ),
      flexibleSpace: FlexibleSpaceBar(
        background: Stack(
          children: [
            PageView.builder(
              onPageChanged: (i) => setState(() => _imageIndex = i),
              itemCount: images.length,
              itemBuilder: (context, index) => Image.network(
                images[index],
                fit: BoxFit.cover,
              ),
            ),
            if (images.length > 1)
              Positioned(
                bottom: 20,
                left: 0,
                right: 0,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(images.length, (i) => AnimatedContainer(
                    duration: 300.ms,
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    height: 8,
                    width: _imageIndex == i ? 24 : 8,
                    decoration: BoxDecoration(
                      color: _imageIndex == i ? cs.primary : Colors.grey.withOpacity(0.5),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  )),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildMainInfo(bool hasDiscount, ColorScheme cs) {
    final outOfStock = widget.product.isOutOfStock;
    final lowStock = widget.product.isLowStock;
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(widget.product.name, style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: cs.onSurface)),
          const SizedBox(height: 8),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.amber.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Icon(Icons.star_rounded, color: Colors.amber, size: 16),
                    const SizedBox(width: 4),
                    Text(
                      "4.4",
                      style: TextStyle(color: Colors.amber.shade700, fontSize: 14, fontWeight: FontWeight.w800),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              if (outOfStock)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(color: Colors.red.shade50, borderRadius: BorderRadius.circular(8), border: Border.all(color: Colors.red.shade200)),
                  child: Text("Out of Stock", style: TextStyle(color: Colors.red.shade700, fontSize: 12, fontWeight: FontWeight.w800)),
                )
              else if (lowStock)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(color: Colors.orange.shade50, borderRadius: BorderRadius.circular(8), border: Border.all(color: Colors.orange.shade200)),
                  child: Text("Only ${widget.product.quantityAsInt} left!", style: TextStyle(color: Colors.orange.shade700, fontSize: 12, fontWeight: FontWeight.w800)),
                )
              else
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(color: cs.primaryContainer, borderRadius: BorderRadius.circular(8), border: Border.all(color: cs.primary.withOpacity(0.3))),
                  child: Text("In Stock", style: TextStyle(color: cs.primary, fontSize: 12, fontWeight: FontWeight.w800)),
                ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Text(
                "₹${(hasDiscount ? widget.product.discountPriceAsDouble : widget.product.priceAsDouble).round()}",
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w900,
                  color: outOfStock ? cs.onSurface.withOpacity(0.4) : cs.onSurface,
                ),
              ),
              if (hasDiscount) ...[
                const SizedBox(width: 8),
                Text("₹${widget.product.priceAsDouble.round()}",
                    style: TextStyle(decoration: TextDecoration.lineThrough, color: cs.onSurface.withOpacity(0.4), fontSize: 16)),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(color: cs.primary, borderRadius: BorderRadius.circular(4)),
                  child: Text("${((1 - widget.product.discountPriceAsDouble / widget.product.priceAsDouble) * 100).round()}% OFF",
                      style: TextStyle(color: cs.onPrimary, fontSize: 12, fontWeight: FontWeight.bold)),
                ),
              ]
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildShopCard(ColorScheme cs) {
    if (_shop == null) return const SizedBox();
    final shopImageUrl = ApiService.resolveImage(_shop!.image);
    return InkWell(
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => ShopDetailsScreen(shop: _shop!))),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            shopImageUrl.isNotEmpty
                ? Container(height: 50, width: 50,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10), 
                      color: cs.surfaceContainerHighest,
                      image: DecorationImage(image: NetworkImage(shopImageUrl), fit: BoxFit.cover, onError: (_, __) {})),
                  )
                : Container(height: 50, width: 50,
                    decoration: BoxDecoration(borderRadius: BorderRadius.circular(10), color: cs.surfaceContainerHighest),
                    child: Icon(Icons.store, color: cs.onSurface.withOpacity(0.3), size: 24)),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(_shop!.name, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: cs.onSurface)),
                  Text(_shop!.city ?? "Local Shop", style: TextStyle(color: cs.onSurface.withOpacity(0.5), fontSize: 12)),
                ],
              ),
            ),
            Icon(Icons.chevron_right, color: cs.onSurface.withOpacity(0.4)),
          ],
        ),
      ),
    );
  }

  Widget _buildSizeSelector(ColorScheme cs) {
    final sizes = widget.product.size?.split(',').map((s) => s.trim()).toList() ?? ['S', 'M', 'L', 'XL'];
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Select Size", style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16, color: cs.onSurface)),
          const SizedBox(height: 12),
          SizedBox(
            height: 45,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: sizes.length,
              itemBuilder: (context, i) {
                final isSelected = _selectedSize == sizes[i];
                return GestureDetector(
                  onTap: () => setState(() => _selectedSize = sizes[i]),
                  child: Container(
                    margin: const EdgeInsets.only(right: 10),
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: isSelected ? cs.primary : cs.surface,
                      border: Border.all(
                        color: isSelected ? cs.primary : cs.outline,
                        width: 1,
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(sizes[i], style: TextStyle(color: isSelected ? cs.onPrimary : cs.onSurface, fontWeight: FontWeight.bold)),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildColorSelector(ColorScheme cs) {
    final colors = [
      {"name": "Pink", "color": cs.primary},
      {"name": "Purple", "color": cs.secondary},
      {"name": "Light Blue", "color": const Color(0xFF81D4FA)},
    ];
    String _selectedColor = colors[0]["name"] as String;

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Select Color", style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16, color: cs.onSurface)),
          const SizedBox(height: 12),
          SizedBox(
            height: 45,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: colors.length,
              itemBuilder: (context, i) {
                final colorData = colors[i];
                final isSelected = _selectedColor == colorData["name"];
                return GestureDetector(
                  onTap: () => setState(() => _selectedColor = colorData["name"] as String),
                  child: Container(
                    margin: const EdgeInsets.only(right: 12),
                    width: 45,
                    height: 45,
                    decoration: BoxDecoration(
                      color: colorData["color"] as Color,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: isSelected ? cs.onSurface : Colors.transparent,
                        width: 3,
                      ),
                    ),
                    child: isSelected
                        ? Icon(Icons.check, color: cs.surface, size: 20)
                        : null,
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDescription(ColorScheme cs) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Product Details", style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16, color: cs.onSurface)),
          const SizedBox(height: 8),
          Text(widget.product.description ?? "No description available.",
              style: TextStyle(color: cs.onSurface.withOpacity(0.6), height: 1.5)),
        ],
      ),
    );
  }

  Widget _buildBargainSection(ColorScheme cs) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: cs.primaryContainer,
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: cs.primary.withOpacity(0.2)),
        ),
        child: Row(
          children: [
            Icon(Icons.local_offer, color: cs.primary),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Want a better price?", style: TextStyle(fontWeight: FontWeight.bold, color: cs.primary)),
                  Text("Try Bargaining (BHAV) with the seller", style: TextStyle(fontSize: 12, color: cs.onSurface)),
                ],
              ),
            ),
            TextButton(
              onPressed: _showBhavNegotiation,
              style: TextButton.styleFrom(backgroundColor: cs.primary, foregroundColor: cs.onPrimary),
              child: const Text("START"),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildFloatingBottomBar(bool hasDiscount, ColorScheme cs) {
    final cartState = context.watch<CartState>();
    final qty = cartState.quantityOf(widget.product.id);
    final price = (hasDiscount ? widget.product.discountPriceAsDouble : widget.product.priceAsDouble).round();
    final outOfStock = widget.product.isOutOfStock;
    final remaining = widget.product.quantityAsInt - qty;

    return Positioned(
      bottom: 0, left: 0, right: 0,
      child: Container(
        padding: EdgeInsets.fromLTRB(20, 15, 20, MediaQuery.of(context).padding.bottom + 10),
        decoration: BoxDecoration(
          color: cs.surface,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05), 
              blurRadius: 10, 
              offset: const Offset(0, -5)
            ),
          ],
        ),
        child: Row(
          children: [
            Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("₹$price", style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: outOfStock ? cs.onSurface.withOpacity(0.4) : cs.onSurface)),
                Text("Total Price", style: TextStyle(fontSize: 12, color: cs.onSurface.withOpacity(0.5))),
              ],
            ),
            const Spacer(),
            outOfStock
                ? Container(
                    width: 140, height: 50,
                    decoration: BoxDecoration(
                      color: cs.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Center(
                      child: Text("OUT OF STOCK", style: TextStyle(color: cs.onSurface.withOpacity(0.4), fontWeight: FontWeight.bold, fontSize: 13)),
                    ),
                  )
                : qty == 0
                    ? SizedBox(
                        width: 140, height: 50,
                        child: ElevatedButton(
                          onPressed: () => cartState.incrementProduct(widget.product),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: cs.primary,
                            foregroundColor: cs.onPrimary,
                            elevation: 0,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                          ),
                          child: const Text("Add to cart", style: TextStyle(fontWeight: FontWeight.bold)),
                        ),
                      )
                    : Container(
                        width: 140, height: 50,
                        decoration: BoxDecoration(
                          color: cs.primary, 
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            IconButton(onPressed: () => cartState.decrementProduct(widget.product), icon: Icon(Icons.remove, color: cs.onPrimary)),
                            Text("$qty", style: TextStyle(color: cs.onPrimary, fontWeight: FontWeight.bold, fontSize: 18)),
                            IconButton(
                              onPressed: remaining > 1 ? () => cartState.incrementProduct(widget.product) : null,
                              icon: Icon(Icons.add, color: remaining > 1 ? cs.onPrimary : cs.onPrimary.withOpacity(0.3)),
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

// --- Zepto UI Bargain Sheet ---

class BhavNegotiationSheet extends StatefulWidget {
  final ApiProduct product;
  final String selectedSize;
  const BhavNegotiationSheet({super.key, required this.product, required this.selectedSize});

  @override
  State<BhavNegotiationSheet> createState() => _BhavNegotiationSheetState();
}

enum _Round { offer, counter, finalRound, result }

class _BhavNegotiationSheetState extends State<BhavNegotiationSheet> {
  _Round _round = _Round.offer;
  double _customerOffer = 0.5;
  double _sellerCounter = 0.3;
  bool _dealStruck = false;
  late double _listPrice;
  late double _floorPrice;

  @override
  void initState() {
    super.initState();
    _listPrice = widget.product.priceAsDouble;
    _floorPrice = widget.product.discountPriceAsDouble > 0 ? widget.product.discountPriceAsDouble : _listPrice * 0.7;
  }

  double get _currentOfferPrice => _listPrice - (_customerOffer * (_listPrice - _floorPrice));
  double get _counterPrice => _floorPrice + (_sellerCounter * (_listPrice - _floorPrice));

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(color: cs.surface, borderRadius: const BorderRadius.vertical(top: Radius.circular(30))),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(width: 40, height: 4, decoration: BoxDecoration(color: cs.outline, borderRadius: BorderRadius.circular(2))),
          const SizedBox(height: 20),
          if (_round == _Round.result) _buildResult(cs) else _buildProcess(cs),
        ],
      ),
    );
  }

  Widget _buildProcess(ColorScheme cs) {
    return Column(
      children: [
        Text("Bhav Bargaining", style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: cs.onSurface)),
        const SizedBox(height: 30),
        Stack(
          alignment: Alignment.center,
          children: [
            SizedBox(
              height: 150, width: 150,
              child: CircularProgressIndicator(
                value: 1 - _customerOffer,
                strokeWidth: 12,
                backgroundColor: cs.surfaceContainerHighest,
                valueColor: AlwaysStoppedAnimation(cs.primary),
              ),
            ),
            Column(
              children: [
                Text("YOUR PRICE", style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: cs.onSurface.withOpacity(0.5))),
                Text("₹${_currentOfferPrice.round()}", style: TextStyle(fontSize: 30, fontWeight: FontWeight.w900, color: cs.primary)),
              ],
            )
          ],
        ),
        Slider(
          value: _customerOffer,
          activeColor: cs.primary,
          onChanged: (v) => setState(() => _customerOffer = v),
        ),
        const SizedBox(height: 20),
        SizedBox(
          width: double.infinity,
          height: 55,
          child: ElevatedButton(
            onPressed: () => setState(() => _round = _Round.result),
            style: ElevatedButton.styleFrom(backgroundColor: cs.primary, foregroundColor: cs.onPrimary, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15))),
            child: const Text("MAKE OFFER", style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        )
      ],
    );
  }

  Widget _buildResult(ColorScheme cs) {
    _dealStruck = _currentOfferPrice >= _floorPrice;
    return Column(
      children: [
        Icon(_dealStruck ? Icons.check_circle : Icons.cancel, size: 80, color: _dealStruck ? cs.primary : Colors.red),
        const SizedBox(height: 16),
        Text(_dealStruck ? "Deal Accepted!" : "Offer Too Low", style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: cs.onSurface)),
        const SizedBox(height: 8),
        Text(_dealStruck ? "The seller agreed to ₹${_currentOfferPrice.round()}" : "The seller can't go below ₹${_floorPrice.round()}", style: TextStyle(color: cs.onSurface.withOpacity(0.6))),
        const SizedBox(height: 30),
        SizedBox(
          width: double.infinity,
          height: 55,
          child: ElevatedButton(
            onPressed: () {
              if (_dealStruck) {
                context.read<CartState>().addToCart(widget.product, widget.selectedSize);
              }
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(backgroundColor: cs.primary, foregroundColor: cs.onPrimary, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15))),
            child: Text(_dealStruck ? "Add" : "GO BACK", style: const TextStyle(fontWeight: FontWeight.bold)),
          ),
        )
      ],
    );
  }
}
