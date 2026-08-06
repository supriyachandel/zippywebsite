class Product {
  final String id;
  final String name;
  final String shopId;
  final String shopName;
  final double price;
  final double floorPrice;
  final String imageUrl;
  final List<String> availableColors;
  final List<String> sizes;
  final String category;
  final String gender; // 'men', 'women', 'kids'
  final String subCategory; // 'clothes', 'shoes'

  Product({
    required this.id,
    required this.name,
    required this.shopId,
    required this.shopName,
    required this.price,
    required this.floorPrice,
    required this.imageUrl,
    required this.availableColors,
    required this.sizes,
    required this.category,
    required this.gender,
    required this.subCategory,
  });
}

class Shop {
  final String id;
  final String name;
  final String distance;
  final List<String> tags;
  final String imageUrl;
  final double rating;
  final String description;

  Shop({
    required this.id,
    required this.name,
    required this.distance,
    required this.tags,
    required this.imageUrl,
    required this.rating,
    required this.description,
  });
}

final List<Shop> mockShops = [
  Shop(
    id: 's1',
    name: 'Sagar Footwear',
    distance: '0.8 km',
    tags: ['Shoes', 'Streetwear'],
    imageUrl: 'https://images.unsplash.com/photo-1542291026-7eec264c27ff',
    rating: 4.5,
    description: 'Best footwear collection in Indiranagar. From sports to casuals.',
  ),
  Shop(
    id: 's2',
    name: 'Ethnic Elegance',
    distance: '1.2 km',
    tags: ['Ethnic', 'Wedding'],
    imageUrl: 'https://images.unsplash.com/photo-1585487000160-6ebcfceb0d03',
    rating: 4.8,
    description: 'Luxury ethnic wear for all occasions. Specialized in designer kurtas.',
  ),
  Shop(
    id: 's3',
    name: 'Trend Setters',
    distance: '2.5 km',
    tags: ['Western', 'Casual'],
    imageUrl: 'https://images.unsplash.com/photo-1441986300917-64674bd600d8',
    rating: 4.2,
    description: 'Latest western trends at affordable prices. New arrivals every week.',
  ),
];

final List<Product> mockProducts = [
  // Sagar Footwear (Shoes)
  Product(
    id: 'p1',
    name: 'Volt Runner Sneakers',
    shopId: 's1',
    shopName: 'Sagar Footwear',
    price: 2499,
    floorPrice: 1800,
    imageUrl: 'https://images.unsplash.com/photo-1542291026-7eec264c27ff',
    availableColors: ['#E2FB4D', '#121212', '#FFFFFF'],
    sizes: ['UK 7', 'UK 8', 'UK 9', 'UK 10'],
    category: 'Sneakers',
    gender: 'men',
    subCategory: 'shoes',
  ),
  Product(
    id: 'p4',
    name: 'Classic Leather Boots',
    shopId: 's1',
    shopName: 'Sagar Footwear',
    price: 3999,
    floorPrice: 3200,
    imageUrl: 'https://images.unsplash.com/photo-1542281286-9e0a16bb7366',
    availableColors: ['#4B2C20', '#000000'],
    sizes: ['UK 8', 'UK 9', 'UK 10'],
    category: 'Boots',
    gender: 'men',
    subCategory: 'shoes',
  ),
  Product(
    id: 'p5',
    name: 'Pink Canvas Sneakers',
    shopId: 's1',
    shopName: 'Sagar Footwear',
    price: 1599,
    floorPrice: 1200,
    imageUrl: 'https://images.unsplash.com/photo-1560769629-975ec94e6a86',
    availableColors: ['#FFC0CB', '#FFFFFF'],
    sizes: ['UK 4', 'UK 5', 'UK 6'],
    category: 'Casual',
    gender: 'women',
    subCategory: 'shoes',
  ),

  // Trend Setters (Clothes)
  Product(
    id: 'p2',
    name: 'Street Oversized Tee',
    shopId: 's3',
    shopName: 'Trend Setters',
    price: 1299,
    floorPrice: 900,
    imageUrl: 'https://images.unsplash.com/photo-1521572163474-6864f9cf17ab',
    availableColors: ['#000000', '#FFFFFF', '#FF0000'],
    sizes: ['S', 'M', 'L', 'XL'],
    category: 'T-Shirts',
    gender: 'men',
    subCategory: 'clothes',
  ),
  Product(
    id: 'p6',
    name: 'Slim Fit Denim',
    shopId: 's3',
    shopName: 'Trend Setters',
    price: 2199,
    floorPrice: 1600,
    imageUrl: 'https://images.unsplash.com/photo-1542272604-787c3835535d',
    availableColors: ['#0000FF', '#000000'],
    sizes: ['30', '32', '34', '36'],
    category: 'Jeans',
    gender: 'men',
    subCategory: 'clothes',
  ),
  Product(
    id: 'p7',
    name: 'Floral Summer Dress',
    shopId: 's3',
    shopName: 'Trend Setters',
    price: 1899,
    floorPrice: 1400,
    imageUrl: 'https://images.unsplash.com/photo-1515372039744-b8f02a3ae446',
    availableColors: ['#FFFFFF', '#FFB6C1'],
    sizes: ['S', 'M', 'L'],
    category: 'Dresses',
    gender: 'women',
    subCategory: 'clothes',
  ),

  // Ethnic Elegance
  Product(
    id: 'p3',
    name: 'Silk Embroidered Kurta',
    shopId: 's2',
    shopName: 'Ethnic Elegance',
    price: 3500,
    floorPrice: 2800,
    imageUrl: 'https://images.unsplash.com/photo-1585487000160-6ebcfceb0d03',
    availableColors: ['#FFD700', '#C0C0C0', '#800080'],
    sizes: ['M', 'L', 'XL'],
    category: 'Kurtas',
    gender: 'men',
    subCategory: 'clothes',
  ),
  Product(
    id: 'p8',
    name: 'Designer Anarkali',
    shopId: 's2',
    shopName: 'Ethnic Elegance',
    price: 5500,
    floorPrice: 4200,
    imageUrl: 'https://images.unsplash.com/photo-1610030469983-98e550d6193c',
    availableColors: ['#FF0000', '#008000'],
    sizes: ['S', 'M', 'L'],
    category: 'Ethnic Wear',
    gender: 'women',
    subCategory: 'clothes',
  ),

  // Kids Products
  Product(
    id: 'p9',
    name: 'Cartoon Print Tee',
    shopId: 's3',
    shopName: 'Trend Setters',
    price: 799,
    floorPrice: 500,
    imageUrl: 'https://images.unsplash.com/photo-1518831959646-742c3a14ebf7',
    availableColors: ['#FFFF00', '#00FFFF'],
    sizes: ['24', '26', '28'],
    category: 'T-Shirts',
    gender: 'kids',
    subCategory: 'clothes',
  ),
  Product(
    id: 'p10',
    name: 'Kids Sport Shoes',
    shopId: 's1',
    shopName: 'Sagar Footwear',
    price: 1299,
    floorPrice: 900,
    imageUrl: 'https://images.unsplash.com/photo-1514989940723-e8e51635b782',
    availableColors: ['#000000', '#FF0000'],
    sizes: ['UK 1', 'UK 2', 'UK 3'],
    category: 'Sports',
    gender: 'kids',
    subCategory: 'shoes',
  ),
];
