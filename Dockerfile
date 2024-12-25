# golang:1.20.6-alpine
FROM golang@sha256:b01f7c744a3f1fccaf44905169169fed0ab13e6d1d702a6542d07b34cf677969 as build
WORKDIR /app
COPY . .
RUN env CGO_ENABLED=0 GOOS=linux GOARCH=amd64 go build -o /rds_outpost_exporter ./ && \
    chmod +x /rds_outpost_exporter

# alpine:3.18.2
FROM alpine@sha256:21dc6063fd678b478f57c0e13f47560d0ea4eeba26dfc947b2a4f81f686b9f45
COPY --from=build ["/rds_outpost_exporter", "/bin/" ]
# Check version ca-certificates: https://pkgs.alpinelinux.org/package/edge/main/x86/ca-certificates
RUN apk update --no-cache && \
    apk upgrade --no-cache && \
    apk add --no-cache ca-certificates=20240705-r0 && \
    update-ca-certificates && \
    rm -rf /var/cache/apk/*

EXPOSE 9999
ENTRYPOINT [ "/bin/rds_outpost_exporter", "--config.file=/etc/rds_outpost_exporter/config.yml" ]
