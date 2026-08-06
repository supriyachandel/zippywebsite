class ApiProduct {
  final int id;
  final String name;
  final String price;
  final String discountPrice;
  final String quantity;
  final String? sku;
  final String? barcode;
  final String? weight;
  final String? size;
  final String? material;
  final String? color;
  final String? slug;
  final String? description;
  final String? image;
  final String? video;
  final List<String> imageUrls;
  final String status;
  final int subCategoryId;
  final int shopId;
  final int userId;
  final String gender;
  final String createdAt;
  final String updatedAt;
  final ApiUser? user;

  ApiProduct({
    required this.id,
    required this.name,
    required this.price,
    required this.discountPrice,
    required this.quantity,
    this.sku,
    this.barcode,
    this.weight,
    this.size,
    this.material,
    this.color,
    this.slug,
    this.description,
    this.image,
    this.video,
    this.imageUrls = const [],
    required this.status,
    required this.subCategoryId,
    required this.shopId,
    required this.userId,
    this.gender = 'unisex',
    required this.createdAt,
    required this.updatedAt,
    this.user,
  });

  factory ApiProduct.fromJson(Map<String, dynamic> json) {
    final rawUrls = json['image_urls'];
    final List<String> urls;
    if (rawUrls is List) {
      urls = rawUrls.map((e) => e?.toString() ?? '').where((s) => s.isNotEmpty).toList();
    } else {
      urls = [];
    }
    return ApiProduct(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      price: json['price'] ?? '0',
      discountPrice: json['discount_price'] ?? '0',
      quantity: json['quantity'] ?? '0',
      sku: json['sku'],
      barcode: json['barcode'],
      weight: json['weight'],
      size: json['size'],
      material: json['material'],
      color: json['color'],
      slug: json['slug'],
      description: json['description'],
      image: json['image'],
      video: json['video'],
      imageUrls: urls,
      status: json['status'] ?? 'active',
      subCategoryId: json['sub_category_id'] ?? 0,
      shopId: json['shop_id'] ?? 0,
      userId: json['user_id'] ?? 0,
      gender: (json['gender'] ?? 'unisex').toString(),
      createdAt: json['created_at'] ?? '',
      updatedAt: json['updated_at'] ?? '',
      user: json['user'] != null ? ApiUser.fromJson(json['user']) : null,
    );
  }

  String get displayImage => imageUrls.isNotEmpty ? imageUrls.first : (image ?? '');

  double get priceAsDouble => double.tryParse(price) ?? 0;
  double get discountPriceAsDouble => double.tryParse(discountPrice) ?? 0;
  int get quantityAsInt => int.tryParse(quantity) ?? 0;
  bool get isOutOfStock => quantityAsInt <= 0;
  bool get isLowStock => quantityAsInt > 0 && quantityAsInt <= 5;
}

class ApiCategory {
  final int id;
  final String categoryName;
  final String slug;
  final String? description;
  final String? image;
  final int? categoryId;
  final String gender;
  final String createdAt;
  final String updatedAt;

  ApiCategory({
    required this.id,
    required this.categoryName,
    required this.slug,
    this.description,
    this.image,
    this.categoryId,
    this.gender = 'unisex',
    required this.createdAt,
    required this.updatedAt,
  });

  factory ApiCategory.fromJson(Map<String, dynamic> json) {
    final name = (json['category_name'] ?? json['name'] ?? json['sub_category_name'] ?? '').toString();
    return ApiCategory(
      id: json['id'] ?? 0,
      categoryName: name,
      slug: json['slug'] ?? '',
      description: json['description'],
      image: json['image'],
      categoryId: json['category_id'] is int ? json['category_id'] as int? : (json['parent_id'] is int ? json['parent_id'] as int? : null),
      gender: (json['gender'] ?? 'unisex').toString(),
      createdAt: json['created_at'] ?? '',
      updatedAt: json['updated_at'] ?? '',
    );
  }
}

class ApiShop {
  final int id;
  final String name;
  final String slug;
  final String? description;
  final String? image;
  final String? video;
  final String status;
  final String? shopNumber;
  final String? gstNumber;
  final String? latitude;
  final String? longitude;
  final String? address;
  final String? city;
  final String? state;
  final String? zip;
  final String? country;
  final String? phone;
  final String? email;
  final String? website;
  final String? facebook;
  final String? twitter;
  final String? instagram;
  final String? linkedin;
  final int userId;
  final String createdAt;
  final String updatedAt;

