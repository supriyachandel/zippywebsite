import '../models/api_models.dart';

class MockData {
  static bool useMock = true;

  static final List<ApiProduct> products = [
    ApiProduct.fromJson({
      "id": 1, "name": "Classic Cotton T-Shirt", "price": "1299", "discount_price": "799",
      "quantity": "50", "size": "M", "material": "Cotton", "color": "White",
      "description": "Premium quality cotton t-shirt with modern fit", "image": "dummy",
      "image_urls": ["https://images.unsplash.com/photo-1521572163474-6864f9cf17ab?w=400"],
      "sub_category_id": 1, "shop_id": 1, "user_id": 1, "gender": "male",
      "status": "active", "created_at": "2025-01-01T00:00:00.000000Z", "updated_at": "2025-01-01T00:00:00.000000Z",
    }),
    ApiProduct.fromJson({
      "id": 2, "name": "Floral Summer Dress", "price": "2499", "discount_price": "1499",
      "quantity": "30", "size": "S", "material": "Polyester", "color": "Blue",
      "description": "Beautiful floral print dress perfect for summer", "image": "dummy",
      "image_urls": ["https://images.unsplash.com/photo-1595777457583-95e059d581b8?w=400"],
      "sub_category_id": 2, "shop_id": 1, "user_id": 1, "gender": "female",
      "status": "active", "created_at": "2025-01-01T00:00:00.000000Z", "updated_at": "2025-01-01T00:00:00.000000Z",
    }),
    ApiProduct.fromJson({
      "id": 3, "name": "Denim Jacket", "price": "3999", "discount_price": "2499",
      "quantity": "20", "size": "L", "material": "Denim", "color": "Blue",
      "description": "Classic denim jacket with modern styling", "image": "dummy",
      "image_urls": ["https://images.unsplash.com/photo-1551028719-00167b16eac5?w=400"],
      "sub_category_id": 4, "shop_id": 2, "user_id": 1, "gender": "unisex",
      "status": "active", "created_at": "2025-01-01T00:00:00.000000Z", "updated_at": "2025-01-01T00:00:00.000000Z",
    }),
    ApiProduct.fromJson({
      "id": 4, "name": "Sports Running Shoes", "price": "5999", "discount_price": "3999",
      "quantity": "40", "size": "UK 8", "material": "Mesh", "color": "Black",
      "description": "Lightweight running shoes with cushioned sole", "image": "dummy",
      "image_urls": ["https://images.unsplash.com/photo-1542291026-7eec264c27ff?w=400"],
      "sub_category_id": 7, "shop_id": 2, "user_id": 1, "gender": "male",
      "status": "active", "created_at": "2025-01-01T00:00:00.000000Z", "updated_at": "2025-01-01T00:00:00.000000Z",
    }),
    ApiProduct.fromJson({
      "id": 5, "name": "Leather Handbag", "price": "4499", "discount_price": "2999",
      "quantity": "15", "size": "One Size", "material": "Leather", "color": "Brown",
      "description": "Genuine leather handbag with multiple compartments", "image": "dummy",
      "image_urls": ["https://images.unsplash.com/photo-1584917865442-de89df76afd3?w=400"],
      "sub_category_id": 10, "shop_id": 3, "user_id": 1, "gender": "female",
      "status": "active", "created_at": "2025-01-01T00:00:00.000000Z", "updated_at": "2025-01-01T00:00:00.000000Z",
    }),
    ApiProduct.fromJson({
      "id": 6, "name": "Casual Sneakers", "price": "3499", "discount_price": "1999",
      "quantity": "60", "size": "UK 9", "material": "Canvas", "color": "White",
      "description": "Comfortable casual sneakers for everyday wear", "image": "dummy",
      "image_urls": ["https://images.unsplash.com/photo-1595950653106-6c9ebd614d3a?w=400"],
      "sub_category_id": 7, "shop_id": 1, "user_id": 1, "gender": "unisex",
      "status": "active", "created_at": "2025-01-01T00:00:00.000000Z", "updated_at": "2025-01-01T00:00:00.000000Z",
    }),
    ApiProduct.fromJson({
      "id": 7, "name": "Kids Cartoon T-Shirt", "price": "699", "discount_price": "399",
      "quantity": "80", "size": "S", "material": "Cotton", "color": "Multi",
      "description": "Fun cartoon printed t-shirt for kids", "image": "dummy",
      "image_urls": ["https://images.unsplash.com/photo-1622290291468-a28f7a7dc6a8?w=400"],
      "sub_category_id": 1, "shop_id": 3, "user_id": 1, "gender": "kids",
      "status": "active", "created_at": "2025-01-01T00:00:00.000000Z", "updated_at": "2025-01-01T00:00:00.000000Z",
    }),
    ApiProduct.fromJson({
      "id": 8, "name": "Woolen Sweater", "price": "2999", "discount_price": "1999",
      "quantity": "25", "size": "XL", "material": "Wool", "color": "Grey",
      "description": "Warm woolen sweater for winter", "image": "dummy",
      "image_urls": ["https://images.unsplash.com/photo-1620799140408-edc6dcb6d633?w=400"],
      "sub_category_id": 5, "shop_id": 2, "user_id": 1, "gender": "male",
      "status": "active", "created_at": "2025-01-01T00:00:00.000000Z", "updated_at": "2025-01-01T00:00:00.000000Z",
    }),
    ApiProduct.fromJson({
      "id": 9, "name": "Silk Saree", "price": "8999", "discount_price": "5999",
      "quantity": "10", "size": "Free", "material": "Silk", "color": "Red",
      "description": "Elegant silk saree for special occasions", "image": "dummy",
      "image_urls": ["https://images.unsplash.com/photo-1610030469983-98e550d6193c?w=400"],
      "sub_category_id": 16, "shop_id": 3, "user_id": 1, "gender": "female",
      "status": "active", "created_at": "2025-01-01T00:00:00.000000Z", "updated_at": "2025-01-01T00:00:00.000000Z",
    }),
    ApiProduct.fromJson({
      "id": 10, "name": "Formal Blazer", "price": "6999", "discount_price": "4499",
      "quantity": "12", "size": "M", "material": "Polyester", "color": "Navy",
      "description": "Sharp formal blazer for office wear", "image": "dummy",
      "image_urls": ["https://images.unsplash.com/photo-1593030761757-71fae45fa0e7?w=400"],
      "sub_category_id": 4, "shop_id": 1, "user_id": 1, "gender": "male",
      "status": "active", "created_at": "2025-01-01T00:00:00.000000Z", "updated_at": "2025-01-01T00:00:00.000000Z",
    }),
    ApiProduct.fromJson({
      "id": 11, "name": "Slim Fit Jeans", "price": "2499", "discount_price": "1799",
      "quantity": "35", "size": "32", "material": "Denim", "color": "Dark Blue",
      "description": "Comfortable slim fit denim jeans", "image": "dummy",
      "image_urls": ["https://images.unsplash.com/photo-1542272454315-4c01d7abdf4a?w=400"],
      "sub_category_id": 3, "shop_id": 1, "user_id": 1, "gender": "male",
      "status": "active", "created_at": "2025-01-01T00:00:00.000000Z", "updated_at": "2025-01-01T00:00:00.000000Z",
    }),
    ApiProduct.fromJson({
      "id": 12, "name": "Cotton Shorts", "price": "999", "discount_price": "699",
      "quantity": "45", "size": "M", "material": "Cotton", "color": "Beige",
      "description": "Lightweight cotton shorts for summer", "image": "dummy",
      "image_urls": ["https://images.unsplash.com/photo-1591195853828-11db59a44f6b?w=400"],
      "sub_category_id": 6, "shop_id": 2, "user_id": 1, "gender": "female",
      "status": "active", "created_at": "2025-01-01T00:00:00.000000Z", "updated_at": "2025-01-01T00:00:00.000000Z",
    }),
    ApiProduct.fromJson({
      "id": 13, "name": "Leather Formal Shoes", "price": "4999", "discount_price": "3499",
      "quantity": "18", "size": "UK 9", "material": "Leather", "color": "Black",
      "description": "Premium leather formal shoes", "image": "dummy",
      "image_urls": ["https://images.unsplash.com/photo-1614252369475-531eba835eb1?w=400"],
      "sub_category_id": 8, "shop_id": 1, "user_id": 1, "gender": "male",
      "status": "active", "created_at": "2025-01-01T00:00:00.000000Z", "updated_at": "2025-01-01T00:00:00.000000Z",
    }),
    ApiProduct.fromJson({
      "id": 14, "name": "Analog Watch", "price": "2999", "discount_price": "1999",
      "quantity": "22", "size": "Free", "material": "Stainless Steel", "color": "Silver",
      "description": "Elegant analog watch with leather strap", "image": "dummy",
      "image_urls": ["https://images.unsplash.com/photo-1524592094714-0f0654e20314?w=400"],
      "sub_category_id": 11, "shop_id": 2, "user_id": 1, "gender": "unisex",
      "status": "active", "created_at": "2025-01-01T00:00:00.000000Z", "updated_at": "2025-01-01T00:00:00.000000Z",
    }),
    ApiProduct.fromJson({
      "id": 15, "name": "Aviator Sunglasses", "price": "1999", "discount_price": "999",
      "quantity": "30", "size": "One Size", "material": "Polycarbonate", "color": "Black",
      "description": "Trendy aviator sunglasses with UV protection", "image": "dummy",
      "image_urls": ["https://images.unsplash.com/photo-1572635196237-14b3f281503f?w=400"],
      "sub_category_id": 12, "shop_id": 3, "user_id": 1, "gender": "unisex",
      "status": "active", "created_at": "2025-01-01T00:00:00.000000Z", "updated_at": "2025-01-01T00:00:00.000000Z",
    }),
    ApiProduct.fromJson({
      "id": 16, "name": "Gold Plated Necklace", "price": "5999", "discount_price": "3999",
      "quantity": "8", "size": "Free", "material": "Gold Plated", "color": "Gold",
      "description": "Beautiful gold plated necklace set", "image": "dummy",
      "image_urls": ["https://images.unsplash.com/photo-1515562141589-677acb0d1fb2?w=400"],
      "sub_category_id": 13, "shop_id": 1, "user_id": 1, "gender": "female",
      "status": "active", "created_at": "2025-01-01T00:00:00.000000Z", "updated_at": "2025-01-01T00:00:00.000000Z",
    }),
    ApiProduct.fromJson({
      "id": 17, "name": "Men's Kurta Pajama", "price": "2999", "discount_price": "1999",
      "quantity": "15", "size": "L", "material": "Cotton", "color": "White",
      "description": "Traditional cotton kurta pajama set", "image": "dummy",
      "image_urls": ["https://images.unsplash.com/photo-1598965402086-897c3241ea61?w=400"],
      "sub_category_id": 17, "shop_id": 2, "user_id": 1, "gender": "male",
      "status": "active", "created_at": "2025-01-01T00:00:00.000000Z", "updated_at": "2025-01-01T00:00:00.000000Z",
    }),
    ApiProduct.fromJson({
      "id": 18, "name": "Designer Lehenga", "price": "14999", "discount_price": "9999",
      "quantity": "5", "size": "M", "material": "Silk", "color": "Pink",
      "description": "Designer wedding lehenga with embroidery", "image": "dummy",
      "image_urls": ["https://images.unsplash.com/photo-1610030469629-b0ce4b10e7b8?w=400"],
      "sub_category_id": 18, "shop_id": 3, "user_id": 1, "gender": "female",
      "status": "active", "created_at": "2025-01-01T00:00:00.000000Z", "updated_at": "2025-01-01T00:00:00.000000Z",
    }),
    ApiProduct.fromJson({
      "id": 19, "name": "Gym T-Shirt", "price": "899", "discount_price": "599",
      "quantity": "50", "size": "L", "material": "Polyester", "color": "Grey",
      "description": "Breathable gym t-shirt for workouts", "image": "dummy",
      "image_urls": ["https://images.unsplash.com/photo-1571019613454-1cb2f99b2d8b?w=400"],
      "sub_category_id": 19, "shop_id": 1, "user_id": 1, "gender": "unisex",
      "status": "active", "created_at": "2025-01-01T00:00:00.000000Z", "updated_at": "2025-01-01T00:00:00.000000Z",
    }),
    ApiProduct.fromJson({
      "id": 20, "name": "Kids Casual Shoes", "price": "1499", "discount_price": "999",
      "quantity": "25", "size": "UK 12", "material": "Canvas", "color": "Blue",
      "description": "Comfortable casual shoes for kids", "image": "dummy",
      "image_urls": ["https://images.unsplash.com/photo-1593095948071-474c5cc2c1cf?w=400"],
      "sub_category_id": 15, "shop_id": 3, "user_id": 1, "gender": "kids",
      "status": "active", "created_at": "2025-01-01T00:00:00.000000Z", "updated_at": "2025-01-01T00:00:00.000000Z",
    }),
    ApiProduct.fromJson({
      "id": 21, "name": "Yoga Mat", "price": "1999", "discount_price": "1499",
      "quantity": "20", "size": "6mm", "material": "TPE", "color": "Purple",
      "description": "Non-slip yoga mat with carrying strap", "image": "dummy",
      "image_urls": ["https://images.unsplash.com/photo-1544367567-0f2fcb009e0b?w=400"],
      "sub_category_id": 20, "shop_id": 2, "user_id": 1, "gender": "unisex",
      "status": "active", "created_at": "2025-01-01T00:00:00.000000Z", "updated_at": "2025-01-01T00:00:00.000000Z",
    }),
    ApiProduct.fromJson({
      "id": 22, "name": "Face Moisturizer", "price": "799", "discount_price": "499",
      "quantity": "40", "size": "50ml", "material": "Cream", "color": "White",
      "description": "Hydrating face moisturizer for all skin types", "image": "dummy",
      "image_urls": ["https://images.unsplash.com/photo-1556228578-0d85b1a4d571?w=400"],
      "sub_category_id": 21, "shop_id": 1, "user_id": 1, "gender": "female",
      "status": "active", "created_at": "2025-01-01T00:00:00.000000Z", "updated_at": "2025-01-01T00:00:00.000000Z",
    }),
    ApiProduct.fromJson({
      "id": 23, "name": "Scented Candle Set", "price": "1299", "discount_price": "899",
      "quantity": "30", "size": "Set of 3", "material": "Wax", "color": "Beige",
      "description": "Hand-poured scented candle gift set", "image": "dummy",
      "image_urls": ["https://images.unsplash.com/photo-1586023492125-27b2c045efd7?w=400"],
      "sub_category_id": 23, "shop_id": 3, "user_id": 1, "gender": "unisex",
      "status": "active", "created_at": "2025-01-01T00:00:00.000000Z", "updated_at": "2025-01-01T00:00:00.000000Z",
    }),
    ApiProduct.fromJson({
      "id": 24, "name": "Cotton Bedsheet", "price": "2499", "discount_price": "1499",
      "quantity": "20", "size": "Queen", "material": "Cotton", "color": "White",
      "description": "Premium quality cotton bedsheet set", "image": "dummy",
      "image_urls": ["https://images.unsplash.com/photo-1616627547584-bf28cee262db?w=400"],
      "sub_category_id": 24, "shop_id": 2, "user_id": 1, "gender": "unisex",
      "status": "active", "created_at": "2025-01-01T00:00:00.000000Z", "updated_at": "2025-01-01T00:00:00.000000Z",
    }),
  ];

