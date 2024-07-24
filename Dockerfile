# golang:1.20.6-alpine
FROM golang@sha256:1b70fa8200ed48367e7d0e0e82c0c1d14cf712d422116f9d69e7c964243653a0 as build
WORKDIR /app
COPY . .
RUN env CGO_ENABLED=0 GOOS=linux GOARCH=amd64 go build -o /rds_outpost_exporter ./ && \
    chmod +x /rds_outpost_exporter

# alpine:3.18.2
FROM alpine@sha256:0a4eaa0eecf5f8c050e5bba433f58c052be7587ee8af3e8b3910ef9ab5fbe9f5
COPY --from=build ["/rds_outpost_exporter", "/bin/" ]
# Check version ca-certificates: https://pkgs.alpinelinux.org/package/edge/main/x86/ca-certificates
RUN apk update --no-cache && \
    apk upgrade --no-cache && \
    apk add --no-cache ca-certificates=20240705-r0 && \
    update-ca-certificates && \
    rm -rf /var/cache/apk/*

EXPOSE 9999
ENTRYPOINT [ "/bin/rds_outpost_exporter", "--config.file=/etc/rds_outpost_exporter/config.yml" ]
