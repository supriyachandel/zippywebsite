# ZippyStyle API Reference

## Base URLs

| App | Platform | URL |
|-----|----------|-----|
| User App | Production / Live | `https://fascism-bullseye-perjury.ngrok-free.dev/api` |
| Store App | Production / Live | `https://fascism-bullseye-perjury.ngrok-free.dev/api` |
| Local Dev | Android Emulator | `http://10.0.2.2:3000/api` |
| Local Dev | iOS / macOS | `http://localhost:3000/api` |

## Headers

All authenticated requests require:
```
Authorization: Bearer <token>
Content-Type: application/json
Accept: application/json
```

---

# User App Endpoints

## Auth

### Register
```
POST /api/register
```
**Body:**
```json
{
  "name": "string",
  "email": "string",
  "password": "string",
  "password_confirmation": "string",
  "phone": "string",
  "gender": "male|female|other",
  "image": "string (URL)",
  "address": "string",
  "adharcard": "string",
  "pancard": "string",
  "city": "string",
  "zip": "string",
  "state": "string",
  "country": "string",
  "latitude": "string",
  "longitude": "string"
}
```
**Response:**
```json
{
  "token": "string",
  "user": { "id": "int", "name": "string", "email": "string", "phone": "string", "image": "string", "gender": "string", ... }
}
```

### Login
```
POST /api/login
```
**Body:**
```json
{ "email": "string", "password": "string" }
```
**Response:**
```json
{
  "token": "string",
  "user": { "id": "int", "name": "string", "email": "string", "phone": "string", "image": "string", "gender": "string", ... }
}
```

### Google Sign-In
```
POST /api/auth/google
```
**Body:**
```json
{ "id_token": "string (Google ID token)" }
```
**Response:**
```json
{
  "token": "string",
  "user": { "id": "int", "name": "string", "email": "string", "phone": "string", "image": "string", "gender": "string", ... }
}
```

### Get Profile
```
GET /api/user
```
**Response:**
```json
{
  "id": "int",
  "name": "string",
  "email": "string",
  "phone": "string",
  "image": "string",
  "gender": "string",
  "address": "string",
  "city": "string",
  "state": "string",
  "zip": "string",
  "country": "string",
  "latitude": "string",
  "longitude": "string",
  "role": "string",
  "status": "string",
  "created_at": "datetime",
  "updated_at": "datetime"
}
```

### Update Profile
```
POST /api/user/update/{id}
```
**Body:**
```json
{
  "name": "string",
  "email": "string",
  "phone": "string",
  "image": "string (URL)"
}
```
**Response:**
```json
{ "success": true, "message": "string", "user": { ... } }
```

---

## Products & Categories

### Get All Products
```
GET /api/products
```
**Response:** `[ { product_object }, ... ]`

### Get Categories
```
GET /api/categories
```
**Response:** `[ { "id": "int", "name": "string", "image": "string (URL)", ... }, ... ]`

### Get Subcategories
```
GET /api/sub/categories
```
**Response:** `[ { "id": "int", "category_name": "string", "category_id": "int", "image": "string (URL)", ... }, ... ]`

### Get All Shops
```
GET /api/shops
```
**Response:** `[ { shop_object }, ... ]`

### Get Shop Products
```
GET /api/shop/{shopId}/products
```
**Response:** `[ { product_object }, ... ]`

### Get Products by Subcategory
```
GET /api/{subCategoryId}/products
```
**Response:** `[ { product_object }, ... ]`

---

## Addresses

### Get Addresses
```
GET /api/addresses
```
**Response:** `[ { "id": "int", "label": "string", "name": "string", "phone": "string", "address": "string", "city": "string", "state": "string", "zip": "string", "is_default": "bool", ... }, ... ]`

### Create Address
```
POST /api/address/create
```
**Body:**
```json
{
  "label": "string (Home/Work/Other)",
  "name": "string",
  "phone": "string",
  "address": "string",
  "city": "string",
  "state": "string",
  "zip": "string",
  "is_default": "bool",
  "latitude": "string",
  "longitude": "string"
}
```
**Response:** `{ "success": true, "message": "string" }`

### Update Address
```
POST /api/address/update/{id}
```
**Body:** Same as Create Address
**Response:** `{ "success": true, "message": "string" }`