  static final List<ApiCategory> categories = [
    ApiCategory.fromJson({
      "id": 1, "category_name": "Clothing", "slug": "clothing",
      "description": "All clothing items", "image": "https://images.unsplash.com/photo-1556905055-8f358a7a47b2?w=200",
      "category_id": null, "gender": "unisex",
      "created_at": "2025-01-01T00:00:00.000000Z", "updated_at": "2025-01-01T00:00:00.000000Z",
    }),
    ApiCategory.fromJson({
      "id": 2, "category_name": "Footwear", "slug": "footwear",
      "description": "Shoes and sneakers", "image": "https://images.unsplash.com/photo-1542291026-7eec264c27ff?w=200",
      "category_id": null, "gender": "unisex",
      "created_at": "2025-01-01T00:00:00.000000Z", "updated_at": "2025-01-01T00:00:00.000000Z",
    }),
    ApiCategory.fromJson({
      "id": 3, "category_name": "Accessories", "slug": "accessories",
      "description": "Bags, belts, and more", "image": "https://images.unsplash.com/photo-1601924582970-9238bcb495d9?w=200",
      "category_id": null, "gender": "unisex",
      "created_at": "2025-01-01T00:00:00.000000Z", "updated_at": "2025-01-01T00:00:00.000000Z",
    }),
    ApiCategory.fromJson({
      "id": 4, "category_name": "Kids Wear", "slug": "kids-wear",
      "description": "Clothing for kids", "image": "https://images.unsplash.com/photo-1622290291468-a28f7a7dc6a8?w=200",
      "category_id": null, "gender": "kids",
      "created_at": "2025-01-01T00:00:00.000000Z", "updated_at": "2025-01-01T00:00:00.000000Z",
    }),
    ApiCategory.fromJson({
      "id": 5, "category_name": "Ethnic Wear", "slug": "ethnic-wear",
      "description": "Traditional Indian clothing", "image": "https://images.unsplash.com/photo-1585487000160-6ebcfceb0d03?w=200",
      "category_id": null, "gender": "unisex",
      "created_at": "2025-01-01T00:00:00.000000Z", "updated_at": "2025-01-01T00:00:00.000000Z",
    }),
    ApiCategory.fromJson({
      "id": 6, "category_name": "Sports & Active", "slug": "sports",
      "description": "Activewear and sports gear", "image": "https://images.unsplash.com/photo-1571019614242-c5c5dee9f50b?w=200",
      "category_id": null, "gender": "unisex",
      "created_at": "2025-01-01T00:00:00.000000Z", "updated_at": "2025-01-01T00:00:00.000000Z",
    }),
    ApiCategory.fromJson({
      "id": 7, "category_name": "Beauty", "slug": "beauty",
      "description": "Beauty and personal care", "image": "https://images.unsplash.com/photo-1596462502278-27bfdc403348?w=200",
      "category_id": null, "gender": "female",
      "created_at": "2025-01-01T00:00:00.000000Z", "updated_at": "2025-01-01T00:00:00.000000Z",
    }),
    ApiCategory.fromJson({
      "id": 8, "category_name": "Home & Living", "slug": "home-living",
      "description": "Home decor and lifestyle", "image": "https://images.unsplash.com/photo-1586023492125-27b2c045efd7?w=200",
      "category_id": null, "gender": "unisex",
      "created_at": "2025-01-01T00:00:00.000000Z", "updated_at": "2025-01-01T00:00:00.000000Z",
    }),
  ];

