const express = require('express');
const app = express();

app.use(express.json());

// Mock data
const deliveries = new Map();
const agents = new Map();
let deliveryIdCounter = 5000;
let agentIdCounter = 100;

// Initialize mock agents
const initializeAgents = () => {
  const mockAgents = [
    { name: 'John Smith', phone: '+91-9876543210', city: 'Delhi', status: 'available' },
    { name: 'Priya Singh', phone: '+91-9876543211', city: 'Rohtak', status: 'available' },
    { name: 'Rajesh Kumar', phone: '+91-9876543212', city: 'Gurugram', status: 'on-delivery' },
    { name: 'Neha Gupta', phone: '+91-9876543213', city: 'Noida', status: 'available' },
    { name: 'Amit Patel', phone: '+91-9876543214', city: 'Rohtak', status: 'available' }
  ];

  mockAgents.forEach(agent => {
    const agentId = `AGENT-${agentIdCounter++}`;
    agents.set(agentId, { id: agentId, ...agent });
  });
};

initializeAgents();

// Status options
const statusFlow = ['pending', 'assigned', 'picked-up', 'in-transit', 'out-for-delivery', 'delivered'];

// Create Delivery Order
app.post('/api/deliveries/create', (req, res) => {
  const { orderId, customerName, address, city, phone, weight, dimensions } = req.body;

  // Validation
  if (!orderId || !customerName || !address || !city || !phone) {
    return res.status(400).json({
      success: false,
      message: 'Missing required fields: orderId, customerName, address, city, phone'
    });
  }

  // Find available agent in the same city
  const availableAgent = Array.from(agents.values()).find(
    agent => agent.city.toLowerCase() === city.toLowerCase() && agent.status === 'available'
  );

  const deliveryId = `DEL-${deliveryIdCounter++}`;
  const deliveryData = {
    deliveryId,
    orderId,
    customerName,
    address,
    city,
    phone,
    weight: weight || '1kg',
    dimensions: dimensions || 'Standard',
    status: 'pending',
    assignedAgent: availableAgent ? availableAgent.id : null,
    agentName: availableAgent ? availableAgent.name : 'Not assigned',
    agentPhone: availableAgent ? availableAgent.phone : null,
    createdAt: new Date().toISOString(),
    estimatedDelivery: getEstimatedDeliveryDate(),
    currentLocation: null,
    updates: [
      {
        status: 'pending',
        timestamp: new Date().toISOString(),
        message: 'Order received and pending assignment'
      }
    ]
  };

  deliveries.set(deliveryId, deliveryData);

  res.status(201).json({
    success: true,
    message: 'Delivery order created successfully',
    deliveryId,
    orderId,
    status: 'pending',
    estimatedDelivery: deliveryData.estimatedDelivery,
    assignedAgent: availableAgent ? {
      id: availableAgent.id,
      name: availableAgent.name,
      phone: availableAgent.phone
    } : null
  });
});

// Assign Delivery Agent
app.post('/api/deliveries/:deliveryId/assign', (req, res) => {
  const { deliveryId } = req.params;
  const { agentId } = req.body;

  const delivery = deliveries.get(deliveryId);

  if (!delivery) {
    return res.status(404).json({
      success: false,
      message: 'Delivery not found'
    });
  }

  const agent = agents.get(agentId);

  if (!agent) {
    return res.status(404).json({
      success: false,
      message: 'Agent not found'
    });
  }

  delivery.assignedAgent = agentId;
  delivery.agentName = agent.name;
  delivery.agentPhone = agent.phone;
  delivery.status = 'assigned';

  delivery.updates.push({
    status: 'assigned',
    timestamp: new Date().toISOString(),
    message: `Assigned to agent ${agent.name}`
  });

  res.status(200).json({
    success: true,
    message: 'Agent assigned successfully',
    deliveryId,
    agent: {
      id: agent.id,
      name: agent.name,
      phone: agent.phone,
      city: agent.city
    }
  });
});

// Update Delivery Status
app.put('/api/deliveries/:deliveryId/status', (req, res) => {
  const { deliveryId } = req.params;
  const { status, location, notes } = req.body;

  const delivery = deliveries.get(deliveryId);

  if (!delivery) {
    return res.status(404).json({
      success: false,
      message: 'Delivery not found'
    });
  }

  if (!statusFlow.includes(status)) {
    return res.status(400).json({
      success: false,
      message: `Invalid status. Allowed: ${statusFlow.join(', ')}`
    });
  }

  delivery.status = status;
  delivery.currentLocation = location || delivery.currentLocation;

  delivery.updates.push({
    status,
    timestamp: new Date().toISOString(),
    location: location || null,
    message: notes || `Status updated to ${status}`
  });

  res.status(200).json({
    success: true,
    message: 'Status updated successfully',
    deliveryId,
    status,
    currentLocation: delivery.currentLocation
  });
});

