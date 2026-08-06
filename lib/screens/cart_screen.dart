import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/cart_state.dart';
import '../utils/app_theme.dart';
import 'checkout_screen.dart';

class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final cartState = Provider.of<CartState>(context);
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: cs.surface,
      body: Column(
        children: [
          _buildAppBar(context, cs),
          Expanded(
            child: cartState.items.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.shopping_bag_outlined, size: 80, color: cs.onSurface.withOpacity(0.2)),
                        const SizedBox(height: 16),
                        Text(
                          "YOUR BAG IS EMPTY",
                          style: TextStyle(
                            color: cs.onSurface.withOpacity(0.5),
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.5,
                          ),
                        ),
                        const SizedBox(height: 24),
                        ElevatedButton(
                          onPressed: () => Navigator.pop(context),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: cs.primary,
                            foregroundColor: cs.onPrimary,
                            elevation: 0,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                          ),
                          child: const Text("GO SHOPPING"),
                        ),
                      ],
                    ),
                  )
                : Column(
                    children: [
                      Expanded(
                        child: ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: cartState.items.length,
                          itemBuilder: (context, index) {
                            final item = cartState.items[index];
                            final imageUrl = item.product.displayImage.isNotEmpty ? item.product.displayImage : 'https://via.placeholder.com/100';
                            return Container(
                              margin: const EdgeInsets.only(bottom: 12),
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: cs.surface,
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: cs.outlineVariant,
                                  width: 1,
                                ),
                              ),
                              child: Row(
                                children: [
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(16),
                                    child: Image.network(
                                      imageUrl,
                                      width: 80,
                                      height: 80,
                                      fit: BoxFit.cover,
                                      errorBuilder: (context, error, stackTrace) => Container(
                                        width: 80,
                                        height: 80,
                                        color: cs.surfaceContainerHighest,
                                        child: const Icon(Icons.broken_image, color: Colors.grey),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          item.product.name,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: TextStyle(
                                            color: cs.onSurface,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 14,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          "Size: ${item.size}",
                                          style: TextStyle(
                                            color: cs.onSurface.withValues(alpha: 0.5),
                                            fontSize: 12,
                                          ),
                                        ),
                                        const SizedBox(height: 8),
                                        Row(
                                          children: [
                                            Container(
                                              decoration: BoxDecoration(
                                                color: cs.surfaceContainerHighest,
                                                borderRadius: BorderRadius.circular(12),
                                              ),
                                              child: IconButton(
                                                icon: const Icon(Icons.remove, size: 16),
                                                onPressed: () {
                                                  cartState.updateQuantity(item, -1);
                                                },
                                                constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                                              ),
                                            ),
                                            const SizedBox(width: 12),
                                            Text(
                                              "${item.quantity}",
                                              style: const TextStyle(fontWeight: FontWeight.bold),
                                            ),
                                            const SizedBox(width: 12),
                                            Container(
                                              decoration: BoxDecoration(
                                                color: cs.surfaceContainerHighest,
                                                borderRadius: BorderRadius.circular(12),
                                              ),
                                              child: IconButton(
                                                icon: const Icon(Icons.add, size: 16),
                                                onPressed: () {
                                                  cartState.updateQuantity(item, 1);
                                                },
                                                constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                  Text(
                                    "₹${(item.quantity * (item.product.discountPriceAsDouble > 0 ? item.product.discountPriceAsDouble : item.product.priceAsDouble)).round()}",
                                    style: TextStyle(
                                      color: cs.primary,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: cs.surface,
                          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 10,
                              offset: const Offset(0, -5),
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  "TOTAL",
                                  style: TextStyle(
                                    color: cs.onSurface,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                    letterSpacing: 1,
                                  ),
                                ),
                                Text(
                                  "₹${cartState.totalPrice.round()}",
                                  style: TextStyle(
                                    color: cs.primary,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 22,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            ElevatedButton(
                              onPressed: () {
                                Navigator.push(context, MaterialPageRoute(builder: (_) => const CheckoutScreen()));
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: cs.primary,
                                foregroundColor: cs.onPrimary,
                                elevation: 0,
                                minimumSize: const Size(double.infinity, 60),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20),
                                ),
                              ),
                              child: const Text(
                                "CHECKOUT NOW",
                                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildAppBar(BuildContext context, ColorScheme cs) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      color: cs.surface,
      child: Row(
        children: [
          IconButton(
            icon: Icon(Icons.arrow_back_ios_new, color: cs.onSurface, size: 20),
            onPressed: () => Navigator.pop(context),
          ),
          const SizedBox(width: 8),
          Text(
            "MY BAG",
            style: TextStyle(
              color: cs.onSurface,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.5,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }
}
