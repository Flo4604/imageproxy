# Base stage
FROM golang:1.24 AS base

WORKDIR /app
RUN apt-get update -qq && \
    apt-get install -y --no-install-recommends ca-certificates libwebp-dev

# Build stage
FROM base AS build
COPY go.mod go.sum ./
RUN go mod download
COPY . .

RUN go build -o bin/imageproxy ./cmd/imageproxy

# Runner stage
FROM gcr.io/distroless/static-debian12 AS runner
COPY --from=base /etc/ssl/certs/ca-certificates.crt /etc/ssl/certs/
COPY --from=build /app/bin/imageproxy /imageproxy
ENTRYPOINT ["/imageproxy"]