// Get Delivery Status
app.get('/api/deliveries/:deliveryId', (req, res) => {
  const { deliveryId } = req.params;

  const delivery = deliveries.get(deliveryId);

  if (!delivery) {
    return res.status(404).json({
      success: false,
      message: 'Delivery not found'
    });
  }

  res.status(200).json({
    success: true,
    delivery: {
      deliveryId: delivery.deliveryId,
      orderId: delivery.orderId,
      customerName: delivery.customerName,
      address: delivery.address,
      city: delivery.city,
      status: delivery.status,
      assignedAgent: delivery.assignedAgent ? {
        id: delivery.assignedAgent,
        name: delivery.agentName,
        phone: delivery.agentPhone
      } : null,
      estimatedDelivery: delivery.estimatedDelivery,
      currentLocation: delivery.currentLocation,
      createdAt: delivery.createdAt,
      updates: delivery.updates
    }
  });
});

// Get All Deliveries (with filters)
app.get('/api/deliveries', (req, res) => {
  const { status, city, orderId } = req.query;

  let deliveriesList = Array.from(deliveries.values());

  if (status) {
    deliveriesList = deliveriesList.filter(d => d.status === status);
  }

  if (city) {
    deliveriesList = deliveriesList.filter(d => d.city.toLowerCase() === city.toLowerCase());
  }

  if (orderId) {
    deliveriesList = deliveriesList.filter(d => d.orderId === orderId);
  }

  res.status(200).json({
    success: true,
    count: deliveriesList.length,
    deliveries: deliveriesList.map(d => ({
      deliveryId: d.deliveryId,
      orderId: d.orderId,
      customerName: d.customerName,
      city: d.city,
      status: d.status,
      estimatedDelivery: d.estimatedDelivery,
      agentName: d.agentName
    }))
  });
});

// Get All Delivery Agents
app.get('/api/agents', (req, res) => {
  const { city, status } = req.query;

  let agentsList = Array.from(agents.values());

  if (city) {
    agentsList = agentsList.filter(a => a.city.toLowerCase() === city.toLowerCase());
  }

  if (status) {
    agentsList = agentsList.filter(a => a.status === status);
  }

  res.status(200).json({
    success: true,
    count: agentsList.length,
    agents: agentsList
  });
});

// Get Agent Details
app.get('/api/agents/:agentId', (req, res) => {
  const { agentId } = req.params;

  const agent = agents.get(agentId);

  if (!agent) {
    return res.status(404).json({
      success: false,
      message: 'Agent not found'
    });
  }

  // Get deliveries assigned to this agent
  const assignedDeliveries = Array.from(deliveries.values()).filter(
    d => d.assignedAgent === agentId
  );

  res.status(200).json({
    success: true,
    agent: {
      id: agent.id,
      name: agent.name,
      phone: agent.phone,
      city: agent.city,
      status: agent.status,
      assignedDeliveries: assignedDeliveries.length,
      completedDeliveries: assignedDeliveries.filter(d => d.status === 'delivered').length
    }
  });
});

// Track Delivery (public endpoint)
app.get('/api/track/:deliveryId', (req, res) => {
  const { deliveryId } = req.params;

  const delivery = deliveries.get(deliveryId);

  if (!delivery) {
    return res.status(404).json({
      success: false,
      message: 'Delivery not found'
    });
  }

  res.status(200).json({
    success: true,
    tracking: {
      deliveryId: delivery.deliveryId,
      status: delivery.status,
      currentLocation: delivery.currentLocation,
      estimatedDelivery: delivery.estimatedDelivery,
      agentPhone: delivery.agentPhone,
      updates: delivery.updates.slice(-5) // Last 5 updates
    }
  });
});

// Health check
app.get('/health', (req, res) => {
  res.status(200).json({
    status: 'Delivery Agents API is running',
    totalDeliveries: deliveries.size,
    totalAgents: agents.size,
    timestamp: new Date().toISOString()
  });
});

// Helper function to calculate estimated delivery date
function getEstimatedDeliveryDate() {
  const date = new Date();
  date.setDate(date.getDate() + 3); // 3 days from now
  return date.toISOString().split('T')[0];
}

const PORT = process.env.PORT || 3002;
app.listen(PORT, () => {
  console.log(`Delivery Agents API running on port ${PORT}`);
  console.log('\nMock Agents:');
  Array.from(agents.values()).forEach(agent => {
    console.log(`- ${agent.name} (${agent.id}) - ${agent.city} - ${agent.status}`);
  });
});