  static final List<ApiCategory> subCategories = [
    ApiCategory.fromJson({
      "id": 1, "category_name": "T-Shirts", "slug": "tshirts", "description": "Casual t-shirts",
      "image": "https://images.unsplash.com/photo-1521572163474-6864f9cf17ab?w=200",
      "category_id": 1, "gender": "unisex",
      "created_at": "2025-01-01T00:00:00.000000Z", "updated_at": "2025-01-01T00:00:00.000000Z",
    }),
    ApiCategory.fromJson({
      "id": 2, "category_name": "Dresses & Kurtis", "slug": "dresses", "description": "Dresses and kurtis",
      "image": "https://images.unsplash.com/photo-1595777457583-95e059d581b8?w=200",
      "category_id": 1, "gender": "female",
      "created_at": "2025-01-01T00:00:00.000000Z", "updated_at": "2025-01-01T00:00:00.000000Z",
    }),
    ApiCategory.fromJson({
      "id": 3, "category_name": "Jeans", "slug": "jeans", "description": "Denim jeans for everyone",
      "image": "https://images.unsplash.com/photo-1542272454315-4c01d7abdf4a?w=200",
      "category_id": 1, "gender": "unisex",
      "created_at": "2025-01-01T00:00:00.000000Z", "updated_at": "2025-01-01T00:00:00.000000Z",
    }),
    ApiCategory.fromJson({
      "id": 4, "category_name": "Jackets & Blazers", "slug": "jackets", "description": "Jackets and blazers",
      "image": "https://images.unsplash.com/photo-1551028719-00167b16eac5?w=200",
      "category_id": 1, "gender": "unisex",
      "created_at": "2025-01-01T00:00:00.000000Z", "updated_at": "2025-01-01T00:00:00.000000Z",
    }),
    ApiCategory.fromJson({
      "id": 5, "category_name": "Winter Wear", "slug": "winter", "description": "Sweaters and hoodies",
      "image": "https://images.unsplash.com/photo-1620799140408-edc6dcb6d633?w=200",
      "category_id": 1, "gender": "unisex",
      "created_at": "2025-01-01T00:00:00.000000Z", "updated_at": "2025-01-01T00:00:00.000000Z",
    }),
    ApiCategory.fromJson({
      "id": 6, "category_name": "Shorts & Skirts", "slug": "shorts", "description": "Shorts and skirts",
      "image": "https://images.unsplash.com/photo-1591195853828-11db59a44f6b?w=200",
      "category_id": 1, "gender": "female",
      "created_at": "2025-01-01T00:00:00.000000Z", "updated_at": "2025-01-01T00:00:00.000000Z",
    }),
    ApiCategory.fromJson({
      "id": 7, "category_name": "Sneakers", "slug": "sneakers", "description": "Sports and casual shoes",
      "image": "https://images.unsplash.com/photo-1542291026-7eec264c27ff?w=200",
      "category_id": 2, "gender": "unisex",
      "created_at": "2025-01-01T00:00:00.000000Z", "updated_at": "2025-01-01T00:00:00.000000Z",
    }),
    ApiCategory.fromJson({
      "id": 8, "category_name": "Formal Shoes", "slug": "formal-shoes", "description": "Formal footwear",
      "image": "https://images.unsplash.com/photo-1614252369475-531eba835eb1?w=200",
      "category_id": 2, "gender": "male",
      "created_at": "2025-01-01T00:00:00.000000Z", "updated_at": "2025-01-01T00:00:00.000000Z",
    }),
    ApiCategory.fromJson({
      "id": 9, "category_name": "Sandals & Flip Flops", "slug": "sandals", "description": "Casual summer footwear",
      "image": "https://images.unsplash.com/photo-1603481588273-2f908a9a7a1b?w=200",
      "category_id": 2, "gender": "unisex",
      "created_at": "2025-01-01T00:00:00.000000Z", "updated_at": "2025-01-01T00:00:00.000000Z",
    }),
    ApiCategory.fromJson({
      "id": 10, "category_name": "Bags & Backpacks", "slug": "bags", "description": "Handbags and backpacks",
      "image": "https://images.unsplash.com/photo-1584917865442-de89df76afd3?w=200",
      "category_id": 3, "gender": "female",
      "created_at": "2025-01-01T00:00:00.000000Z", "updated_at": "2025-01-01T00:00:00.000000Z",
    }),
    ApiCategory.fromJson({
      "id": 11, "category_name": "Watches", "slug": "watches", "description": "Stylish watches",
      "image": "https://images.unsplash.com/photo-1524592094714-0f0654e20314?w=200",
      "category_id": 3, "gender": "unisex",
      "created_at": "2025-01-01T00:00:00.000000Z", "updated_at": "2025-01-01T00:00:00.000000Z",
    }),
    ApiCategory.fromJson({
      "id": 12, "category_name": "Sunglasses", "slug": "sunglasses", "description": "Trendy eyewear",
      "image": "https://images.unsplash.com/photo-1572635196237-14b3f281503f?w=200",
      "category_id": 3, "gender": "unisex",
      "created_at": "2025-01-01T00:00:00.000000Z", "updated_at": "2025-01-01T00:00:00.000000Z",
    }),
    ApiCategory.fromJson({
      "id": 13, "category_name": "Jewelry", "slug": "jewelry", "description": "Necklaces, earrings, rings",
      "image": "https://images.unsplash.com/photo-1515562141589-677acb0d1fb2?w=200",
      "category_id": 3, "gender": "female",
      "created_at": "2025-01-01T00:00:00.000000Z", "updated_at": "2025-01-01T00:00:00.000000Z",
    }),
    ApiCategory.fromJson({
      "id": 14, "category_name": "Kids Clothing", "slug": "kids-clothing", "description": "Clothes for kids",
      "image": "https://images.unsplash.com/photo-1622290291468-a28f7a7dc6a8?w=200",
      "category_id": 4, "gender": "kids",
      "created_at": "2025-01-01T00:00:00.000000Z", "updated_at": "2025-01-01T00:00:00.000000Z",
    }),
    ApiCategory.fromJson({
      "id": 15, "category_name": "Kids Shoes", "slug": "kids-shoes", "description": "Footwear for kids",
      "image": "https://images.unsplash.com/photo-1593095948071-474c5cc2c1cf?w=200",
      "category_id": 4, "gender": "kids",
      "created_at": "2025-01-01T00:00:00.000000Z", "updated_at": "2025-01-01T00:00:00.000000Z",
    }),
    ApiCategory.fromJson({
      "id": 16, "category_name": "Sarees", "slug": "sarees", "description": "Traditional sarees",
      "image": "https://images.unsplash.com/photo-1610030469983-98e550d6193c?w=200",
      "category_id": 5, "gender": "female",
      "created_at": "2025-01-01T00:00:00.000000Z", "updated_at": "2025-01-01T00:00:00.000000Z",
    }),
    ApiCategory.fromJson({
      "id": 17, "category_name": "Kurta Pajamas", "slug": "kurta", "description": "Men's ethnic wear",
      "image": "https://images.unsplash.com/photo-1598965402086-897c3241ea61?w=200",
      "category_id": 5, "gender": "male",
      "created_at": "2025-01-01T00:00:00.000000Z", "updated_at": "2025-01-01T00:00:00.000000Z",
    }),
    ApiCategory.fromJson({
      "id": 18, "category_name": "Lehengas", "slug": "lehengas", "description": "Wedding and party lehengas",
      "image": "https://images.unsplash.com/photo-1610030469629-b0ce4b10e7b8?w=200",
      "category_id": 5, "gender": "female",
      "created_at": "2025-01-01T00:00:00.000000Z", "updated_at": "2025-01-01T00:00:00.000000Z",
    }),
    ApiCategory.fromJson({
      "id": 19, "category_name": "Sportswear", "slug": "sportswear", "description": "Activewear and gym wear",
      "image": "https://images.unsplash.com/photo-1571019613454-1cb2f99b2d8b?w=200",
      "category_id": 6, "gender": "unisex",
      "created_at": "2025-01-01T00:00:00.000000Z", "updated_at": "2025-01-01T00:00:00.000000Z",
    }),
    ApiCategory.fromJson({
      "id": 20, "category_name": "Yoga & Gym", "slug": "yoga", "description": "Yoga mats and gym equipment",
      "image": "https://images.unsplash.com/photo-1544367567-0f2fcb009e0b?w=200",
      "category_id": 6, "gender": "unisex",
      "created_at": "2025-01-01T00:00:00.000000Z", "updated_at": "2025-01-01T00:00:00.000000Z",
    }),
    ApiCategory.fromJson({
      "id": 21, "category_name": "Skincare", "slug": "skincare", "description": "Face and body care",
      "image": "https://images.unsplash.com/photo-1556228578-0d85b1a4d571?w=200",
      "category_id": 7, "gender": "female",
      "created_at": "2025-01-01T00:00:00.000000Z", "updated_at": "2025-01-01T00:00:00.000000Z",
    }),
    ApiCategory.fromJson({
      "id": 22, "category_name": "Makeup", "slug": "makeup", "description": "Cosmetics and makeup",
      "image": "https://images.unsplash.com/photo-1596462502278-27bfdc403348?w=200",
      "category_id": 7, "gender": "female",
      "created_at": "2025-01-01T00:00:00.000000Z", "updated_at": "2025-01-01T00:00:00.000000Z",
    }),
    ApiCategory.fromJson({
      "id": 23, "category_name": "Home Decor", "slug": "home-decor", "description": "Decorative items for home",
      "image": "https://images.unsplash.com/photo-1586023492125-27b2c045efd7?w=200",
      "category_id": 8, "gender": "unisex",
      "created_at": "2025-01-01T00:00:00.000000Z", "updated_at": "2025-01-01T00:00:00.000000Z",
    }),
    ApiCategory.fromJson({
      "id": 24, "category_name": "Bed & Bath", "slug": "bed-bath", "description": "Bedding and bathroom essentials",
      "image": "https://images.unsplash.com/photo-1616627547584-bf28cee262db?w=200",
      "category_id": 8, "gender": "unisex",
      "created_at": "2025-01-01T00:00:00.000000Z", "updated_at": "2025-01-01T00:00:00.000000Z",
    }),
    ApiCategory.fromJson({
      "id": 25, "category_name": "Sports Shoes", "slug": "sports-shoes", "description": "Performance athletic footwear",
      "image": "https://images.unsplash.com/photo-1595950653106-6c9ebd614d3a?w=200",
      "category_id": 2, "gender": "unisex",
      "created_at": "2025-01-01T00:00:00.000000Z", "updated_at": "2025-01-01T00:00:00.000000Z",
    }),
    ApiCategory.fromJson({
      "id": 26, "category_name": "Heels & Wedges", "slug": "heels", "description": "Party and formal heels",
      "image": "https://images.unsplash.com/photo-1543163521-1bf539c55dd2?w=200",
      "category_id": 2, "gender": "female",
      "created_at": "2025-01-01T00:00:00.000000Z", "updated_at": "2025-01-01T00:00:00.000000Z",
    }),
    ApiCategory.fromJson({
      "id": 27, "category_name": "Toys & Games", "slug": "toys", "description": "Fun toys and board games",
      "image": "https://images.unsplash.com/photo-1515488042361-ee00e0ddd4e4?w=200",
      "category_id": 4, "gender": "kids",
      "created_at": "2025-01-01T00:00:00.000000Z", "updated_at": "2025-01-01T00:00:00.000000Z",
    }),
    ApiCategory.fromJson({
      "id": 28, "category_name": "Kids Accessories", "slug": "kids-accessories", "description": "Hats, belts, and more",
      "image": "https://images.unsplash.com/photo-1566576912327-6eec4c734fdb?w=200",
      "category_id": 4, "gender": "kids",
      "created_at": "2025-01-01T00:00:00.000000Z", "updated_at": "2025-01-01T00:00:00.000000Z",
    }),
    ApiCategory.fromJson({
      "id": 29, "category_name": "Sports Equipment", "slug": "sports-equipment", "description": "Cricket bats, balls, and more",
      "image": "https://images.unsplash.com/photo-1530541115426-315e9e1d6612?w=200",
      "category_id": 6, "gender": "unisex",
      "created_at": "2025-01-01T00:00:00.000000Z", "updated_at": "2025-01-01T00:00:00.000000Z",
    }),
    ApiCategory.fromJson({
      "id": 30, "category_name": "Cycling", "slug": "cycling", "description": "Cycles and cycling gear",
      "image": "https://images.unsplash.com/photo-1576435728678-68d0fbf94e4e?w=200",
      "category_id": 6, "gender": "unisex",
      "created_at": "2025-01-01T00:00:00.000000Z", "updated_at": "2025-01-01T00:00:00.000000Z",
    }),
    ApiCategory.fromJson({
      "id": 31, "category_name": "Hair Care", "slug": "hair-care", "description": "Shampoos, oils, and styling",
      "image": "https://images.unsplash.com/photo-1560066984-138dadb4c035?w=200",
      "category_id": 7, "gender": "female",
      "created_at": "2025-01-01T00:00:00.000000Z", "updated_at": "2025-01-01T00:00:00.000000Z",
    }),
    ApiCategory.fromJson({
      "id": 32, "category_name": "Fragrances", "slug": "fragrances", "description": "Perfumes and deodorants",
      "image": "https://images.unsplash.com/photo-1541643600914-78b084683601?w=200",
      "category_id": 7, "gender": "unisex",
      "created_at": "2025-01-01T00:00:00.000000Z", "updated_at": "2025-01-01T00:00:00.000000Z",
    }),
    ApiCategory.fromJson({
      "id": 33, "category_name": "Kitchen & Dining", "slug": "kitchen", "description": "Cookware and tableware",
      "image": "https://images.unsplash.com/photo-1556909114-f6e7ad7d3136?w=200",
      "category_id": 8, "gender": "unisex",
      "created_at": "2025-01-01T00:00:00.000000Z", "updated_at": "2025-01-01T00:00:00.000000Z",
    }),
    ApiCategory.fromJson({
      "id": 34, "category_name": "Lighting", "slug": "lighting", "description": "Lamps, bulbs, and string lights",
      "image": "https://images.unsplash.com/photo-1513506003901-1e6a229e2d15?w=200",
      "category_id": 8, "gender": "unisex",
      "created_at": "2025-01-01T00:00:00.000000Z", "updated_at": "2025-01-01T00:00:00.000000Z",
    }),
  ];

