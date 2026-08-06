# E-Commerce Testing APIs Guide

## Overview
This guide covers two mock APIs for testing your e-commerce app:
1. **Payment Gateway API** (Port 3001)
2. **Delivery Agents API** (Port 3002)

---

## Setup Instructions

### Prerequisites
- Node.js v14+ 
- npm

### Installation

1. **Install Express**
```bash
npm install express
```

2. **Run Payment Gateway API**
```bash
node payment-gateway-api.js
```
Output: `Payment Gateway API running on port 3001`

3. **Run Delivery Agents API** (in another terminal)
```bash
node delivery-agents-api.js
```
Output: `Delivery Agents API running on port 3002`

---

## Payment Gateway API (Port 3001)

### Endpoints

#### 1. Process Payment
**POST** `/api/payments/process`

**Request Body:**
```json
{
  "amount": 5000,
  "cardNumber": "4111111111111111",
  "cvv": "123",
  "expiryDate": "12/25",
  "customerName": "John Doe",
  "orderId": "ORD-12345"
}
```

**Success Response (200):**
```json
{
  "success": true,
  "message": "Payment processed successfully",
  "paymentId": "PAY-1000",
  "transactionId": "TXN-1623456789-abc123def",
  "amount": 5000,
  "status": "completed"
}
```

**Test Card Numbers:**
- `4111111111111111` - ✅ Success
- `4000000000000002` - ❌ Insufficient funds (402)
- `5555555555554444` - ❌ Card declined (403)

---

#### 2. Refund Payment
**POST** `/api/payments/refund`

**Request Body:**
```json
{
  "paymentId": "PAY-1000",
  "amount": 2500
}
```

**Response (200):**
```json
{
  "success": true,
  "message": "Refund processed successfully",
  "paymentId": "PAY-1000",
  "refundAmount": 2500,
  "originalAmount": 5000,
  "status": "refunded"
}
```

---

#### 3. Get Payment Status
**GET** `/api/payments/:paymentId`

**Example:** `GET /api/payments/PAY-1000`

**Response (200):**
```json
{
  "success": true,
  "payment": {
    "paymentId": "PAY-1000",
    "transactionId": "TXN-1623456789-abc123def",
    "amount": 5000,
    "status": "completed",
    "customerName": "John Doe",
    "timestamp": "2024-01-15T10:30:00.000Z",
    "cardLast4": "1111"
  }
}
```

---

#### 4. List All Payments
**GET** `/api/payments`

**Response (200):**
```json
{
  "success": true,
  "count": 5,
  "payments": [
    {
      "paymentId": "PAY-1000",
      "amount": 5000,
      "status": "completed",
      ...
    }
  ]
}
```

---

#### 5. Health Check
**GET** `/health`

**Response:**
```json
{
  "status": "Payment Gateway API is running",
  "timestamp": "2024-01-15T10:30:00.000Z"
}
```

---

## Delivery Agents API (Port 3002)

### Endpoints

#### 1. Create Delivery Order
**POST** `/api/deliveries/create`

**Request Body:**
```json
{
  "orderId": "ORD-12345",
  "customerName": "Rajesh Kumar",
  "address": "123 Main St, Apartment 4B",
  "city": "Rohtak",
  "phone": "+91-9876543215",
  "weight": "2kg",
  "dimensions": "20x20x30 cm"
}
```

**Response (201):**
```json
{
  "success": true,
  "message": "Delivery order created successfully",
  "deliveryId": "DEL-5000",
  "orderId": "ORD-12345",
  "status": "pending",
  "estimatedDelivery": "2024-01-18",
  "assignedAgent": {
    "id": "AGENT-101",
    "name": "Priya Singh",
    "phone": "+91-9876543211"
  }
}
```

---

#### 2. Assign Delivery Agent
**POST** `/api/deliveries/:deliveryId/assign`

**Request Body:**
```json
{
  "agentId": "AGENT-102"
}
```

**Response (200):**
```json
{
  "success": true,
  "message": "Agent assigned successfully",
  "deliveryId": "DEL-5000",
  "agent": {
    "id": "AGENT-102",
    "name": "Rajesh Kumar",
    "phone": "+91-9876543212",
    "city": "Gurugram"
  }
}
```

---

#### 3. Update Delivery Status
**PUT** `/api/deliveries/:deliveryId/status`

**Request Body:**
```json
{
  "status": "in-transit",
  "location": "Delhi-Rohtak Highway, KM 25",
  "notes": "Package picked up from warehouse"
}
```

**Allowed Status Values:**
- `pending` → `assigned` → `picked-up` → `in-transit` → `out-for-delivery` → `delivered`

**Response (200):**
```json
{
  "success": true,
  "message": "Status updated successfully",
  "deliveryId": "DEL-5000",
  "status": "in-transit",
  "currentLocation": "Delhi-Rohtak Highway, KM 25"
}
```

---

#### 4. Get Delivery Status
**GET** `/api/deliveries/:deliveryId`

**Example:** `GET /api/deliveries/DEL-5000`

