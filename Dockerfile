# Base stage
FROM golang:1.24 AS builder

WORKDIR /app

RUN apt-get update -qq && \
    apt-get install -y --no-install-recommends ca-certificates libwebp-dev

COPY go.mod go.sum ./
RUN go mod download
COPY . .

RUN go build -o ./imageproxy ./cmd/imageproxy

# Runner stage
FROM gcr.io/distroless/static-debian12
COPY --from=builder /etc/ssl/certs/ca-certificates.crt /etc/ssl/certs/
COPY --from=builder /app/imageproxy /

ENTRYPOINT  ["/imageproxy"]
