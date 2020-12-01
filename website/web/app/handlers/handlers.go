// Package handlers list all handlers which will display an html page
package handlers

import (
	"net/http"
	"website/web/static"
)

// HandlerIndex is the first stage for the password reseting when the user has lost is password
func HandlerIndex(w http.ResponseWriter, r *http.Request) {
	p := static.LoadPage("index")
	static.RenderTemplate(w, "index", p)
}

// HandlerSmsValidation is the second stage for the password reseting when the user has lost is password.
func HandlerSmsValidation(w http.ResponseWriter, r *http.Request) {
	p := static.LoadPage("validation")
	static.RenderTemplate(w, "validation", p)
}

// HandlerUpdatePassword is the third stage for the password reseting when the user has lost is password.
func HandlerUpdatePassword(w http.ResponseWriter, r *http.Request) {
	p := static.LoadPage("newpass")
	static.RenderTemplate(w, "newpass", p)
}

// HandlerHealthCheck permit the AWS ALB healthcheck to be healthy
func HandlerHealthCheck(w http.ResponseWriter, r *http.Request) {
	w.Header().Set("Content-Type", "application/json")
	w.WriteHeader(http.StatusOK)
}