  static final List<ApiShop> shops = [
    ApiShop.fromJson({
      "id": 1, "name": "Fashion Hub", "slug": "fashion-hub",
      "description": "Your one-stop fashion destination", "image": "dummy",
      "status": "active", "shop_number": "SH-101",
      "address": "MG Road, Indiranagar", "city": "Bengaluru", "state": "Karnataka",
      "zip": "560038", "country": "India", "phone": "9876543210",
      "email": "fashionhub@example.com",
      "instagram": "@fashionhub", "user_id": 1,
      "created_at": "2025-01-01T00:00:00.000000Z", "updated_at": "2025-01-01T00:00:00.000000Z",
    }),
    ApiShop.fromJson({
      "id": 2, "name": "Urban Threads", "slug": "urban-threads",
      "description": "Trendy urban wear", "image": "dummy",
      "status": "active", "shop_number": "SH-202",
      "address": "Koramangala 5th Block", "city": "Bengaluru", "state": "Karnataka",
      "zip": "560095", "country": "India", "phone": "9876543211",
      "email": "urban@example.com",
      "instagram": "@urbanthreads", "user_id": 1,
      "created_at": "2025-01-01T00:00:00.000000Z", "updated_at": "2025-01-01T00:00:00.000000Z",
    }),
    ApiShop.fromJson({
      "id": 3, "name": "Style Studio", "slug": "style-studio",
      "description": "Premium fashion boutique", "image": "dummy",
      "status": "active", "shop_number": "SH-303",
      "address": "Commercial Street", "city": "Bengaluru", "state": "Karnataka",
      "zip": "560001", "country": "India", "phone": "9876543212",
      "email": "style@example.com",
      "instagram": "@stylestudio", "user_id": 1,
      "created_at": "2025-01-01T00:00:00.000000Z", "updated_at": "2025-01-01T00:00:00.000000Z",
    }),
  ];

