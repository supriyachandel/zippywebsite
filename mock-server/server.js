const express = require('express');
const cors = require('cors');
const path = require('path');

const app = express();
app.use(cors());
app.use(express.json());

// ─── Data ────────────────────────────────────────────────────────────────────

const products = [

  { id: 1, name: "Classic Cotton T-Shirt", price: "1299", discount_price: "799", quantity: "50", size: "M", material: "Cotton", color: "White", description: "Premium quality cotton t-shirt with modern fit", image: "products/tshirt.jpg", image_urls: ["https://images.unsplash.com/photo-1521572163474-6864f9cf17ab?w=400"], sub_category_id: 1, shop_id: 1, user_id: 1, gender: "male", status: "active", sku: null, barcode: null, weight: null, slug: "classic-cotton-tshirt", video: null, created_at: "2025-01-01T00:00:00.000000Z", updated_at: "2025-01-01T00:00:00.000000Z", user: { id: 1, name: "Tanya", email: "tanya@example.com", phone: "9876543210", image: null, address: "123, MG Road", city: "Bengaluru", zip: "560038", state: "Karnataka", country: "India", role: "user", status: "active", created_at: "2025-01-01T00:00:00.000000Z", updated_at: "2025-01-01T00:00:00.000000Z" } },
  { id: 2, name: "Floral Summer Dress", price: "2499", discount_price: "1499", quantity: "30", size: "S", material: "Polyester", color: "Blue", description: "Beautiful floral print dress perfect for summer", image: "products/dress.jpg", image_urls: ["https://images.unsplash.com/photo-1595777457583-95e059d581b8?w=400"], sub_category_id: 2, shop_id: 1, user_id: 1, gender: "female", status: "active", sku: null, barcode: null, weight: null, slug: "floral-summer-dress", video: null, created_at: "2025-01-01T00:00:00.000000Z", updated_at: "2025-01-01T00:00:00.000000Z", user: null },
  { id: 3, name: "Denim Jacket", price: "3999", discount_price: "2499", quantity: "20", size: "L", material: "Denim", color: "Blue", description: "Classic denim jacket with modern styling", image: "products/jacket.jpg", image_urls: ["https://images.unsplash.com/photo-1551028719-00167b16eac5?w=400"], sub_category_id: 4, shop_id: 2, user_id: 1, gender: "unisex", status: "active", sku: null, barcode: null, weight: null, slug: "denim-jacket", video: null, created_at: "2025-01-01T00:00:00.000000Z", updated_at: "2025-01-01T00:00:00.000000Z", user: null },
  { id: 4, name: "Sports Running Shoes", price: "5999", discount_price: "3999", quantity: "40", size: "UK 8", material: "Mesh", color: "Black", description: "Lightweight running shoes with cushioned sole", image: "products/shoes.jpg", image_urls: ["https://images.unsplash.com/photo-1542291026-7eec264c27ff?w=400"], sub_category_id: 7, shop_id: 2, user_id: 1, gender: "male", status: "active", sku: null, barcode: null, weight: null, slug: "sports-running-shoes", video: null, created_at: "2025-01-01T00:00:00.000000Z", updated_at: "2025-01-01T00:00:00.000000Z", user: null },
  { id: 5, name: "Leather Handbag", price: "4499", discount_price: "2999", quantity: "15", size: "One Size", material: "Leather", color: "Brown", description: "Genuine leather handbag with multiple compartments", image: "products/handbag.jpg", image_urls: ["https://images.unsplash.com/photo-1584917865442-de89df76afd3?w=400"], sub_category_id: 10, shop_id: 3, user_id: 1, gender: "female", status: "active", sku: null, barcode: null, weight: null, slug: "leather-handbag", video: null, created_at: "2025-01-01T00:00:00.000000Z", updated_at: "2025-01-01T00:00:00.000000Z", user: null },
  { id: 6, name: "Casual Sneakers", price: "3499", discount_price: "1999", quantity: "60", size: "UK 9", material: "Canvas", color: "White", description: "Comfortable casual sneakers for everyday wear", image: "products/sneakers.jpg", image_urls: ["https://images.unsplash.com/photo-1595950653106-6c9ebd614d3a?w=400"], sub_category_id: 7, shop_id: 1, user_id: 1, gender: "unisex", status: "active", sku: null, barcode: null, weight: null, slug: "casual-sneakers", video: null, created_at: "2025-01-01T00:00:00.000000Z", updated_at: "2025-01-01T00:00:00.000000Z", user: null },
  { id: 7, name: "Kids Cartoon T-Shirt", price: "699", discount_price: "399", quantity: "80", size: "S", material: "Cotton", color: "Multi", description: "Fun cartoon printed t-shirt for kids", image: "products/kids-tshirt.jpg", image_urls: ["https://images.unsplash.com/photo-1622290291468-a28f7a7dc6a8?w=400"], sub_category_id: 1, shop_id: 3, user_id: 1, gender: "kids", status: "active", sku: null, barcode: null, weight: null, slug: "kids-cartoon-tshirt", video: null, created_at: "2025-01-01T00:00:00.000000Z", updated_at: "2025-01-01T00:00:00.000000Z", user: null },
  { id: 8, name: "Woolen Sweater", price: "2999", discount_price: "1999", quantity: "25", size: "XL", material: "Wool", color: "Grey", description: "Warm woolen sweater for winter", image: "products/sweater.jpg", image_urls: ["https://images.unsplash.com/photo-1620799140408-edc6dcb6d633?w=400"], sub_category_id: 5, shop_id: 2, user_id: 1, gender: "male", status: "active", sku: null, barcode: null, weight: null, slug: "woolen-sweater", video: null, created_at: "2025-01-01T00:00:00.000000Z", updated_at: "2025-01-01T00:00:00.000000Z", user: null },
  { id: 9, name: "Silk Saree", price: "8999", discount_price: "5999", quantity: "10", size: "Free", material: "Silk", color: "Red", description: "Elegant silk saree for special occasions", image: "products/saree.jpg", image_urls: ["https://images.unsplash.com/photo-1610030469983-98e550d6193c?w=400"], sub_category_id: 16, shop_id: 3, user_id: 1, gender: "female", status: "active", sku: null, barcode: null, weight: null, slug: "silk-saree", video: null, created_at: "2025-01-01T00:00:00.000000Z", updated_at: "2025-01-01T00:00:00.000000Z", user: null },
  { id: 10, name: "Formal Blazer", price: "6999", discount_price: "4499", quantity: "12", size: "M", material: "Polyester", color: "Navy", description: "Sharp formal blazer for office wear", image: "products/blazer.jpg", image_urls: ["https://images.unsplash.com/photo-1593030761757-71fae45fa0e7?w=400"], sub_category_id: 4, shop_id: 1, user_id: 1, gender: "male", status: "active", sku: null, barcode: null, weight: null, slug: "formal-blazer", video: null, created_at: "2025-01-01T00:00:00.000000Z", updated_at: "2025-01-01T00:00:00.000000Z", user: null },
  { id: 11, name: "Slim Fit Jeans", price: "2499", discount_price: "1799", quantity: "35", size: "32", material: "Denim", color: "Dark Blue", description: "Comfortable slim fit denim jeans", image: "products/jeans.jpg", image_urls: ["https://images.unsplash.com/photo-1542272454315-4c01d7abdf4a?w=400"], sub_category_id: 3, shop_id: 1, user_id: 1, gender: "male", status: "active", sku: null, barcode: null, weight: null, slug: "slim-fit-jeans", video: null, created_at: "2025-01-01T00:00:00.000000Z", updated_at: "2025-01-01T00:00:00.000000Z", user: null },
  { id: 12, name: "Cotton Shorts", price: "999", discount_price: "699", quantity: "45", size: "M", material: "Cotton", color: "Beige", description: "Lightweight cotton shorts for summer", image: "products/shorts.jpg", image_urls: ["https://images.unsplash.com/photo-1591195853828-11db59a44f6b?w=400"], sub_category_id: 6, shop_id: 2, user_id: 1, gender: "female", status: "active", sku: null, barcode: null, weight: null, slug: "cotton-shorts", video: null, created_at: "2025-01-01T00:00:00.000000Z", updated_at: "2025-01-01T00:00:00.000000Z", user: null },
  { id: 13, name: "Leather Formal Shoes", price: "4999", discount_price: "3499", quantity: "18", size: "UK 9", material: "Leather", color: "Black", description: "Premium leather formal shoes", image: "products/formal-shoes.jpg", image_urls: ["https://images.unsplash.com/photo-1614252369475-531eba835eb1?w=400"], sub_category_id: 8, shop_id: 1, user_id: 1, gender: "male", status: "active", sku: null, barcode: null, weight: null, slug: "leather-formal-shoes", video: null, created_at: "2025-01-01T00:00:00.000000Z", updated_at: "2025-01-01T00:00:00.000000Z", user: null },
  { id: 14, name: "Analog Watch", price: "2999", discount_price: "1999", quantity: "22", size: "Free", material: "Stainless Steel", color: "Silver", description: "Elegant analog watch with leather strap", image: "products/watch.jpg", image_urls: ["https://images.unsplash.com/photo-1524592094714-0f0654e20314?w=400"], sub_category_id: 11, shop_id: 2, user_id: 1, gender: "unisex", status: "active", sku: null, barcode: null, weight: null, slug: "analog-watch", video: null, created_at: "2025-01-01T00:00:00.000000Z", updated_at: "2025-01-01T00:00:00.000000Z", user: null },
  { id: 15, name: "Aviator Sunglasses", price: "1999", discount_price: "999", quantity: "30", size: "One Size", material: "Polycarbonate", color: "Black", description: "Trendy aviator sunglasses with UV protection", image: "products/sunglasses.jpg", image_urls: ["https://images.unsplash.com/photo-1572635196237-14b3f281503f?w=400"], sub_category_id: 12, shop_id: 3, user_id: 1, gender: "unisex", status: "active", sku: null, barcode: null, weight: null, slug: "aviator-sunglasses", video: null, created_at: "2025-01-01T00:00:00.000000Z", updated_at: "2025-01-01T00:00:00.000000Z", user: null },
  { id: 16, name: "Gold Plated Necklace", price: "5999", discount_price: "3999", quantity: "8", size: "Free", material: "Gold Plated", color: "Gold", description: "Beautiful gold plated necklace set", image: "products/necklace.jpg", image_urls: ["https://images.unsplash.com/photo-1515562141589-677acb0d1fb2?w=400"], sub_category_id: 13, shop_id: 1, user_id: 1, gender: "female", status: "active", sku: null, barcode: null, weight: null, slug: "gold-plated-necklace", video: null, created_at: "2025-01-01T00:00:00.000000Z", updated_at: "2025-01-01T00:00:00.000000Z", user: null },
  { id: 17, name: "Men's Kurta Pajama", price: "2999", discount_price: "1999", quantity: "15", size: "L", material: "Cotton", color: "White", description: "Traditional cotton kurta pajama set", image: "products/kurta.jpg", image_urls: ["https://images.unsplash.com/photo-1598965402086-897c3241ea61?w=400"], sub_category_id: 17, shop_id: 2, user_id: 1, gender: "male", status: "active", sku: null, barcode: null, weight: null, slug: "mens-kurta-pajama", video: null, created_at: "2025-01-01T00:00:00.000000Z", updated_at: "2025-01-01T00:00:00.000000Z", user: null },
  { id: 18, name: "Designer Lehenga", price: "14999", discount_price: "9999", quantity: "5", size: "M", material: "Silk", color: "Pink", description: "Designer wedding lehenga with embroidery", image: "products/lehenga.jpg", image_urls: ["https://images.unsplash.com/photo-1610030469629-b0ce4b10e7b8?w=400"], sub_category_id: 18, shop_id: 3, user_id: 1, gender: "female", status: "active", sku: null, barcode: null, weight: null, slug: "designer-lehenga", video: null, created_at: "2025-01-01T00:00:00.000000Z", updated_at: "2025-01-01T00:00:00.000000Z", user: null },
  { id: 19, name: "Gym T-Shirt", price: "899", discount_price: "599", quantity: "50", size: "L", material: "Polyester", color: "Grey", description: "Breathable gym t-shirt for workouts", image: "products/gym-tshirt.jpg", image_urls: ["https://images.unsplash.com/photo-1571019613454-1cb2f99b2d8b?w=400"], sub_category_id: 19, shop_id: 1, user_id: 1, gender: "unisex", status: "active", sku: null, barcode: null, weight: null, slug: "gym-tshirt", video: null, created_at: "2025-01-01T00:00:00.000000Z", updated_at: "2025-01-01T00:00:00.000000Z", user: null },
  { id: 20, name: "Kids Casual Shoes", price: "1499", discount_price: "999", quantity: "25", size: "UK 12", material: "Canvas", color: "Blue", description: "Comfortable casual shoes for kids", image: "products/kids-shoes.jpg", image_urls: ["https://images.unsplash.com/photo-1593095948071-474c5cc2c1cf?w=400"], sub_category_id: 15, shop_id: 3, user_id: 1, gender: "kids", status: "active", sku: null, barcode: null, weight: null, slug: "kids-casual-shoes", video: null, created_at: "2025-01-01T00:00:00.000000Z", updated_at: "2025-01-01T00:00:00.000000Z", user: null },
  { id: 21, name: "Yoga Mat", price: "1999", discount_price: "1499", quantity: "20", size: "6mm", material: "TPE", color: "Purple", description: "Non-slip yoga mat with carrying strap", image: "products/yoga-mat.jpg", image_urls: ["https://images.unsplash.com/photo-1544367567-0f2fcb009e0b?w=400"], sub_category_id: 20, shop_id: 2, user_id: 1, gender: "unisex", status: "active", sku: null, barcode: null, weight: null, slug: "yoga-mat", video: null, created_at: "2025-01-01T00:00:00.000000Z", updated_at: "2025-01-01T00:00:00.000000Z", user: null },
  { id: 22, name: "Face Moisturizer", price: "799", discount_price: "499", quantity: "40", size: "50ml", material: "Cream", color: "White", description: "Hydrating face moisturizer for all skin types", image: "products/moisturizer.jpg", image_urls: ["https://images.unsplash.com/photo-1556228578-0d85b1a4d571?w=400"], sub_category_id: 21, shop_id: 1, user_id: 1, gender: "female", status: "active", sku: null, barcode: null, weight: null, slug: "face-moisturizer", video: null, created_at: "2025-01-01T00:00:00.000000Z", updated_at: "2025-01-01T00:00:00.000000Z", user: null },
  { id: 23, name: "Scented Candle Set", price: "1299", discount_price: "899", quantity: "30", size: "Set of 3", material: "Wax", color: "Beige", description: "Hand-poured scented candle gift set", image: "products/candles.jpg", image_urls: ["https://images.unsplash.com/photo-1586023492125-27b2c045efd7?w=400"], sub_category_id: 23, shop_id: 3, user_id: 1, gender: "unisex", status: "active", sku: null, barcode: null, weight: null, slug: "scented-candle-set", video: null, created_at: "2025-01-01T00:00:00.000000Z", updated_at: "2025-01-01T00:00:00.000000Z", user: null },
  { id: 24, name: "Cotton Bedsheet", price: "2499", discount_price: "1499", quantity: "20", size: "Queen", material: "Cotton", color: "White", description: "Premium quality cotton bedsheet set", image: "products/bedsheet.jpg", image_urls: ["https://images.unsplash.com/photo-1616627547584-bf28cee262db?w=400"], sub_category_id: 24, shop_id: 2, user_id: 1, gender: "unisex", status: "active", sku: null, barcode: null, weight: null, slug: "cotton-bedsheet", video: null, created_at: "2025-01-01T00:00:00.000000Z", updated_at: "2025-01-01T00:00:00.000000Z", user: null },
];

