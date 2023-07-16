FROM golang:1.20.0-alpine as build
WORKDIR /app
COPY . .
RUN env CGO_ENABLED=0 GOOS=linux GOARCH=amd64 go build -o /rds_outpost_exporter ./
RUN chmod +x /rds_outpost_exporter

FROM alpine:latest
COPY --from=build ["/rds_outpost_exporter", "/bin/" ]
RUN apk update && \
    apk add ca-certificates && \
    update-ca-certificates

EXPOSE 9999
ENTRYPOINT [ "/bin/rds_outpost_exporter", "--config.file=/etc/rds_outpost_exporter/config.yml" ]
