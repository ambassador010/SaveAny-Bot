FROM golang:alpine AS builder

ARG VERSION="dev"
ARG GitCommit="Unknown"
ARG BuildTime="Unknown"

WORKDIR /app

COPY go.mod go.sum ./
RUN --mount=type=cache,id=s/e7b2a76a-460f-49d5-9bd6-11ac3fe2d74d-/go/pkg/mod,target=/go/pkg/mod \
    go mod download

COPY . .
RUN --mount=type=cache,id=s/e7b2a76a-460f-49d5-9bd6-11ac3fe2d74d-/root/.cache/go-build,target=/root/.cache/go-build \
    --mount=type=cache,id=s/e7b2a76a-460f-49d5-9bd6-11ac3fe2d74d-/go/pkg,target=/go/pkg \
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

COPY --from=builder /app/saveany-bot .
COPY entrypoint.sh .

RUN chmod +x /app/saveany-bot && \
    chmod +x /app/entrypoint.sh

ENTRYPOINT ["/app/entrypoint.sh"]
