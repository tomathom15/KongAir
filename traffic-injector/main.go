package main

import (
	"bytes"
	"encoding/json"
	"flag"
	"fmt"
	"io"
	"log"
	"math"
	"math/rand"
	"net/http"
	"sync"
	"time"

	"github.com/google/uuid"
)

var (
	baseURL       = flag.String("url", "http://localhost:5052", "Base URL for KongAir APIs (flights service)")
	tps           = flag.Float64("tps", 10, "Target transactions per second")
	duration      = flag.Duration("duration", 5*time.Minute, "How long to run the injector")
	burstFraction = flag.Float64("burst", 0.2, "Fraction of time to burst at 2x TPS (0-1)")
	includeDark   = flag.Bool("dark", true, "Include undocumented dark API endpoints")
	verbose       = flag.Bool("v", false, "Verbose logging")
)

type Metrics struct {
	mu           sync.Mutex
	requests     int64
	failures     int64
	startTime    time.Time
	lastRPS      float64
}

func (m *Metrics) recordRequest() {
	m.mu.Lock()
	m.requests++
	m.mu.Unlock()
}

func (m *Metrics) recordFailure() {
	m.mu.Lock()
	m.failures++
	m.mu.Unlock()
}

func (m *Metrics) getRPS() float64 {
	m.mu.Lock()
	defer m.mu.Unlock()
	elapsed := time.Since(m.startTime).Seconds()
	if elapsed > 0 {
		return float64(m.requests) / elapsed
	}
	return 0
}

func (m *Metrics) getFailureRate() float64 {
	m.mu.Lock()
	defer m.mu.Unlock()
	if m.requests == 0 {
		return 0
	}
	return float64(m.failures) / float64(m.requests)
}

type TrafficPattern struct {
	name    string
	weight  float64 // probability of this pattern
	fn      func(*http.Client, string) error
}

func main() {
	flag.Parse()

	if *tps <= 0 {
		log.Fatal("TPS must be positive")
	}
	if *burstFraction < 0 || *burstFraction > 1 {
		log.Fatal("Burst fraction must be between 0 and 1")
	}

	log.Printf("KongAir Traffic Injector")
	log.Printf("Target: %s", *baseURL)
	log.Printf("TPS: %.1f (burst: %.1fx on %.0f%% of time)", *tps, 2, *burstFraction*100)
	log.Printf("Duration: %v", *duration)
	log.Printf("Dark APIs: %v", *includeDark)
	log.Printf("")

	metrics := &Metrics{startTime: time.Now()}
	patterns := getTrafficPatterns(*includeDark)

	client := &http.Client{
		Timeout: 5 * time.Second,
	}

	// Prepare burst schedule
	burstStart := time.Now()
	burstDuration := time.Duration(float64(*duration) * *burstFraction)
	isBurst := func() bool {
		elapsed := time.Since(burstStart)
		// Simple pattern: burst for burstDuration, then quiet, repeat
		cycle := time.Duration(float64(*duration))
		pos := elapsed % cycle
		return pos < burstDuration
	}

	// Traffic generation goroutine
	stop := make(chan struct{})
	go func() {
		ticker := time.NewTicker(time.Second)
		defer ticker.Stop()

		for {
			select {
			case <-stop:
				return
			case <-ticker.C:
				// Determine target RPS for this second
				targetRPS := *tps
				if isBurst() {
					targetRPS *= 2
				}

				// Distribute requests across the second
				interval := time.Second / time.Duration(math.Ceil(targetRPS))
				t := time.NewTicker(interval)
				defer t.Stop()

				sent := 0
				for sent < int(math.Ceil(targetRPS)) {
					select {
					case <-t.C:
						go func() {
							pattern := selectPattern(patterns)
							if err := pattern.fn(client, *baseURL); err != nil {
								metrics.recordFailure()
								if *verbose {
									log.Printf("ERROR [%s]: %v", pattern.name, err)
								}
							} else {
								metrics.recordRequest()
								if *verbose {
									log.Printf("OK [%s]", pattern.name)
								}
							}
						}()
						sent++
					case <-stop:
						return
					}
				}
			}
		}
	}()

	// Monitoring goroutine
	monitorTicker := time.NewTicker(10 * time.Second)
	defer monitorTicker.Stop()

	go func() {
		for range monitorTicker.C {
			rps := metrics.getRPS()
			failRate := metrics.getFailureRate()
			log.Printf("[%.1fs] RPS: %.1f | Requests: %d | Failures: %d (%.1f%%)",
				time.Since(metrics.startTime).Seconds(),
				rps,
				metrics.requests,
				metrics.failures,
				failRate*100,
			)
		}
	}()

	// Run for specified duration
	time.Sleep(*duration)
	close(stop)

	// Final stats
	time.Sleep(500 * time.Millisecond)
	log.Printf("")
	log.Printf("=== FINAL STATS ===")
	log.Printf("Total requests: %d", metrics.requests)
	log.Printf("Total failures: %d", metrics.failures)
	log.Printf("Failure rate: %.1f%%", metrics.getFailureRate()*100)
	log.Printf("Average RPS: %.1f", metrics.getRPS())
	log.Printf("Duration: %v", time.Since(metrics.startTime))
}