const categories = [
  { id: 1, category_name: "Clothing", slug: "clothing", description: "All clothing items", image: null, category_id: null, gender: "unisex", created_at: "2025-01-01T00:00:00.000000Z", updated_at: "2025-01-01T00:00:00.000000Z" },
  { id: 2, category_name: "Footwear", slug: "footwear", description: "Shoes and sneakers", image: null, category_id: null, gender: "unisex", created_at: "2025-01-01T00:00:00.000000Z", updated_at: "2025-01-01T00:00:00.000000Z" },
  { id: 3, category_name: "Accessories", slug: "accessories", description: "Bags, belts, and more", image: null, category_id: null, gender: "unisex", created_at: "2025-01-01T00:00:00.000000Z", updated_at: "2025-01-01T00:00:00.000000Z" },
  { id: 4, category_name: "Kids Wear", slug: "kids-wear", description: "Clothing for kids", image: null, category_id: null, gender: "kids", created_at: "2025-01-01T00:00:00.000000Z", updated_at: "2025-01-01T00:00:00.000000Z" },
  { id: 5, category_name: "Ethnic Wear", slug: "ethnic-wear", description: "Traditional Indian clothing", image: null, category_id: null, gender: "unisex", created_at: "2025-01-01T00:00:00.000000Z", updated_at: "2025-01-01T00:00:00.000000Z" },
  { id: 6, category_name: "Sports & Active", slug: "sports", description: "Activewear and sports gear", image: null, category_id: null, gender: "unisex", created_at: "2025-01-01T00:00:00.000000Z", updated_at: "2025-01-01T00:00:00.000000Z" },
  { id: 7, category_name: "Beauty", slug: "beauty", description: "Beauty and personal care", image: null, category_id: null, gender: "female", created_at: "2025-01-01T00:00:00.000000Z", updated_at: "2025-01-01T00:00:00.000000Z" },
  { id: 8, category_name: "Home & Living", slug: "home-living", description: "Home decor and lifestyle", image: null, category_id: null, gender: "unisex", created_at: "2025-01-01T00:00:00.000000Z", updated_at: "2025-01-01T00:00:00.000000Z" },
];

