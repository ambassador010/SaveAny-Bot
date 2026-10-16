FROM golang:alpine AS builder

ARG VERSION="dev"
ARG GitCommit="Unknown"
ARG BuildTime="Unknown"

WORKDIR /app
RUN mkdir -p /app/downloads

COPY go.mod go.sum ./
RUN --mount=type=cache,id=s/cd29aca7-e0da-4b61-8648-11129db3016e-/go/pkg/mod,target=/go/pkg/mod \
    go mod download

COPY . .
RUN --mount=type=cache,id=s/cd29aca7-e0da-4b61-8648-11129db3016e-/root/.cache/go-build,target=/root/.cache/go-build \
    --mount=type=cache,id=s/cd29aca7-e0da-4b61-8648-11129db3016e-/go/pkg,target=/go/pkg \
    CGO_ENABLED=0 \
    go build -trimpath \
    -ldflags=" \
    -s -w \
    -X 'github.com/krau/SaveAny-Bot/config.Version=${VERSION}' \
    -X 'github.com/krau/SaveAny-Bot/config.GitCommit=${GitCommit}' \
    -X 'github.com/krau/SaveAny-Bot/config.BuildTime=${BuildTime}' \
    -X 'github.com/krau/SaveAny-Bot/config.Docker=true' \
    " \
    -o saveany-bot .

FROM alpine:latest

RUN apk add --no-cache curl ffmpeg yt-dlp

WORKDIR /app
COPY config.toml /app/config.toml

COPY --from=builder /app/saveany-bot .
COPY entrypoint.sh .

RUN chmod +x /app/saveany-bot && \
    chmod +x /app/entrypoint.sh

ENTRYPOINT ["/app/entrypoint.sh"]
