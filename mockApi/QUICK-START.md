# Quick Start Guide - Testing the E-Commerce APIs

## 🚀 Getting Started (5 Minutes)

### Step 1: Install Dependencies
```bash
npm install
```

### Step 2: Run Both APIs
**Option A: Run in separate terminals**
```bash
# Terminal 1
node payment-gateway-api.js

# Terminal 2
node delivery-agents-api.js
```

**Option B: Run both simultaneously (requires concurrently)**
```bash
npm start
```

### Step 3: Verify APIs are Running
```bash
# Payment API Health Check
curl http://localhost:3001/health

# Delivery API Health Check
curl http://localhost:3002/health
```

---

## 📝 Quick Testing with curl

### Complete Order Workflow

#### 1️⃣ Process Payment
```bash
curl -X POST http://localhost:3001/api/payments/process \
  -H "Content-Type: application/json" \
  -d '{
    "amount": 5000,
    "cardNumber": "4111111111111111",
    "cvv": "123",
    "expiryDate": "12/25",
    "customerName": "John Doe",
    "orderId": "ORD-001"
  }'
```

**Expected Response:**
```json
{
  "success": true,
  "paymentId": "PAY-1000",
  "transactionId": "TXN-...",
  "status": "completed"
}
```

---

#### 2️⃣ Create Delivery Order
```bash
curl -X POST http://localhost:3002/api/deliveries/create \
  -H "Content-Type: application/json" \
  -d '{
    "orderId": "ORD-001",
    "customerName": "John Doe",
    "address": "123 Main Street, Apt 4B",
    "city": "Rohtak",
    "phone": "+91-9876543215",
    "weight": "1kg"
  }'
```

**Expected Response:**
```json
{
  "success": true,
  "deliveryId": "DEL-5000",
  "status": "pending",
  "assignedAgent": {
    "id": "AGENT-101",
    "name": "Priya Singh",
    "phone": "+91-9876543211"
  }
}
```

---

#### 3️⃣ Track Delivery
```bash
curl http://localhost:3002/api/track/DEL-5000
```

---

#### 4️⃣ Update Delivery Status
```bash
curl -X PUT http://localhost:3002/api/deliveries/DEL-5000/status \
  -H "Content-Type: application/json" \
  -d '{
    "status": "in-transit",
    "location": "Delhi-Rohtak Highway, KM 25"
  }'
```

---

#### 5️⃣ Refund Payment
```bash
curl -X POST http://localhost:3001/api/payments/refund \
  -H "Content-Type: application/json" \
  -d '{
    "paymentId": "PAY-1000",
    "amount": 5000
  }'
```

---

## 🧪 Testing Different Scenarios

### Payment API Test Cards

#### ✅ Successful Payment
```bash
curl -X POST http://localhost:3001/api/payments/process \
  -H "Content-Type: application/json" \
  -d '{
    "amount": 5000,
    "cardNumber": "4111111111111111",
    "cvv": "123",
    "expiryDate": "12/25",
    "customerName": "Test User"
  }'
```

#### ❌ Insufficient Funds (402 Error)
```bash
curl -X POST http://localhost:3001/api/payments/process \
  -H "Content-Type: application/json" \
  -d '{
    "amount": 5000,
    "cardNumber": "4000000000000002",
    "cvv": "123",
    "expiryDate": "12/25",
    "customerName": "Test User"
  }'
```

#### ❌ Card Declined (403 Error)
```bash
curl -X POST http://localhost:3001/api/payments/process \
  -H "Content-Type: application/json" \
  -d '{
    "amount": 5000,
    "cardNumber": "5555555555554444",
    "cvv": "123",
    "expiryDate": "12/25",
    "customerName": "Test User"
  }'
```

---

### Delivery API Test Scenarios

#### Get All Deliveries in Rohtak
```bash
curl http://localhost:3002/api/deliveries?city=Rohtak
```

#### Get Available Agents in Rohtak
```bash
curl http://localhost:3002/api/agents?city=Rohtak&status=available
```

#### Get Pending Deliveries
```bash
curl http://localhost:3002/api/deliveries?status=pending
```

#### Get Delivery by Order ID
```bash
curl http://localhost:3002/api/deliveries?orderId=ORD-001
```

#### Get Agent Details
```bash
curl http://localhost:3002/api/agents/AGENT-101
```

---

## 🔄 Complete Test Sequence (Copy & Paste)

### Scenario: Customer places order, pays, and tracks delivery