const subCategories = [
  { id: 1, category_name: "T-Shirts", slug: "tshirts", description: "Casual t-shirts", image: "https://images.unsplash.com/photo-1521572163474-6864f9cf17ab?w=200", category_id: 1, gender: "unisex", created_at: "2025-01-01T00:00:00.000000Z", updated_at: "2025-01-01T00:00:00.000000Z" },
  { id: 2, category_name: "Dresses & Kurtis", slug: "dresses", description: "Dresses and kurtis", image: "https://images.unsplash.com/photo-1595777457583-95e059d581b8?w=200", category_id: 1, gender: "female", created_at: "2025-01-01T00:00:00.000000Z", updated_at: "2025-01-01T00:00:00.000000Z" },
  { id: 3, category_name: "Jeans", slug: "jeans", description: "Denim jeans for everyone", image: "https://images.unsplash.com/photo-1542272454315-4c01d7abdf4a?w=200", category_id: 1, gender: "unisex", created_at: "2025-01-01T00:00:00.000000Z", updated_at: "2025-01-01T00:00:00.000000Z" },
  { id: 4, category_name: "Jackets & Blazers", slug: "jackets", description: "Jackets and blazers", image: "https://images.unsplash.com/photo-1551028719-00167b16eac5?w=200", category_id: 1, gender: "unisex", created_at: "2025-01-01T00:00:00.000000Z", updated_at: "2025-01-01T00:00:00.000000Z" },
  { id: 5, category_name: "Winter Wear", slug: "winter", description: "Sweaters and hoodies", image: "https://images.unsplash.com/photo-1620799140408-edc6dcb6d633?w=200", category_id: 1, gender: "unisex", created_at: "2025-01-01T00:00:00.000000Z", updated_at: "2025-01-01T00:00:00.000000Z" },
  { id: 6, category_name: "Shorts & Skirts", slug: "shorts", description: "Shorts and skirts", image: "https://images.unsplash.com/photo-1591195853828-11db59a44f6b?w=200", category_id: 1, gender: "female", created_at: "2025-01-01T00:00:00.000000Z", updated_at: "2025-01-01T00:00:00.000000Z" },
  { id: 7, category_name: "Sneakers", slug: "sneakers", description: "Sports and casual shoes", image: "https://images.unsplash.com/photo-1542291026-7eec264c27ff?w=200", category_id: 2, gender: "unisex", created_at: "2025-01-01T00:00:00.000000Z", updated_at: "2025-01-01T00:00:00.000000Z" },
  { id: 8, category_name: "Formal Shoes", slug: "formal-shoes", description: "Formal footwear", image: "https://images.unsplash.com/photo-1614252369475-531eba835eb1?w=200", category_id: 2, gender: "male", created_at: "2025-01-01T00:00:00.000000Z", updated_at: "2025-01-01T00:00:00.000000Z" },
  { id: 9, category_name: "Sandals & Flip Flops", slug: "sandals", description: "Casual summer footwear", image: "https://images.unsplash.com/photo-1603481588273-2f908a9a7a1b?w=200", category_id: 2, gender: "unisex", created_at: "2025-01-01T00:00:00.000000Z", updated_at: "2025-01-01T00:00:00.000000Z" },
  { id: 10, category_name: "Bags & Backpacks", slug: "bags", description: "Handbags and backpacks", image: "https://images.unsplash.com/photo-1584917865442-de89df76afd3?w=200", category_id: 3, gender: "female", created_at: "2025-01-01T00:00:00.000000Z", updated_at: "2025-01-01T00:00:00.000000Z" },
  { id: 11, category_name: "Watches", slug: "watches", description: "Stylish watches", image: "https://images.unsplash.com/photo-1524592094714-0f0654e20314?w=200", category_id: 3, gender: "unisex", created_at: "2025-01-01T00:00:00.000000Z", updated_at: "2025-01-01T00:00:00.000000Z" },
  { id: 12, category_name: "Sunglasses", slug: "sunglasses", description: "Trendy eyewear", image: "https://images.unsplash.com/photo-1572635196237-14b3f281503f?w=200", category_id: 3, gender: "unisex", created_at: "2025-01-01T00:00:00.000000Z", updated_at: "2025-01-01T00:00:00.000000Z" },
  { id: 13, category_name: "Jewelry", slug: "jewelry", description: "Necklaces, earrings, rings", image: "https://images.unsplash.com/photo-1515562141589-677acb0d1fb2?w=200", category_id: 3, gender: "female", created_at: "2025-01-01T00:00:00.000000Z", updated_at: "2025-01-01T00:00:00.000000Z" },
  { id: 14, category_name: "Kids Clothing", slug: "kids-clothing", description: "Clothes for kids", image: "https://images.unsplash.com/photo-1622290291468-a28f7a7dc6a8?w=200", category_id: 4, gender: "kids", created_at: "2025-01-01T00:00:00.000000Z", updated_at: "2025-01-01T00:00:00.000000Z" },
  { id: 15, category_name: "Kids Shoes", slug: "kids-shoes", description: "Footwear for kids", image: "https://images.unsplash.com/photo-1593095948071-474c5cc2c1cf?w=200", category_id: 4, gender: "kids", created_at: "2025-01-01T00:00:00.000000Z", updated_at: "2025-01-01T00:00:00.000000Z" },
  { id: 16, category_name: "Sarees", slug: "sarees", description: "Traditional sarees", image: "https://images.unsplash.com/photo-1610030469983-98e550d6193c?w=200", category_id: 5, gender: "female", created_at: "2025-01-01T00:00:00.000000Z", updated_at: "2025-01-01T00:00:00.000000Z" },
  { id: 17, category_name: "Kurta Pajamas", slug: "kurta", description: "Men's ethnic wear", image: "https://images.unsplash.com/photo-1598965402086-897c3241ea61?w=200", category_id: 5, gender: "male", created_at: "2025-01-01T00:00:00.000000Z", updated_at: "2025-01-01T00:00:00.000000Z" },
  { id: 18, category_name: "Lehengas", slug: "lehengas", description: "Wedding and party lehengas", image: "https://images.unsplash.com/photo-1610030469629-b0ce4b10e7b8?w=200", category_id: 5, gender: "female", created_at: "2025-01-01T00:00:00.000000Z", updated_at: "2025-01-01T00:00:00.000000Z" },
  { id: 19, category_name: "Sportswear", slug: "sportswear", description: "Activewear and gym wear", image: "https://images.unsplash.com/photo-1571019613454-1cb2f99b2d8b?w=200", category_id: 6, gender: "unisex", created_at: "2025-01-01T00:00:00.000000Z", updated_at: "2025-01-01T00:00:00.000000Z" },
  { id: 20, category_name: "Yoga & Gym", slug: "yoga", description: "Yoga mats and gym equipment", image: "https://images.unsplash.com/photo-1544367567-0f2fcb009e0b?w=200", category_id: 6, gender: "unisex", created_at: "2025-01-01T00:00:00.000000Z", updated_at: "2025-01-01T00:00:00.000000Z" },
  { id: 21, category_name: "Skincare", slug: "skincare", description: "Face and body care", image: "https://images.unsplash.com/photo-1556228578-0d85b1a4d571?w=200", category_id: 7, gender: "female", created_at: "2025-01-01T00:00:00.000000Z", updated_at: "2025-01-01T00:00:00.000000Z" },
  { id: 22, category_name: "Makeup", slug: "makeup", description: "Cosmetics and makeup", image: "https://images.unsplash.com/photo-1596462502278-27bfdc403348?w=200", category_id: 7, gender: "female", created_at: "2025-01-01T00:00:00.000000Z", updated_at: "2025-01-01T00:00:00.000000Z" },
  { id: 23, category_name: "Home Decor", slug: "home-decor", description: "Decorative items for home", image: "https://images.unsplash.com/photo-1586023492125-27b2c045efd7?w=200", category_id: 8, gender: "unisex", created_at: "2025-01-01T00:00:00.000000Z", updated_at: "2025-01-01T00:00:00.000000Z" },
  { id: 24, category_name: "Bed & Bath", slug: "bed-bath", description: "Bedding and bathroom essentials", image: "https://images.unsplash.com/photo-1616627547584-bf28cee262db?w=200", category_id: 8, gender: "unisex", created_at: "2025-01-01T00:00:00.000000Z", updated_at: "2025-01-01T00:00:00.000000Z" },
];