  static final List<ApiAddress> addresses = [
    ApiAddress.fromJson({
      "id": 1, "label": "Home", "name": "Tanya", "phone": "9876543210",
      "address": "123, MG Road, Indiranagar", "city": "Bengaluru",
      "state": "Karnataka", "zip": "560038", "country": "India", "is_default": true,
    }),
    ApiAddress.fromJson({
      "id": 2, "label": "Work", "name": "Tanya", "phone": "9876543210",
      "address": "456, Koramangala 5th Block", "city": "Bengaluru",
      "state": "Karnataka", "zip": "560095", "country": "India", "is_default": false,
    }),
  ];

  static final List<ApiPaymentMethod> paymentMethods = [
    ApiPaymentMethod.fromJson({
      "id": 1, "name": "Razorpay", "type": "online",
      "description": "Pay via UPI, Card, Net Banking", "status": "active",
    }),
    ApiPaymentMethod.fromJson({
      "id": 2, "name": "Cash on Delivery", "type": "cod",
      "description": "Pay when you receive", "status": "active",
    }),
  ];

  static Map<String, dynamic> get userData => {
    "id": 1, "name": "Tanya", "email": "tanya@example.com", "phone": "9876543210",
    "image": null, "address": "123, MG Road", "city": "Bengaluru",
    "zip": "560038", "state": "Karnataka", "country": "India",
    "role": "user", "status": "active",
    "created_at": "2025-01-01T00:00:00.000000Z", "updated_at": "2025-01-01T00:00:00.000000Z",
  };