**Response (200):**
```json
{
  "success": true,
  "delivery": {
    "deliveryId": "DEL-5000",
    "orderId": "ORD-12345",
    "customerName": "Rajesh Kumar",
    "address": "123 Main St, Apartment 4B",
    "city": "Rohtak",
    "status": "in-transit",
    "assignedAgent": {
      "id": "AGENT-102",
      "name": "Rajesh Kumar",
      "phone": "+91-9876543212"
    },
    "estimatedDelivery": "2024-01-18",
    "currentLocation": "Delhi-Rohtak Highway, KM 25",
    "createdAt": "2024-01-15T10:30:00.000Z",
    "updates": [
      {
        "status": "pending",
        "timestamp": "2024-01-15T10:30:00.000Z",
        "message": "Order received and pending assignment"
      },
      {
        "status": "assigned",
        "timestamp": "2024-01-15T10:35:00.000Z",
        "message": "Assigned to agent Rajesh Kumar"
      },
      {
        "status": "in-transit",
        "timestamp": "2024-01-15T11:00:00.000Z",
        "location": "Delhi-Rohtak Highway, KM 25",
        "message": "Package picked up from warehouse"
      }
    ]
  }
}
```

---

#### 5. Get All Deliveries
**GET** `/api/deliveries?status=pending&city=Rohtak&orderId=ORD-12345`

**Query Parameters (all optional):**
- `status` - Filter by status
- `city` - Filter by city
- `orderId` - Filter by order ID

**Response (200):**
```json
{
  "success": true,
  "count": 3,
  "deliveries": [
    {
      "deliveryId": "DEL-5000",
      "orderId": "ORD-12345",
      "customerName": "Rajesh Kumar",
      "city": "Rohtak",
      "status": "in-transit",
      "estimatedDelivery": "2024-01-18",
      "agentName": "Rajesh Kumar"
    }
  ]
}
```

---

#### 6. Get All Agents
**GET** `/api/agents?city=Rohtak&status=available`

**Query Parameters (optional):**
- `city` - Filter by city
- `status` - Filter by status (available, on-delivery, offline)

**Response (200):**
```json
{
  "success": true,
  "count": 3,
  "agents": [
    {
      "id": "AGENT-101",
      "name": "Priya Singh",
      "phone": "+91-9876543211",
      "city": "Rohtak",
      "status": "available"
    }
  ]
}
```

---

#### 7. Get Agent Details
**GET** `/api/agents/:agentId`

**Example:** `GET /api/agents/AGENT-101`

**Response (200):**
```json
{
  "success": true,
  "agent": {
    "id": "AGENT-101",
    "name": "Priya Singh",
    "phone": "+91-9876543211",
    "city": "Rohtak",
    "status": "available",
    "assignedDeliveries": 5,
    "completedDeliveries": 3
  }
}
```

---

#### 8. Track Delivery (Public)
**GET** `/api/track/:deliveryId`

**Example:** `GET /api/track/DEL-5000`

**Response (200):**
```json
{
  "success": true,
  "tracking": {
    "deliveryId": "DEL-5000",
    "status": "in-transit",
    "currentLocation": "Delhi-Rohtak Highway, KM 25",
    "estimatedDelivery": "2024-01-18",
    "agentPhone": "+91-9876543212",
    "updates": [
      {
        "status": "assigned",
        "timestamp": "2024-01-15T10:35:00.000Z",
        "message": "Assigned to agent Rajesh Kumar"
      },
      {
        "status": "in-transit",
        "timestamp": "2024-01-15T11:00:00.000Z",
        "location": "Delhi-Rohtak Highway, KM 25",
        "message": "Package picked up from warehouse"
      }
    ]
  }
}
```

---

#### 9. Health Check
**GET** `/health`

**Response:**
```json
{
  "status": "Delivery Agents API is running",
  "totalDeliveries": 12,
  "totalAgents": 5,
  "timestamp": "2024-01-15T10:30:00.000Z"
}
```

---

## Mock Data Included

### Pre-loaded Agents (Delivery API)
1. John Smith - Delhi (+91-9876543210)
2. Priya Singh - Rohtak (+91-9876543211)
3. Rajesh Kumar - Gurugram (+91-9876543212)
4. Neha Gupta - Noida (+91-9876543213)
5. Amit Patel - Rohtak (+91-9876543214)

---

## Testing Workflow Example

```bash
# 1. Create Order & Payment
curl -X POST http://localhost:3001/api/payments/process \
  -H "Content-Type: application/json" \
  -d '{
    "amount": 5000,
    "cardNumber": "4111111111111111",
    "cvv": "123",
    "expiryDate": "12/25",
    "customerName": "John Doe",
    "orderId": "ORD-12345"
  }'

# 2. Create Delivery Order
curl -X POST http://localhost:3002/api/deliveries/create \
  -H "Content-Type: application/json" \
  -d '{
    "orderId": "ORD-12345",
    "customerName": "John Doe",
    "address": "123 Main St",
    "city": "Rohtak",
    "phone": "+91-9876543215"
  }'

# 3. Track Delivery
curl http://localhost:3002/api/track/DEL-5000

# 4. Update Status
curl -X PUT http://localhost:3002/api/deliveries/DEL-5000/status \
  -H "Content-Type: application/json" \
  -d '{
    "status": "in-transit",
    "location": "Highway"
  }'
```

---

## Error Codes

### Payment API
- `200` - Success
- `201` - Created
- `400` - Bad request
- `402` - Payment failed
- `403` - Forbidden
- `404` - Not found

### Delivery API
- `200` - Success
- `201` - Created
- `400` - Bad request
- `404` - Not found

---

## Features

✅ Realistic mock responses
✅ In-memory data storage (persists during session)
✅ Test card numbers for payment failures
✅ Automatic agent assignment based on city
✅ Full delivery status tracking
✅ Public tracking endpoint
✅ Agent management & statistics
✅ Comprehensive update history

---

## Notes

- Data resets when the server restarts
- No actual payment processing occurs
- Agent availability is randomly distributed by city
- Estimated delivery is always +3 days from creation