const shops = [
  { id: 1, name: "Fashion Hub", slug: "fashion-hub", description: "Your one-stop fashion destination", image: null, video: null, status: "active", shop_number: "SH-101", gst_number: null, latitude: null, longitude: null, address: "MG Road, Indiranagar", city: "Bengaluru", state: "Karnataka", zip: "560038", country: "India", phone: "9876543210", email: "fashionhub@example.com", website: null, facebook: null, twitter: null, instagram: "@fashionhub", linkedin: null, user_id: 1, created_at: "2025-01-01T00:00:00.000000Z", updated_at: "2025-01-01T00:00:00.000000Z" },
  { id: 2, name: "Urban Threads", slug: "urban-threads", description: "Trendy urban wear", image: null, video: null, status: "active", shop_number: "SH-202", gst_number: null, latitude: null, longitude: null, address: "Koramangala 5th Block", city: "Bengaluru", state: "Karnataka", zip: "560095", country: "India", phone: "9876543211", email: "urban@example.com", website: null, facebook: null, twitter: null, instagram: "@urbanthreads", linkedin: null, user_id: 1, created_at: "2025-01-01T00:00:00.000000Z", updated_at: "2025-01-01T00:00:00.000000Z" },
  { id: 3, name: "Style Studio", slug: "style-studio", description: "Premium fashion boutique", image: null, video: null, status: "active", shop_number: "SH-303", gst_number: null, latitude: null, longitude: null, address: "Commercial Street", city: "Bengaluru", state: "Karnataka", zip: "560001", country: "India", phone: "9876543212", email: "style@example.com", website: null, facebook: null, twitter: null, instagram: "@stylestudio", linkedin: null, user_id: 1, created_at: "2025-01-01T00:00:00.000000Z", updated_at: "2025-01-01T00:00:00.000000Z" },
];