  static Map<String, dynamic> get loginResponse => {
    "token": "mock_token_12345",
    "user": userData,
  };

  static Map<String, dynamic> get registerResponse => {
    "token": "mock_token_12345",
    "user": userData,
  };

  static List<Map<String, dynamic>> purchases = [];

  static Map<String, dynamic> _productToMap(ApiProduct p) {
    return {
      'id': p.id,
      'name': p.name,
      'price': p.price,
      'discount_price': p.discountPrice,
      'quantity': p.quantity,
      'size': p.size,
      'material': p.material,
      'color': p.color,
      'description': p.description,
      'image': p.image,
      'image_urls': p.imageUrls,
      'sub_category_id': p.subCategoryId,
      'shop_id': p.shopId,
      'user_id': p.userId,
      'gender': p.gender,
      'status': p.status,
      'created_at': p.createdAt,
      'updated_at': p.updatedAt,
    };
  }

  static void addPurchase(Map<String, dynamic> data) {
    final id = purchases.length + 1;
    final purchase = Map<String, dynamic>.from(data);
    purchase['id'] = id;
    purchase['user_id'] = 1;
    purchase['status'] = 'placed';
    purchase['created_at'] = DateTime.now().toIso8601String();
    purchase['updated_at'] = DateTime.now().toIso8601String();
    purchase['total_paid_price'] = (data['products'] as List<dynamic>).fold<double>(
      0, (sum, p) => sum + (p['paid_price'] as num).toDouble(),
    ).toString();
    purchase['payment_method'] = data['payment_method_id'] == 1
        ? {'id': 1, 'name': 'Razorpay', 'type': 'online', 'description': 'Pay via UPI, Card, Net Banking'}
        : {'id': 2, 'name': 'Cash on Delivery', 'type': 'cod', 'description': 'Pay when you receive'};
    purchase['purchased_products'] = (data['products'] as List<dynamic>).map((p) {
      final product = products.firstWhere(
        (pr) => pr.id == p['product_id'],
        orElse: () => products.first,
      );
      final prodMap = _productToMap(product);
      prodMap['image_url'] = (prodMap['image_urls'] as List).isNotEmpty ? (prodMap['image_urls'] as List).first : null;
      return {
        'product': prodMap,
        'price': p['price'],
        'paid_price': p['paid_price'],
      };
    }).toList();
    purchases.add(purchase);
  }

