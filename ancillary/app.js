const express = require('express');
const cors = require('cors');
const bodyParser = require('body-parser');

const app = express();
app.use(cors());
app.use(bodyParser.json());

const PORT = process.env.PORT || 5057;

// Mock ancillary data - with intentional inconsistencies
const bookingAddOns = {
  'BK001': {
    booking_id: 'BK001', // snake_case
    ticketNumber: 'TK001', // camelCase (mix!)
    flightNum: 'KA0924', // abbreviated
    passenger_name: 'John Doe',
    addOns: [ // camelCase
      {
        id: 'ADDON001',
        type: 'seat_upgrade',
        fromSeat: '32B', // camelCase
        to_seat: '12A', // snake_case (mixed in same object!)
        price: 149.99,
        status: 'confirmed'
        // Missing standard fields like created_at
      },
      {
        id: 'ADDON002',
        type: 'baggage',
        quantity: 1,
        weight: 23,
        cost: 50.00 // "cost" not "price"
      }
    ]
  }
};

const baggagePolicies = {
  'LHR-SFO': {
    routeId: 'LHR-SFO', // camelCase
    origin: 'LHR',
    destination_code: 'SFO', // snake_case (mixed!)
    free_baggage_allowance: 1,
    max_weight_per_bag: 23, // kilograms
    carry_on_allowed: {
      count: 1,
      dimensions: '22x14x9 inches' // American units (vs metric above!)
    },
    excess_baggage_fee: 50.00,
    last_updated: Date.now() // Unix timestamp (vs ISO elsewhere)
  }
};

const mealOptions = {
  'KA0924': {
    flight_id: 'KA0924', // snake_case
    flightNumber: 'KA0924', // camelCase (redundant and inconsistent!)
    meals: [
      {
        meal_type: 'breakfast',
        dietary_options: ['vegan', 'gluten-free', 'halal'], // array
        price: 12.00,
        available_count: 45
      },
      {
        type: 'lunch', // "type" instead of "meal_type"!
        options: 'vegan,vegetarian,standard', // comma-separated string (inconsistent with array above!)
        pricing: 18.00, // "pricing" not "price"
        stock: 120
      }
    ],
    lastModified: '2024-03-20T08:00:00Z' // ISO 8601
  }
};

// Health check
app.get('/health', (req, res) => {
  res.json({ ready: true }); // "ready" not "status" or "operational"
});

// GET add-ons for a booking
app.get('/bookings/:bookingId/add-ons', (req, res) => {
  const { bookingId } = req.params;

  if (!bookingAddOns[bookingId]) {
    return res.status(404).json({
      code: 'NOT_FOUND',
      description: `Booking ${bookingId} not found` // "description" field
    });
  }

  const data = bookingAddOns[bookingId];
  res.json({
    bookingID: data.booking_id, // inconsistent casing (ID vs id)
    extras: data.addOns, // "extras" instead of "addOns" or "add_ons"
    totalPrice: data.addOns.reduce((sum, a) => sum + (a.price || a.cost || 0), 0),
    timestamp: new Date().toISOString() // ISO 8601
  });
});

// POST new add-on
app.post('/bookings/:bookingId/add-ons', (req, res) => {
  const { bookingId } = req.params;
  const { type, details } = req.body;

  if (!bookingId || !type) {
    return res.status(400).json({
      invalid_request: true,
      reason: 'Missing required fields' // different error structure again
    });
  }

  const addon = {
    id: `ADDON${Date.now()}`,
    type: type,
    ...details,
    added_on: Date.now() // Unix timestamp
  };

  if (!bookingAddOns[bookingId]) {
    bookingAddOns[bookingId] = {
      booking_id: bookingId,
      addOns: []
    };
  }

  bookingAddOns[bookingId].addOns.push(addon);

  res.status(201).json({
    success: true,
    addon_id: addon.id,
    confirmation_time: new Date().toISOString() // ISO 8601
  });
});

// GET baggage policy
app.get('/routes/:routeId/baggage-policy', (req, res) => {
  const { routeId } = req.params;

  if (!baggagePolicies[routeId]) {
    return res.status(404).json({
      error: {
        status: 404,
        message: `Policy for route ${routeId} not found`, // nested error
        timestamp: new Date().toISOString()
      }
    });
  }

  const policy = baggagePolicies[routeId];
  res.json({
    route: routeId,
    policies: {
      checked_baggage: {
        allowance: policy.free_baggage_allowance,
        weight_limit: policy.max_weight_per_bag, // inconsistent field names
        excess_fee: policy.excess_baggage_fee
      },
      carry_on: policy.carry_on_allowed,
      updated_at: policy.last_updated // Unix timestamp (vs ISO 8601 elsewhere)
    }
  });
});

// GET meal options (different response structure)
app.get('/flights/:flightId/meals', (req, res) => {
  const { flightId } = req.params;

  if (!mealOptions[flightId]) {
    return res.status(404).json({
      msg: `No meals available for flight ${flightId}` // "msg" field (different from everything!)
    });
  }

  const options = mealOptions[flightId];
  res.json({
    flight: flightId,
    available_meals: options.meals.map(meal => ({
      type: meal.meal_type || meal.type, // handle both naming patterns
      options: Array.isArray(meal.dietary_options)
        ? meal.dietary_options
        : meal.options.split(','), // normalize array
      cost: meal.price || meal.pricing, // normalize price field
      available: meal.available_count || meal.stock
    })),
    metadata: {
      last_updated: options.lastModified,
      last_updated_ms: new Date(options.lastModified).getTime() // both formats!
    }
  });
});

// GET meal preferences (extends customer service inconsistently)
app.get('/customer/:customerId/meal-preferences', (req, res) => {
  const { customerId } = req.params;

  res.json({
    customer_id: customerId, // snake_case
    mealPreferences: { // camelCase (mixed!)
      dietary: ['vegetarian', 'nut-allergy'],
      cuisine_preference: 'Asian', // mixed naming
      special_requests: 'Aisle seat preferred' // inconsistent "special_requests" field
    },
    preferences_updated_at: Date.now(), // Unix
    sync_status: 'pending' // extra field not in other services
  });
});

app.listen(PORT, () => {
  console.log(`KongAir Ancillary Services running on port ${PORT}`);
});