### Delete Address
```
DELETE /api/address/delete/{id}
```
**Response:** (no body, 200 OK)

---

## Orders & Payment

### Get Payment Methods
```
GET /api/payment-methods
```
**Response:** `[ { "id": "int", "name": "string", ... }, ... ]`

### Create Purchase (Place Order)
```
POST /api/purchase/create
```
**Body:**
```json
{
  "address_id": "int",
  "payment_method_id": "int",
  "latitude": "string",
  "longitude": "string",
  "payment_id": "string (optional, from Razorpay)",
  "transaction_id": "string (optional)",
  "products": [
    {
      "product_id": "int",
      "price": "double",
      "paid_price": "double",
      "quantity": "int (optional)"
    }
  ]
}
```
**Response:**
```json
{
  "success": true,
  "message": "string",
  "purchase": { "id": "int", ... },
  "purchase_id": "int"
}
```

### Get Purchase History
```
GET /api/purchases
```
**Response:** `[ { purchase_object }, ... ]`

Each purchase object:
```json
{
  "id": "int",
  "total_paid_price": "string",
  "payment_method": { "name": "string", ... },
  "address": { "label": "string", "name": "string", "address": "string", "city": "string", "state": "string", "zip": "string" },
  "purchased_products": [
    {
      "product": { "name": "string", "image_url": "string" },
      "paid_price": "double",
      "quantity": "int"
    }
  ],
  "status": "string",
  "transaction_id": "string",
  "created_at": "datetime"
}
```

---

## Product Object Structure

```json
{
  "id": "int",
  "name": "string",
  "price": "double",
  "discount_price": "double",
  "quantity": "int",
  "size": "string (comma-separated)",
  "material": "string",
  "color": "string",
  "description": "string",
  "image": "string (URL)",
  "image_urls": "string (JSON array or pipe-separated URLs)",
  "sub_category_id": "int",
  "shop_id": "int"
}
```

---

# Store App Endpoints

## Auth

### Store Login
```
POST /api/login
```
**Body:**
```json
{ "email": "string", "password": "string" }
```
**Response:**
```json
{
  "token": "string",
  "user": { "id": "int", "name": "string", "email": "string", "phone": "string" },
  "shop": { "id": "int", "name": "string", ... }
}
```

### Store Register
```
POST /api/register
```
**Body:**
```json
{
  "name": "string",
  "email": "string",
  "password": "string",
  "password_confirmation": "string",
  "phone": "string"
}
```
**Response:**
```json
{
  "token": "string",
  "user": { "id": "int", "name": "string", "email": "string", "phone": "string" }
}
```

### Create Shop (after register)
```
POST /api/shop/create
```
**Body:**
```json
{
  "name": "string",
  "description": "string",
  "address": "string",
  "city": "string",
  "state": "string",
  "gst_number": "string",
  "email": "string",
  "website": "string",
  "image": "string (URL)"
}
```
**Response:**
```json
{ "shop": { "id": "int", "name": "string", ... } }
```

---

## Shop Management

### Get User's Shop
```
GET /api/shops
```
**Response:** `{ "id": "int", "name": "string", ... }` (single shop object)

### Get Shop Details
```
GET /api/shop/{id}
```
**Response:** `{ "shop": { shop_object } }`

### Update Shop
```
POST /api/shop/update/{id}
```
**Body:**
```json
{
  "name": "string",
  "description": "string",
  "address": "string",
  "city": "string",
  "state": "string",
  "gst_number": "string",
  "email": "string",
  "website": "string",
  "image": "string (URL)"
}
```
**Response:** `{ "shop": { updated_shop_object } }`

### Delete Shop
```
DELETE /api/shop/delete/{id}
```
**Response:** (200 OK)

---

## Store Products

### Get Shop Products
```
GET /api/shop/{shopId}/products
```
**Response:** `[ { product_object }, ... ]`

### Create Product
```
POST /api/product/create
```
Multipart/form-data with fields:
```
name, price, discount_price, quantity, size, material, color, description,
sub_category_id (int), image (file), image_urls (string)
```
**Response:** `{ "product": { ... }, "id": "int" }`

### Update Product
```
POST /api/product/update/{productId}
```
Multipart/form-data with same fields as create.
**Response:** `{ "product": { ... }, "id": "int", "status": "string" }`

### Delete Product
```
DELETE /api/product/delete/{productId}
```
**Response:** `true`