  static void seedSamplePurchases() {
    if (purchases.isNotEmpty) return;
    final now = DateTime.now();
    final sampleProducts = products.take(4).toList();
    final sampleData = <String, dynamic>{
      'address_id': 1,
      'payment_method_id': 2,
      'latitude': 19.0760,
      'longitude': 72.8777,
      'products': sampleProducts.map((p) => {
        'product_id': p.id,
        'price': p.priceAsDouble,
        'paid_price': p.discountPriceAsDouble > 0 ? p.discountPriceAsDouble : p.priceAsDouble,
      }).toList(),
    };
    for (var i = 0; i < 3; i++) {
      final purchase = Map<String, dynamic>.from(sampleData);
      final id = i + 1;
      purchase['id'] = id;
      purchase['user_id'] = 1;
      purchase['status'] = i == 0 ? 'delivered' : (i == 1 ? 'shipped' : 'processing');
      purchase['created_at'] = now.subtract(Duration(days: [10, 5, 2][i])).toIso8601String();
      purchase['updated_at'] = now.subtract(Duration(days: [8, 3, 1][i])).toIso8601String();
      final total = sampleProducts.fold<double>(0, (sum, p) => sum + (p.discountPriceAsDouble > 0 ? p.discountPriceAsDouble : p.priceAsDouble));
      purchase['total_paid_price'] = total.toString();
      purchase['payment_method'] = {'id': 2, 'name': 'Cash on Delivery', 'type': 'cod', 'description': 'Pay when you receive'};
      purchase['purchased_products'] = sampleProducts.map((p) {
        final prodMap = _productToMap(p);
        prodMap['image_url'] = (prodMap['image_urls'] as List).isNotEmpty ? (prodMap['image_urls'] as List).first : null;
        return {
          'product': prodMap,
          'price': p.priceAsDouble,
          'paid_price': p.discountPriceAsDouble > 0 ? p.discountPriceAsDouble : p.priceAsDouble,
        };
      }).toList();
      purchases.add(purchase);
    }
  }

  static List<ApiProduct> getProductsForShop(int shopId) {
    return products.where((p) => p.shopId == shopId).toList();
  }

  static List<ApiProduct> getProductsBySubCategory(int subCategoryId) {
    return products.where((p) => p.subCategoryId == subCategoryId).toList();
  }
}