  ApiShop({
    required this.id,
    required this.name,
    required this.slug,
    this.description,
    this.image,
    this.video,
    required this.status,
    this.shopNumber,
    this.gstNumber,
    this.latitude,
    this.longitude,
    this.address,
    this.city,
    this.state,
    this.zip,
    this.country,
    this.phone,
    this.email,
    this.website,
    this.facebook,
    this.twitter,
    this.instagram,
    this.linkedin,
    required this.userId,
    required this.createdAt,
    required this.updatedAt,
  });

  factory ApiShop.fromJson(Map<String, dynamic> json) {
    return ApiShop(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      slug: json['slug'] ?? '',
      description: json['description'],
      image: json['image'],
      video: json['video'],
      status: json['status'] ?? 'active',
      shopNumber: json['shop_number'],
      gstNumber: json['gst_number'],
      latitude: json['latitude'],
      longitude: json['longitude'],
      address: json['address'],
      city: json['city'],
      state: json['state'],
      zip: json['zip'],
      country: json['country'],
      phone: json['phone'],
      email: json['email'],
      website: json['website'],
      facebook: json['facebook'],
      twitter: json['twitter'],
      instagram: json['instagram'],
      linkedin: json['linkedin'],
      userId: json['user_id'] ?? 0,
      createdAt: json['created_at'] ?? '',
      updatedAt: json['updated_at'] ?? '',
    );
  }
}

class ApiUser {
  final int id;
  final String name;
  final String? username;
  final String email;
  final String? phone;
  final String? image;
  final String? address;
  final String? city;
  final String? zip;
  final String? state;
  final String? country;
  final String? role;
  final String? status;
  final String? adharcard;
  final String? pancard;
  final String? latitude;
  final String? longitude;
  final String? emailVerifiedAt;
  final String createdAt;
  final String updatedAt;

  ApiUser({
    required this.id,
    required this.name,
    this.username,
    required this.email,
    this.phone,
    this.image,
    this.address,
    this.city,
    this.zip,
    this.state,
    this.country,
    this.role,
    this.status,
    this.adharcard,
    this.pancard,
    this.latitude,
    this.longitude,
    this.emailVerifiedAt,
    required this.createdAt,
    required this.updatedAt,
  });

  factory ApiUser.fromJson(Map<String, dynamic> json) {
    return ApiUser(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      username: json['username'],
      email: json['email'] ?? '',
      phone: json['phone'],
      image: json['image'],
      address: json['address'],
      city: json['city'],
      zip: json['zip'],
      state: json['state'],
      country: json['country'],
      role: json['role'],
      status: json['status'],
      adharcard: json['adharcard'],
      pancard: json['pancard'],
      latitude: json['latitude'],
      longitude: json['longitude'],
      emailVerifiedAt: json['email_verified_at'],
      createdAt: json['created_at'] ?? '',
      updatedAt: json['updated_at'] ?? '',
    );
  }
}

class ApiPaymentMethod {
  final int id;
  final String name;
  final String type;
  final String? description;
  final String status;

  ApiPaymentMethod({
    required this.id,
    required this.name,
    required this.type,
    this.description,
    required this.status,
  });

  factory ApiPaymentMethod.fromJson(Map<String, dynamic> json) {
    return ApiPaymentMethod(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      type: json['type'] ?? '',
      description: json['description'],
      status: json['status'] ?? 'active',
    );
  }
}

class ApiAddress {
  final int id;
  final String label;
  final String name;
  final String phone;
  final String address;
  final String city;
  final String state;
  final String zip;
  final String? country;
  final bool isDefault;

  ApiAddress({
    required this.id,
    required this.label,
    required this.name,
    required this.phone,
    required this.address,
    required this.city,
    required this.state,
    required this.zip,
    this.country,
    this.isDefault = false,
  });

  factory ApiAddress.fromJson(Map<String, dynamic> json) {
    return ApiAddress(
      id: json['id'] ?? 0,
      label: json['label'] ?? '',
      name: json['name'] ?? '',
      phone: json['phone'] ?? '',
      address: json['address'] ?? '',
      city: json['city'] ?? '',
      state: json['state'] ?? '',
      zip: json['zip'] ?? '',
      country: json['country'],
      isDefault: json['is_default'] == true || json['is_default'] == 1,
    );
  }
}
