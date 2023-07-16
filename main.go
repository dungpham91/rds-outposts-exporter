package main

import (
	"flag"
	"log"
	"fmt"
	"net/http"
	//"os"

	//"github.com/go-kit/log"
	//"github.com/go-kit/log/level"
	"github.com/prometheus/client_golang/prometheus"
	"github.com/prometheus/client_golang/prometheus/collectors"
	"github.com/prometheus/client_golang/prometheus/promhttp"
	// "github.com/prometheus/common/promlog"
	// "github.com/prometheus/common/promlog/flag"
	// "github.com/prometheus/common/version"
	// "github.com/aws/aws-sdk-go-v2/aws"
	// "github.com/aws/aws-sdk-go-v2/config"
	// "github.com/aws/aws-sdk-go-v2/service/rds"
	// "github.com/aws/aws-sdk-go-v2/service/rds/types"
	"github.com/alecthomas/kingpin/v2"
)

var (
	listenAddressF	= kingpin.Flag("prom.port", "Address on which to expose metrics and web interface.").Default("9999").Int()
	metricPathF		= kingpin.Flag("web.metric-path", "Path under which to expose exporter's metrics.").Default("/metrics").String()
	configFileF		= kingpin.Flag("config.file", "Path to configuration file.").Default("config.yml").String()
	logTraceF		= kingpin.Flag("log.trace", "Enable verbose tracing of AWS requests (will log credentials).").Default("false").Bool()
	//logger			= log.NewNopLogger()
	promPort   = flag.Int("prom.port", 9150, "port to expose prometheus metrics")
)


func main() {
	reg := prometheus.NewRegistry()
	reg.MustRegister(collectors.NewGoCollector())

	mux := http.NewServeMux()
	promHandler := promhttp.HandlerFor(reg, promhttp.HandlerOpts{})
	mux.Handle("/metrics", promHandler)

	port := fmt.Sprintf(":%d", *promPort)
	log.Printf("starting nginx exporter on %q/metrics", port)
	if err := http.ListenAndServe(port, mux); err != nil {
		log.Fatalf("cannot start nginx exporter: %s", err)
	}

}