func selectPattern(patterns []TrafficPattern) TrafficPattern {
	r := rand.Float64()
	cumulative := 0.0
	for _, p := range patterns {
		cumulative += p.weight
		if r <= cumulative {
			return p
		}
	}
	return patterns[len(patterns)-1]
}

func getTrafficPatterns(includeDark bool) []TrafficPattern {
	patterns := []TrafficPattern{
		{
			name:   "search-flights",
			weight: 0.30,
			fn:     searchFlights,
		},
		{
			name:   "get-flight-details",
			weight: 0.20,
			fn:     getFlightDetails,
		},
		{
			name:   "list-routes",
			weight: 0.15,
			fn:     listRoutes,
		},
		{
			name:   "get-customer",
			weight: 0.15,
			fn:     getCustomer,
		},
		{
			name:   "book-flight",
			weight: 0.10,
			fn:     bookFlight,
		},
		{
			name:   "check-booking-status",
			weight: 0.10,
			fn:     checkBookingStatus,
		},
	}

	if includeDark {
		patterns = append(patterns,
			TrafficPattern{
				name:   "dark-flight-search",
				weight: 0.05,
				fn:     darkFlightSearch,
			},
			TrafficPattern{
				name:   "dark-flight-history",
				weight: 0.03,
				fn:     darkFlightHistory,
			},
			TrafficPattern{
				name:   "dark-seat-map",
				weight: 0.02,
				fn:     darkSeatMap,
			},
			// Seating service (port 5055)
			TrafficPattern{
				name:   "dark-seating-map",
				weight: 0.04,
				fn:     darkSeatingMap,
			},
			TrafficPattern{
				name:   "dark-seat-availability",
				weight: 0.03,
				fn:     darkSeatAvailability,
			},
			// Operations service (port 5056)
			TrafficPattern{
				name:   "dark-flight-status",
				weight: 0.05,
				fn:     darkFlightStatus,
			},
			TrafficPattern{
				name:   "dark-flight-crew",
				weight: 0.02,
				fn:     darkFlightCrew,
			},
			TrafficPattern{
				name:   "dark-flight-gate",
				weight: 0.02,
				fn:     darkFlightGate,
			},
			// Ancillary service (port 5057)
			TrafficPattern{
				name:   "dark-booking-addons",
				weight: 0.03,
				fn:     darkBookingAddOns,
			},
			TrafficPattern{
				name:   "dark-baggage-policy",
				weight: 0.02,
				fn:     darkBaggagePolicy,
			},
			TrafficPattern{
				name:   "dark-flight-meals",
				weight: 0.03,
				fn:     darkFlightMeals,
			},
			TrafficPattern{
				name:   "dark-meal-preferences",
				weight: 0.02,
				fn:     darkMealPreferences,
			},
		)
	}

	// Normalize weights
	total := 0.0
	for _, p := range patterns {
		total += p.weight
	}
	for i := range patterns {
		patterns[i].weight /= total
	}

	return patterns
}

