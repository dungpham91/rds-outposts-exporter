# golang:1.20.6-alpine
FROM golang@sha256:ad5c126b5cf501a8caef751a243bb717ec204ab1aa56dc41dc11be089fafcb4f as build
WORKDIR /app
COPY . .
RUN env CGO_ENABLED=0 GOOS=linux GOARCH=amd64 go build -o /rds_outpost_exporter ./ && \
    chmod +x /rds_outpost_exporter

# alpine:3.18.2
FROM alpine@sha256:beefdbd8a1da6d2915566fde36db9db0b524eb737fc57cd1367effd16dc0d06d
COPY --from=build ["/rds_outpost_exporter", "/bin/" ]
# Check version ca-certificates: https://pkgs.alpinelinux.org/package/edge/main/x86/ca-certificates
RUN apk update --no-cache && \
    apk upgrade --no-cache && \
    apk add --no-cache ca-certificates=20240705-r0 && \
    update-ca-certificates && \
    rm -rf /var/cache/apk/*

EXPOSE 9999
ENTRYPOINT [ "/bin/rds_outpost_exporter", "--config.file=/etc/rds_outpost_exporter/config.yml" ]