```bash
# 1. Process Payment
PAYMENT=$(curl -s -X POST http://localhost:3001/api/payments/process \
  -H "Content-Type: application/json" \
  -d '{
    "amount": 10000,
    "cardNumber": "4111111111111111",
    "cvv": "123",
    "expiryDate": "12/25",
    "customerName": "Rajesh Kumar",
    "orderId": "ORD-2024-001"
  }')

echo "Payment Result:"
echo $PAYMENT | jq '.'
echo ""

# 2. Create Delivery
DELIVERY=$(curl -s -X POST http://localhost:3002/api/deliveries/create \
  -H "Content-Type: application/json" \
  -d '{
    "orderId": "ORD-2024-001",
    "customerName": "Rajesh Kumar",
    "address": "456 Oak Lane, Sector 7",
    "city": "Rohtak",
    "phone": "+91-9876543220",
    "weight": "2kg",
    "dimensions": "30x20x15 cm"
  }')

echo "Delivery Result:"
echo $DELIVERY | jq '.'
echo ""

# Extract delivery ID
DELIVERY_ID=$(echo $DELIVERY | jq -r '.deliveryId')
echo "Delivery ID: $DELIVERY_ID"
echo ""

# 3. Get Initial Tracking
echo "Initial Tracking:"
curl -s http://localhost:3002/api/track/$DELIVERY_ID | jq '.tracking'
echo ""

# 4. Update Status - Picked Up
curl -s -X PUT http://localhost:3002/api/deliveries/$DELIVERY_ID/status \
  -H "Content-Type: application/json" \
  -d '{
    "status": "picked-up",
    "location": "Warehouse - Rohtak"
  }' | jq '.'
echo ""

# 5. Update Status - In Transit
curl -s -X PUT http://localhost:3002/api/deliveries/$DELIVERY_ID/status \
  -H "Content-Type: application/json" \
  -d '{
    "status": "in-transit",
    "location": "On NH9 Highway"
  }' | jq '.'
echo ""

# 6. Get Final Tracking Info
echo "Final Tracking Status:"
curl -s http://localhost:3002/api/track/$DELIVERY_ID | jq '.tracking'
echo ""

# 7. List All Deliveries
echo "All Deliveries in Rohtak:"
curl -s http://localhost:3002/api/deliveries?city=Rohtak | jq '.'
```

---

## 📊 Using with Postman

### Import Collection
1. Open Postman
2. Create a new collection "E-Commerce APIs"
3. Add these requests:

**Payment Requests:**
- POST `http://localhost:3001/api/payments/process`
- POST `http://localhost:3001/api/payments/refund`
- GET `http://localhost:3001/api/payments/:paymentId`
- GET `http://localhost:3001/api/payments`

**Delivery Requests:**
- POST `http://localhost:3002/api/deliveries/create`
- GET `http://localhost:3002/api/deliveries`
- GET `http://localhost:3002/api/deliveries/:deliveryId`
- PUT `http://localhost:3002/api/deliveries/:deliveryId/status`
- GET `http://localhost:3002/api/track/:deliveryId`
- GET `http://localhost:3002/api/agents`
- GET `http://localhost:3002/api/agents/:agentId`

---

## 🔍 Using with JavaScript/Node.js

```javascript
// Import the client
const { PaymentGatewayClient, DeliveryAgentsClient } = 
  require('./client-examples');

// Create clients
const payment = new PaymentGatewayClient();
const delivery = new DeliveryAgentsClient();

// Process payment
const paymentResult = await payment.processPayment({
  amount: 5000,
  cardNumber: '4111111111111111',
  cvv: '123',
  expiryDate: '12/25',
  customerName: 'John Doe',
  orderId: 'ORD-001'
});

// Create delivery
const deliveryResult = await delivery.createDelivery({
  orderId: 'ORD-001',
  customerName: 'John Doe',
  address: '123 Main St',
  city: 'Rohtak',
  phone: '+91-9876543215'
});

// Track delivery
const tracking = await delivery.trackDelivery(deliveryResult.deliveryId);
console.log(tracking);
```

---

## 🐛 Troubleshooting

### Port Already in Use
```bash
# Find process using port 3001
lsof -i :3001

# Find process using port 3002
lsof -i :3002

# Kill process (replace PID with actual process ID)
kill -9 PID
```

### CORS Issues (If Using Frontend)
Add CORS to the APIs - Update payment-gateway-api.js:
```javascript
const cors = require('cors');
app.use(cors());
```

### Connection Refused
Make sure both APIs are running:
```bash
curl http://localhost:3001/health
curl http://localhost:3002/health
```

---

## 📚 API Documentation Files

- **API-DOCUMENTATION.md** - Complete endpoint documentation
- **client-examples.js** - Client library and code examples
- **payment-gateway-api.js** - Payment API server code
- **delivery-agents-api.js** - Delivery API server code

---

## ✨ Features

- ✅ Real-world API behavior
- ✅ Multiple test card numbers
- ✅ Automatic agent assignment by city
- ✅ Complete order workflow
- ✅ In-memory data persistence (session)
- ✅ Public tracking endpoint
- ✅ Comprehensive error handling

---

## 🎯 Next Steps

1. Start both APIs
2. Test with curl commands above
3. Integrate into your app using client-examples.js
4. Customize based on your needs
5. Switch to real APIs when ready

Happy testing! 🚀