// Documented endpoints

func searchFlights(client *http.Client, baseURL string) error {
	departure := []string{"LAX", "JFK", "ORD", "ATL", "DFW"}[rand.Intn(5)]
	arrival := []string{"MIA", "BOS", "SFO", "SEA", "DEN"}[rand.Intn(5)]

	url := fmt.Sprintf("%s/flights?departure=%s&arrival=%s", baseURL, departure, arrival)
	resp, err := client.Get(url)
	if err != nil {
		return err
	}
	defer resp.Body.Close()

	if resp.StatusCode != 200 {
		return fmt.Errorf("unexpected status: %d", resp.StatusCode)
	}

	io.ReadAll(resp.Body)
	return nil
}

func getFlightDetails(client *http.Client, baseURL string) error {
	flightID := fmt.Sprintf("FL%d", 1000+rand.Intn(9000))
	url := fmt.Sprintf("%s/flights/%s", baseURL, flightID)
	resp, err := client.Get(url)
	if err != nil {
		return err
	}
	defer resp.Body.Close()

	// Accept 200 or 404 (not all flight IDs exist)
	if resp.StatusCode != 200 && resp.StatusCode != 404 {
		return fmt.Errorf("unexpected status: %d", resp.StatusCode)
	}

	io.ReadAll(resp.Body)
	return nil
}

func listRoutes(client *http.Client, baseURL string) error {
	url := fmt.Sprintf("%s/routes", baseURL)
	resp, err := client.Get(url)
	if err != nil {
		return err
	}
	defer resp.Body.Close()

	if resp.StatusCode != 200 {
		return fmt.Errorf("unexpected status: %d", resp.StatusCode)
	}

	io.ReadAll(resp.Body)
	return nil
}

func getCustomer(client *http.Client, baseURL string) error {
	// Point to customers service (port 5051)
	customerURL := "http://localhost:5051"
	custID := fmt.Sprintf("CUST%d", 1000+rand.Intn(9000))
	url := fmt.Sprintf("%s/customers/%s", customerURL, custID)

	resp, err := client.Get(url)
	if err != nil {
		return err
	}
	defer resp.Body.Close()

	if resp.StatusCode != 200 && resp.StatusCode != 404 {
		return fmt.Errorf("unexpected status: %d", resp.StatusCode)
	}

	io.ReadAll(resp.Body)
	return nil
}

func bookFlight(client *http.Client, baseURL string) error {
	// Point to bookings service (port 5054)
	bookingURL := "http://localhost:5054"

	payload := map[string]interface{}{
		"flight_id":   fmt.Sprintf("FL%d", 1000+rand.Intn(9000)),
		"customer_id": fmt.Sprintf("CUST%d", 1000+rand.Intn(9000)),
		"seats":       rand.Intn(3) + 1,
	}

	body, _ := json.Marshal(payload)
	resp, err := client.Post(fmt.Sprintf("%s/bookings", bookingURL), "application/json", bytes.NewReader(body))
	if err != nil {
		return err
	}
	defer resp.Body.Close()

	if resp.StatusCode != 200 && resp.StatusCode != 201 && resp.StatusCode != 400 {
		return fmt.Errorf("unexpected status: %d", resp.StatusCode)
	}

	io.ReadAll(resp.Body)
	return nil
}

