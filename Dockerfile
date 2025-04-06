# Base stage
FROM golang:1.24 AS builder

ARG TARGETOS
ARG TARGETARCH

RUN apt-get update -qq && \
    apt-get install -y --no-install-recommends ca-certificates libwebp-dev

WORKDIR /app

COPY go.mod go.sum ./
RUN go mod download
COPY . .

RUN CGO_ENABLED=1 GOOS=${TARGETOS} GOARCH=${TARGETARCH} go build -o bin/imageproxy ./cmd/imageproxy/main.go

FROM debian:bookworm-slim AS runner
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    ca-certificates \
    libwebp7

COPY --from=builder /etc/ssl/certs/ca-certificates.crt /etc/ssl/certs/
COPY --from=builder /app/bin/imageproxy /imageproxy

ENTRYPOINT [ "/imageproxy" ]
