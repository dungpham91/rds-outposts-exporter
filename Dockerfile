FROM golang:1.20.0-alpine as build
WORKDIR /app
COPY . .
RUN apk update --no-cache && \
    apk add --no-cache ca-certificates && \
    update-ca-certificates && \
    env CGO_ENABLED=0 GOOS=linux GOARCH=amd64 go build -o /rds_outpost_exporter ./ && \
    chmod +x /rds_outpost_exporter && \
    rm -rf /var/cache/apk/*

FROM alpine:3.18
COPY --from=build ["/rds_outpost_exporter", "/bin/" ]
RUN apk update --no-cache && \
    apk add --no-cache ca-certificates && \
    update-ca-certificates && \
    rm -rf /var/cache/apk/*

EXPOSE 9999
ENTRYPOINT [ "/bin/rds_outpost_exporter", "--config.file=/etc/rds_outpost_exporter/config.yml" ]
