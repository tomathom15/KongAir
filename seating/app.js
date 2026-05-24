const express = require('express');
const cors = require('cors');

const app = express();
app.use(cors());
app.use(express.json());

const PORT = process.env.PORT || 5055;

// Mock data with intentional inconsistencies vs other services
const flightSeats = {
  'KA0924': {
    flightId: 'KA0924', // camelCase (inconsistent with snake_case in flights service)
    flight: {
      flightNum: 'KA0924', // abbreviated field name (vs "number" in flights service)
      departTime: 1711000348000, // Unix timestamp (vs ISO 8601 in flights service)
      route: 'LHR-SFO'
    },
    totalSeats: 180,
    aircraft: 'Boeing 787',
    seatingMap: {
      cabin: 'Economy',
      rows: 30,
      seatsPerRow: 6,
      layout: 'ABCDEF'
    },
    availableSeats: ['1A', '1B', '1D', '2C', '2E', '3A', '3B', '3C', '3D', '3E', '3F'],
    soldSeats: ['1C', '1E', '1F', '2A', '2B', '2D', '2F']
  },
  'KA0925': {
    flightId: 'KA0925',
    flight: {
      flightNum: 'KA0925',
      departTime: 1711086748000,
      route: 'SFO-LHR'
    },
    totalSeats: 180,
    aircraft: 'Boeing 787',
    seatingMap: {
      cabin: 'Economy',
      rows: 30,
      seatsPerRow: 6,
      layout: 'ABCDEF'
    },
    availableSeats: ['1A', '1B', '1C', '1D', '2A', '2B', '2C', '2D', '2E', '2F'],
    soldSeats: ['1E', '1F', '2G']
  }
};

// Health check
app.get('/health', (req, res) => {
  res.json({ status: 'ok' }); // lowercase "ok" (vs "OK" in flights service)
});

// GET seating map for a flight (camelCase route)
app.get('/flights/:flightId/seatingMap', (req, res) => {
  const { flightId } = req.params;

  if (!flightSeats[flightId]) {
    return res.status(404).json({
      error: 'Flight not found', // error field (vs "message" in other services)
      code: 'FLIGHT_NOT_FOUND'
    });
  }

  const data = flightSeats[flightId];
  res.json({
    flightId: data.flightId,
    aircraft: data.aircraft,
    totalCapacity: data.totalSeats, // different field name (vs totalSeats)
    cabinLayout: data.seatingMap, // renamed field
    seatingChart: generateSeatingChart(data)
  });
});

// GET list of seats (different endpoint pattern)
app.get('/flights/:flightId/seats', (req, res) => {
  const { flightId } = req.params;
  const { available } = req.query;

  if (!flightSeats[flightId]) {
    return res.status(404).json({
      err: 'Flight not found', // "err" not "error" or "message"
      flightId: flightId
    });
  }

  const data = flightSeats[flightId];
  let seats = [];

  if (available === 'true') {
    seats = data.availableSeats.map(seatNum => ({
      seatNumber: seatNum,
      status: 'available',
      price: Math.floor(Math.random() * 500) + 50,
      class: 'economy',
      createdAt: Date.now() // Unix timestamp
    }));
  } else {
    seats = [
      ...data.availableSeats.map(seatNum => ({
        seatNumber: seatNum,
        status: 'available',
        price: Math.floor(Math.random() * 500) + 50,
        class: 'economy',
        createdAt: Date.now()
      })),
      ...data.soldSeats.map(seatNum => ({
        seatNumber: seatNum,
        status: 'occupied',
        price: null,
        class: 'economy',
        createdAt: Date.now()
      }))
    ];
  }

  res.json({
    flightID: flightId, // different casing (vs flightId elsewhere)
    totalCount: seats.length,
    items: seats // "items" instead of consistent naming
  });
});

// GET individual seat (deeply nested inconsistency)
app.get('/flights/:flightId/seats/:seatNumber', (req, res) => {
  const { flightId, seatNumber } = req.params;

  if (!flightSeats[flightId]) {
    return res.status(404).json({
      message: `Flight ${flightId} not found` // NOW using "message" (inconsistent with above!)
    });
  }

  const data = flightSeats[flightId];
  const available = data.availableSeats.includes(seatNumber);

  res.json({
    flight_id: flightId, // snake_case here (inconsistent with camelCase above!)
    seat_number: seatNumber,
    available: available,
    class: 'economy',
    price: available ? Math.floor(Math.random() * 500) + 50 : null,
    lastUpdated: new Date().toISOString() // ISO 8601 (vs Unix timestamps above!)
  });
});

// Helper to generate ASCII seating chart
function generateSeatingChart(flightData) {
  const rows = flightData.seatingMap.rows;
  const layout = flightData.seatingMap.layout.split('');
  const available = new Set(flightData.availableSeats);
  const sold = new Set(flightData.soldSeats);

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