const addresses = [
  { id: 1, label: "Home", name: "Tanya", phone: "9876543210", address: "123, MG Road, Indiranagar", city: "Bengaluru", state: "Karnataka", zip: "560038", country: "India", is_default: true },
  { id: 2, label: "Work", name: "Tanya", phone: "9876543210", address: "456, Koramangala 5th Block", city: "Bengaluru", state: "Karnataka", zip: "560095", country: "India", is_default: false },
];

const paymentMethods = [
  { id: 1, name: "Razorpay", type: "online", description: "Pay via UPI, Card, Net Banking", status: "active" },
  { id: 2, name: "Cash on Delivery", type: "cod", description: "Pay when you receive", status: "active" },
];

const userData = {
  id: 1, name: "Tanya", email: "tanya@example.com", phone: "9876543210",
  image: null, address: "123, MG Road", city: "Bengaluru",
  zip: "560038", state: "Karnataka", country: "India",
  role: "user", status: "active",
  created_at: "2025-01-01T00:00:00.000000Z", updated_at: "2025-01-01T00:00:00.000000Z",
};

// ─── Routes ──────────────────────────────────────────────────────────────────

// Auth
app.post('/api/login', (req, res) => {
  const { email, password } = req.body;
  if (!email || !password) return res.status(422).json({ message: 'Email and password required' });
  res.json({ token: 'mock_token_12345', ...userData });
});