func checkBookingStatus(client *http.Client, baseURL string) error {
	bookingURL := "http://localhost:5054"
	bookingID := fmt.Sprintf("BK%d", 100000+rand.Intn(900000))
	url := fmt.Sprintf("%s/bookings/%s", bookingURL, bookingID)

	resp, err := client.Get(url)
	if err != nil {
		return err
	}
	defer resp.Body.Close()

	if resp.StatusCode != 200 && resp.StatusCode != 404 {
		return fmt.Errorf("unexpected status: %d", resp.StatusCode)
	}

	io.ReadAll(resp.Body)
	return nil
}

// Dark API endpoints (undocumented)

func darkFlightSearch(client *http.Client, baseURL string) error {
	// /flights/search is undocumented but exists
	departure := []string{"LAX", "JFK", "ORD"}[rand.Intn(3)]
	url := fmt.Sprintf("%s/flights/search?from=%s&limit=10", baseURL, departure)
	resp, err := client.Get(url)
	if err != nil {
		return err
	}
	defer resp.Body.Close()

	// This endpoint may or may not exist, both are acceptable
	io.ReadAll(resp.Body)
	return nil
}

func darkFlightHistory(client *http.Client, baseURL string) error {
	// /flights/history is undocumented but exists
	custID := uuid.New().String()
	url := fmt.Sprintf("%s/flights/history/%s", baseURL, custID)
	resp, err := client.Get(url)
	if err != nil {
		return err
	}
	defer resp.Body.Close()

	io.ReadAll(resp.Body)
	return nil
}

func darkSeatMap(client *http.Client, baseURL string) error {
	// /flights/{id}/seats is undocumented but exists
	flightID := fmt.Sprintf("FL%d", 1000+rand.Intn(9000))
	url := fmt.Sprintf("%s/flights/%s/seats", baseURL, flightID)
	resp, err := client.Get(url)
	if err != nil {
		return err
	}
	defer resp.Body.Close()

	io.ReadAll(resp.Body)
	return nil
}

// Seating service dark endpoints (port 5055)

func darkSeatingMap(client *http.Client, baseURL string) error {
	// /flights/{flightId}/seatingMap
	seatURL := "http://localhost:5055"
	flightID := []string{"KA0924", "KA0925"}[rand.Intn(2)]
	url := fmt.Sprintf("%s/flights/%s/seatingMap", seatURL, flightID)
	resp, err := client.Get(url)
	if err != nil {
		return err
	}
	defer resp.Body.Close()

	if resp.StatusCode != 200 && resp.StatusCode != 404 {
		return fmt.Errorf("unexpected status: %d", resp.StatusCode)
	}

	io.ReadAll(resp.Body)
	return nil
}

func darkSeatAvailability(client *http.Client, baseURL string) error {
	// /flights/{flightId}/seats
	seatURL := "http://localhost:5055"
	flightID := []string{"KA0924", "KA0925"}[rand.Intn(2)]
	url := fmt.Sprintf("%s/flights/%s/seats?available=%t", seatURL, flightID, rand.Float64() > 0.5)
	resp, err := client.Get(url)
	if err != nil {
		return err
	}
	defer resp.Body.Close()

	if resp.StatusCode != 200 && resp.StatusCode != 404 {
		return fmt.Errorf("unexpected status: %d", resp.StatusCode)
	}

	io.ReadAll(resp.Body)
	return nil
}

// Operations service dark endpoints (port 5056)

func darkFlightStatus(client *http.Client, baseURL string) error {
	// /flights/{flightNum}/status
	opsURL := "http://localhost:5056"
	flightNum := []string{"KA0924", "KA0925", "KA0926"}[rand.Intn(3)]
	url := fmt.Sprintf("%s/flights/%s/status", opsURL, flightNum)
	resp, err := client.Get(url)
	if err != nil {
		return err
	}
	defer resp.Body.Close()

	if resp.StatusCode != 200 && resp.StatusCode != 404 {
		return fmt.Errorf("unexpected status: %d", resp.StatusCode)
	}

	io.ReadAll(resp.Body)
	return nil
}

