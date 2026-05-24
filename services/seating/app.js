const express = require('express');
const cors = require('cors');

const app = express();
app.use(cors());
app.use(express.json());

const PORT = process.env.PORT || 5055;

// Mock data - Act 2 standardized format
const flightSeats = {
  'KA0924': {
    flight_id: 'KA0924',
    flight_number: 'KA0924',
    departure_time: '2024-03-20T09:12:28Z',
    route: 'LHR-SFO',
    total_seats: 180,
    aircraft: 'Boeing 787',
    seating_map: {
      cabin: 'economy',
      rows: 30,
      seats_per_row: 6,
      layout: 'ABCDEF'
    },
    available_seats: ['1A', '1B', '1D', '2C', '2E', '3A', '3B', '3C', '3D', '3E', '3F'],
    sold_seats: ['1C', '1E', '1F', '2A', '2B', '2D', '2F'],
    created_at: '2024-03-20T09:00:00Z',
    updated_at: '2024-03-20T09:12:28Z'
  },
  'KA0925': {
    flight_id: 'KA0925',
    flight_number: 'KA0925',
    departure_time: '2024-03-21T09:12:28Z',
    route: 'SFO-LHR',
    total_seats: 180,
    aircraft: 'Boeing 787',
    seating_map: {
      cabin: 'economy',
      rows: 30,
      seats_per_row: 6,
      layout: 'ABCDEF'
    },
    available_seats: ['1A', '1B', '1C', '1D', '2A', '2B', '2C', '2D', '2E', '2F'],
    sold_seats: ['1E', '1F', '2G'],
    created_at: '2024-03-21T08:00:00Z',
    updated_at: '2024-03-21T09:12:28Z'
  }
};

// Health check
app.get('/health', (req, res) => {
  res.json({ status: 'ok' });
});

// GET seating map for a flight
app.get('/flights/:flightId/seatingMap', (req, res) => {
  const { flightId } = req.params;

  if (!flightSeats[flightId]) {
    return res.status(404).json({
      error: 'Flight not found',
      message: `Flight ${flightId} not found`,
      timestamp: new Date().toISOString()
    });
  }

  const data = flightSeats[flightId];
  res.json({
    flight_id: data.flight_id,
    flight_number: data.flight_number,
    aircraft: data.aircraft,
    total_seats: data.total_seats,
    seating_map: data.seating_map,
    seating_chart: generateSeatingChart(data),
    created_at: data.created_at,
    updated_at: data.updated_at
  });
});

// GET list of seats
app.get('/flights/:flightId/seats', (req, res) => {
  const { flightId } = req.params;
  const { available } = req.query;

  if (!flightSeats[flightId]) {
    return res.status(404).json({
      error: 'Flight not found',
      message: `Flight ${flightId} not found`,
      timestamp: new Date().toISOString()
    });
  }

  const data = flightSeats[flightId];
  let seats = [];

  if (available === 'true') {
    seats = data.available_seats.map(seatNum => ({
      seat_number: seatNum,
      status: 'available',
      price: Math.floor(Math.random() * 500) + 50,
      cabin_class: 'economy',
      created_at: data.created_at,
      updated_at: data.updated_at
    }));
  } else {
    seats = [
      ...data.available_seats.map(seatNum => ({
        seat_number: seatNum,
        status: 'available',
        price: Math.floor(Math.random() * 500) + 50,
        cabin_class: 'economy',
        created_at: data.created_at,
        updated_at: data.updated_at
      })),
      ...data.sold_seats.map(seatNum => ({
        seat_number: seatNum,
        status: 'occupied',
        price: null,
        cabin_class: 'economy',
        created_at: data.created_at,
        updated_at: data.updated_at
      }))
    ];
  }

  res.json({
    flight_id: flightId,
    total_count: seats.length,
    seats: seats,
    created_at: data.created_at,
    updated_at: data.updated_at
  });
});

// GET individual seat
app.get('/flights/:flightId/seats/:seatNumber', (req, res) => {
  const { flightId, seatNumber } = req.params;

  if (!flightSeats[flightId]) {
    return res.status(404).json({
      error: 'Flight not found',
      message: `Flight ${flightId} not found`,
      timestamp: new Date().toISOString()
    });
  }

  const data = flightSeats[flightId];
  const available = data.available_seats.includes(seatNumber);

  res.json({
    flight_id: flightId,
    seat_number: seatNumber,
    status: available ? 'available' : 'occupied',
    cabin_class: 'economy',
    price: available ? Math.floor(Math.random() * 500) + 50 : null,
    created_at: data.created_at,
    updated_at: data.updated_at
  });
});

// Helper to generate ASCII seating chart
function generateSeatingChart(flightData) {
  const rows = flightData.seating_map.rows;
  const layout = flightData.seating_map.layout.split('');
  const available = new Set(flightData.available_seats);
  const sold = new Set(flightData.sold_seats);

  let chart = '';
  for (let r = 1; r <= rows; r++) {
    chart += `Row ${r.toString().padStart(2)}: `;
    for (const seat of layout) {
      const seatNum = `${r}${seat}`;
      if (available.has(seatNum)) {
        chart += '[ ] ';
      } else if (sold.has(seatNum)) {
        chart += '[X] ';
      } else {
        chart += '[?] ';
      }
    }
    chart += '\n';
  }
  return chart;
}

app.listen(PORT, () => {
  console.log(`KongAir Seating Service running on port ${PORT}`);
});