app.post('/api/register', (req, res) => {
  const { name, email, password } = req.body;
  if (!name || !email || !password) return res.status(422).json({ message: 'Name, email, password required' });
  res.json({ token: 'mock_token_12345', ...userData });
});

// Products
app.get('/api/products', (req, res) => {
  res.json({ products });
});

// Shop products
app.get('/api/shop/:shopId/products', (req, res) => {
  const filtered = products.filter(p => p.shop_id == req.params.shopId);
  res.json({ products: filtered });
});

// Products by subcategory
app.get('/api/:id/products', (req, res) => {
  const filtered = products.filter(p => p.sub_category_id == req.params.id);
  res.json({ products: filtered });
});

// Categories
app.get('/api/categories', (req, res) => {
  res.json({ categories });
});

// Sub categories
app.get('/api/sub/categories', (req, res) => {
  res.json({ sub_categories: subCategories });
});

// Shops
app.get('/api/shops', (req, res) => {
  res.json({ shops });
});

// Payment methods
app.get('/api/payment-methods', (req, res) => {
  res.json({ payment_methods: paymentMethods });
});

// Addresses
app.get('/api/addresses', (req, res) => {
  res.json({ addresses });
});

app.post('/api/address/create', (req, res) => {
  res.json({ success: true, message: 'Address created', address: { id: Date.now(), ...req.body } });
});

