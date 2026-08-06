import 'dart:convert';

class SellerShop {
  final int id;
  final String name;
  final String? description;
  final String? shopNumber;
  final String? gstNumber;
  final String? address;
  final String? city;
  final String? state;
  final String? zip;
  final String? country;
  final String? phone;
  final String? email;
  final String? image;
  final String? status;

  SellerShop({
    required this.id,
    required this.name,
    this.description,
    this.shopNumber,
    this.gstNumber,
    this.address,
    this.city,
    this.state,
    this.zip,
    this.country,
    this.phone,
    this.email,
    this.image,
    this.status,
  });

  factory SellerShop.fromJson(Map<String, dynamic> json) {
    return SellerShop(
      id: int.tryParse(json['id']?.toString() ?? '0') ?? 0,
      name: json['name']?.toString() ?? '',
      description: json['description']?.toString(),
      shopNumber: json['shop_number']?.toString(),
      gstNumber: json['gst_number']?.toString(),
      address: json['address']?.toString(),
      city: json['city']?.toString(),
      state: json['state']?.toString(),
      zip: json['zip']?.toString(),
      country: json['country']?.toString(),
      phone: json['phone']?.toString(),
      email: json['email']?.toString(),
      image: json['image']?.toString(),
      status: json['status']?.toString(),
    );
  }
}

class StoreCategory {
  final String id;
  final String name;
  final String imageUrl;

  StoreCategory({
    required this.id,
    required this.name,
    required this.imageUrl,
  });
}

class StoreSubcategory {
  final String id;
  final String categoryId;
  final String name;

  StoreSubcategory({
    required this.id,
    required this.categoryId,
    required this.name,
  });
}

class StoreProduct {
  final String id;
  final String subcategoryId;
  final String name;
  final double price;
  final double discount;
  final int stockQuantity;
  final List<String> photos;
  final String description;
  final String fabric;
  final String washCare;
  final List<ProductVariant> variants;

  StoreProduct({
    required this.id,
    required this.subcategoryId,
    required this.name,
    required this.price,
    this.discount = 0.0,
    required this.stockQuantity,
    required this.photos,
    required this.description,
    required this.fabric,
    required this.washCare,
    required this.variants,
  });
}

class ProductVariant {
  final String id;
  final String color;
  final String size;
  final int stock;

  ProductVariant({
    required this.id,
    required this.color,
    required this.size,
    required this.stock,
  });
}
