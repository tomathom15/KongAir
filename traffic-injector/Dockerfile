# Build stage
FROM golang:1.21-alpine AS builder

WORKDIR /app

# Copy go mod files
COPY go.mod go.sum* ./

# Download dependencies
RUN go mod download

# Copy source code
COPY . .

# Build the binary
RUN CGO_ENABLED=0 GOOS=linux GOARCH=arm64 go build -o traffic-injector main.go

# Runtime stage
FROM alpine:latest

WORKDIR /app

# Copy binary from builder
COPY --from=builder /app/traffic-injector .

# Install ca-certificates for HTTPS
RUN apk --no-cache add ca-certificates

# Build command from environment variables with sensible defaults
CMD ["sh", "-c", "./traffic-injector -url=\"${BASE_URL:-http://flights.kongair:8080}\" -kong=\"${KONG_URL:-http://localhost:8000}\" -dark=\"${DARK:-true}\" -tps=\"${TPS:-10}\" -duration=\"${DURATION:-5m}\"${VERBOSE:+ -v}"]