app.post('/api/address/update/:id', (req, res) => {
  res.json({ success: true, message: 'Address updated' });
});

app.delete('/api/address/delete/:id', (req, res) => {
  res.json({ success: true, message: 'Address deleted' });
});

// Purchases
app.post('/api/purchase/create', (req, res) => {
  res.json({ success: true, message: 'Purchase created', purchase_id: 1 });
});

app.get('/api/purchases', (req, res) => {
  res.json({ purchases: [] });
});

// User
app.get('/api/user', (req, res) => {
  res.json(userData);
});

app.post('/api/user/update/:id', (req, res) => {
  res.json({ success: true, message: 'Profile updated', user: userData });
});

// ─── Serve static images from /storage ───────────────────────────────────────
app.use('/storage', express.static(path.join(__dirname, 'storage')));

// ─── Start ────────────────────────────────────────────────────────────────────
const PORT = process.env.PORT || 3000;
app.listen(PORT, '0.0.0.0', () => {
  console.log(`ZippyStyle Mock API running on http://localhost:${PORT}`);
  console.log(`Endpoints:`);
  console.log(`  POST /api/login`);
  console.log(`  POST /api/register`);
  console.log(`  GET  /api/products`);
  console.log(`  GET  /api/shop/:id/products`);
  console.log(`  GET  /api/:id/products`);
  console.log(`  GET  /api/categories`);
  console.log(`  GET  /api/sub/categories`);
  console.log(`  GET  /api/shops`);
  console.log(`  GET  /api/payment-methods`);
  console.log(`  GET  /api/addresses`);
  console.log(`  POST /api/address/create`);
  console.log(`  POST /api/address/update/:id`);
  console.log(`  DELETE /api/address/delete/:id`);
  console.log(`  POST /api/purchase/create`);
  console.log(`  GET  /api/purchases`);
  console.log(`  GET  /api/user`);
  console.log(`  POST /api/user/update/:id`);
});