### Get Categories (for store)
```
GET /api/categories
```
**Response:** `[ { category_object }, ... ]`

### Get All Products (for subcategory IDs)
```
GET /api/products
```
**Response:** `[ { product_object }, ... ]`

---

## Store Orders

### Get Shop Orders
```
GET /api/shop/{shopId}/orders
```
**Response:** `[ { order_object }, ... ]`

### Get Order Details
```
GET /api/orders/{orderId}
```
**Response:** `{ order_object }`

### Accept Order
```
PATCH /api/orders/{orderId}/accept
```
**Response:** `{ "success": true, ... }`

### Reject Order
```
PATCH /api/orders/{orderId}/reject
```
**Response:** `{ "success": true, ... }`

### Update Order Status
```
PATCH /api/orders/{orderId}/status
```
**Body:**
```json
{ "status": "shipped|delivered|cancelled" }
```
**Response:** `{ "success": true, ... }`

### Assign Delivery Partner
```
POST /api/orders/{orderId}/assign-delivery
```
**Body:**
```json
{ "partner_id": "int" }
```
**Response:** `{ "success": true, ... }`

### Add Tracking Info
```
POST /api/orders/{orderId}/tracking
```
**Body:**
```json
{ "courier": "string", "tracking_number": "string" }
```
**Response:** `{ "success": true, ... }`

---

## Delivery Partners

### Get All Partners
```
GET /api/delivery-partners
```
**Response:** `[ { partner_object }, ... ]`

Partner object:
```json
{
  "id": "int",
  "name": "string",
  "phone": "string",
  "email": "string",
  "vehicle": "string (Bike/Car/Van)",
  "service_pincodes": "string (comma-separated)",
  "active": "bool",
  "created_at": "datetime"
}
```

### Create Partner
```
POST /api/delivery-partners/create
```
**Body:**
```json
{
  "name": "string",
  "phone": "string",
  "email": "string",
  "vehicle": "Bike|Car|Van",
  "service_pincodes": "string (comma-separated)"
}
```
**Response:** `{ "success": true, "partner": { ... } }`

### Update Partner
```
PUT /api/delivery-partners/{id}
```
**Body:** Same as create.
**Response:** `{ "success": true, "partner": { ... } }`

### Toggle Partner Active Status
```
PATCH /api/delivery-partners/{id}/toggle
```
**Response:** `{ "success": true, "partner": { ... } }`

---

## ShipRocket Integration

### Get Available Couriers
```
GET /api/shiprocket/couriers?delivery_pincode={pincode}
```
**Response:**
```json
[
  { "courier_name": "Delhivery", "rate": "double", "etd": "string", ... },
  ...
]
```

### Create Shipment
```
POST /api/shiprocket/shipments/create
```
**Body:**
```json
{
  "order_id": "string",
  "courier_id": "string",
  "name": "string",
  "address": "string",
  "city": "string",
  "state": "string",
  "pincode": "string",
  "phone": "string",
  "weight": "string"
}
```
**Response:**
```json
{
  "shipment_id": "int",
  "awb_code": "string",
  "courier_name": "string",
  "label_url": "string",
  "manifest_url": "string"
}
```

### Generate Pickup Request
```
POST /api/shiprocket/pickup-request
```
**Body:**
```json
{ "shipment_id": "int" }
```
**Response:**
```json
{ "pickup_id": "string", "status": "string", "pickup_date": "datetime" }
```

### Generate Label
```
POST /api/shiprocket/label
```
**Body:**
```json
{ "shipment_id": "int" }
```
**Response:** `"string (label URL)"`

### Generate Manifest
```
POST /api/shiprocket/manifest
```
**Body:**
```json
{ "shipment_id": "int" }
```
**Response:** `"string (manifest URL)"`

### Track Shipment
```
GET /api/shiprocket/tracking?awb={awb_code}
```
**Response:**
```json
{
  "awb_code": "string",
  "status": "string",
  "current_status": "string",
  "tracking_data": [ { "location": "string", "status": "string", "datetime": "datetime" }, ... ],
  "estimated_delivery": "datetime"
}
```

### Cancel Shipment
```
POST /api/shiprocket/shipments/cancel
```
**Body:**
```json
{ "shipment_id": "int" }
```
**Response:** `true`