func darkFlightCrew(client *http.Client, baseURL string) error {
	// /flights/{flightNum}/crew
	opsURL := "http://localhost:5056"
	flightNum := []string{"KA0924", "KA0925", "KA0926"}[rand.Intn(3)]
	url := fmt.Sprintf("%s/flights/%s/crew", opsURL, flightNum)
	resp, err := client.Get(url)
	if err != nil {
		return err
	}
	defer resp.Body.Close()

	if resp.StatusCode != 200 && resp.StatusCode != 404 {
		return fmt.Errorf("unexpected status: %d", resp.StatusCode)
	}

	io.ReadAll(resp.Body)
	return nil
}

func darkFlightGate(client *http.Client, baseURL string) error {
	// /flights/{flightNum}/gate
	opsURL := "http://localhost:5056"
	flightNum := []string{"KA0924", "KA0925", "KA0926"}[rand.Intn(3)]
	url := fmt.Sprintf("%s/flights/%s/gate", opsURL, flightNum)
	resp, err := client.Get(url)
	if err != nil {
		return err
	}
	defer resp.Body.Close()

	if resp.StatusCode != 200 && resp.StatusCode != 404 {
		return fmt.Errorf("unexpected status: %d", resp.StatusCode)
	}

	io.ReadAll(resp.Body)
	return nil
}

// Ancillary service dark endpoints (port 5057)

func darkBookingAddOns(client *http.Client, baseURL string) error {
	// GET /bookings/{bookingId}/add-ons
	ancillaryURL := "http://localhost:5057"
	bookingID := "BK001"
	url := fmt.Sprintf("%s/bookings/%s/add-ons", ancillaryURL, bookingID)
	resp, err := client.Get(url)
	if err != nil {
		return err
	}
	defer resp.Body.Close()

	if resp.StatusCode != 200 && resp.StatusCode != 404 {
		return fmt.Errorf("unexpected status: %d", resp.StatusCode)
	}

	io.ReadAll(resp.Body)
	return nil
}

func darkBaggagePolicy(client *http.Client, baseURL string) error {
	// GET /routes/{routeId}/baggage-policy
	ancillaryURL := "http://localhost:5057"
	routeID := "LHR-SFO"
	url := fmt.Sprintf("%s/routes/%s/baggage-policy", ancillaryURL, routeID)
	resp, err := client.Get(url)
	if err != nil {
		return err
	}
	defer resp.Body.Close()

	if resp.StatusCode != 200 && resp.StatusCode != 404 {
		return fmt.Errorf("unexpected status: %d", resp.StatusCode)
	}

	io.ReadAll(resp.Body)
	return nil
}

func darkFlightMeals(client *http.Client, baseURL string) error {
	// GET /flights/{flightId}/meals
	ancillaryURL := "http://localhost:5057"
	flightID := "KA0924"
	url := fmt.Sprintf("%s/flights/%s/meals", ancillaryURL, flightID)
	resp, err := client.Get(url)
	if err != nil {
		return err
	}
	defer resp.Body.Close()

	if resp.StatusCode != 200 && resp.StatusCode != 404 {
		return fmt.Errorf("unexpected status: %d", resp.StatusCode)
	}

	io.ReadAll(resp.Body)
	return nil
}

func darkMealPreferences(client *http.Client, baseURL string) error {
	// GET /customer/{customerId}/meal-preferences
	ancillaryURL := "http://localhost:5057"
	customerID := fmt.Sprintf("CUST%d", 1000+rand.Intn(9000))
	url := fmt.Sprintf("%s/customer/%s/meal-preferences", ancillaryURL, customerID)
	resp, err := client.Get(url)
	if err != nil {
		return err
	}
	defer resp.Body.Close()

	if resp.StatusCode != 200 && resp.StatusCode != 404 {
		return fmt.Errorf("unexpected status: %d", resp.StatusCode)
	}

	io.ReadAll(resp.Body)
	return nil
}
