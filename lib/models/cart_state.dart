import 'dart:convert';
import 'package:flutter/material.dart';
import '../models/api_models.dart';
import '../services/prefs_service.dart';

class CartItem {
  final ApiProduct product;
  int quantity;
  String size;

  CartItem({
    required this.product,
    this.quantity = 1,
    required this.size,
  });
}

class CartState extends ChangeNotifier {
  final List<CartItem> _items = [];

  List<CartItem> get items => _items;

  Future<void> init() async {
    final saved = await PrefsService.getString('cart_items');
    if (saved != null && saved.isNotEmpty) {
      try {
        final list = jsonDecode(saved) as List;
        _items.clear();
        for (final e in list) {
          _items.add(CartItem(
            product: ApiProduct.fromJson(e['product']),
            quantity: e['quantity'] as int,
            size: e['size'] as String,
          ));
        }
        notifyListeners();
      } catch (_) {}
    }
  }

  Future<void> _save() async {
    final list = _items.map((e) => {
      'product': {
        'id': e.product.id,
        'name': e.product.name,
        'price': e.product.price,
        'discount_price': e.product.discountPrice,
        'image': e.product.image,
        'image_urls': e.product.imageUrls,
        'size': e.product.size,
        'gender': e.product.gender,
        'shop_id': e.product.shopId,
        'sub_category_id': e.product.subCategoryId,
        'description': e.product.description,
        'quantity': e.product.quantity,
        'status': e.product.status,
        'user_id': e.product.userId,
        'created_at': e.product.createdAt,
        'updated_at': e.product.updatedAt,
      },
      'quantity': e.quantity,
      'size': e.size,
    }).toList();
    await PrefsService.setString('cart_items', jsonEncode(list));
  }

  int? get shopId => _items.isEmpty ? null : _items.first.product.shopId;

  double get totalPrice {
    return _items.fold(0, (sum, item) => sum + item.quantity * (item.product.discountPriceAsDouble > 0 ? item.product.discountPriceAsDouble : item.product.priceAsDouble));
  }

  int get totalItems => _items.fold(0, (sum, item) => sum + item.quantity);

  int quantityOf(int productId) {
    final idx = _items.indexWhere((item) => item.product.id == productId);
    return idx != -1 ? _items[idx].quantity : 0;
  }

  Future<void> incrementProduct(ApiProduct product) async {
    final idx = _items.indexWhere((item) => item.product.id == product.id);
    if (product.isOutOfStock) return;
    if (idx != -1) {
      if (_items[idx].quantity >= product.quantityAsInt) return;
      _items[idx].quantity++;
    } else {
      if (product.quantityAsInt <= 0) return;
      _items.add(CartItem(product: product, size: product.size ?? '', quantity: 1));
    }
    notifyListeners();
    await _save();
  }

  Future<void> decrementProduct(ApiProduct product) async {
    final idx = _items.indexWhere((item) => item.product.id == product.id);
    if (idx != -1) {
      if (_items[idx].quantity > 1) {
        _items[idx].quantity--;
      } else {
        _items.removeAt(idx);
      }
      notifyListeners();
      await _save();
    }
  }

  Future<void> addToCart(ApiProduct product, String size, {int quantity = 1}) async {
    if (product.isOutOfStock) return;
    final index = _items.indexWhere((item) => item.product.id == product.id && item.size == size);
    if (index != -1) {
      final newQty = _items[index].quantity + quantity;
      _items[index].quantity = newQty > product.quantityAsInt ? product.quantityAsInt : newQty;
    } else {
      final addQty = quantity > product.quantityAsInt ? product.quantityAsInt : quantity;
      if (addQty <= 0) return;
      _items.add(CartItem(product: product, size: size, quantity: addQty));
    }
    notifyListeners();
    await _save();
  }

  Future<void> clearAndAdd(ApiProduct product, String size, {int quantity = 1}) async {
    _items.clear();
    _items.add(CartItem(product: product, size: size, quantity: quantity));
    notifyListeners();
    await _save();
  }

  Future<void> removeFromCart(CartItem item) async {
    _items.remove(item);
    notifyListeners();
    await _save();
  }

  Future<void> updateQuantity(CartItem item, int delta) async {
    final index = _items.indexOf(item);
    if (index != -1) {
      _items[index].quantity += delta;
      if (_items[index].quantity <= 0) {
        _items.removeAt(index);
      }
      notifyListeners();
      await _save();
    }
  }

  Future<void> setQuantity(ApiProduct product, int quantity) async {
    if (quantity <= 0) {
      _items.removeWhere((item) => item.product.id == product.id);
    } else {
      final index = _items.indexWhere((item) => item.product.id == product.id);
      if (index != -1) {
        _items[index].quantity = quantity;
      } else {
        _items.add(CartItem(product: product, size: product.size ?? '', quantity: quantity));
      }
    }
    notifyListeners();
    await _save();
  }

  Future<void> clearCart() async {
    _items.clear();
    notifyListeners();
    await _save();
  }
}
