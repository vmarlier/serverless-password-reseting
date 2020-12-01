// Package actions list all back-end handlers which will process the data from the html pages
package actions

import (
	"fmt"
	"net/http"
)

var (
	a = map[string]string{
		"verifAccount":   "",
		"sendCode":       "",
		"updatePassword": "",
	}
)

/* SaveHandler is the process part of the index page form
func SaveHandler(w http.ResponseWriter, r *http.Request) {
	body := r.FormValue("email")
	p := &static.Page{Title: "save", Body: []byte(body)}
	p.Save()
	http.Redirect(w, r, "/view", http.StatusFound)
}
*/

// ProcessIndex is the process part of the index page form
func ProcessIndex(w http.ResponseWriter, r *http.Request) {
	body := r.FormValue("email")
	fmt.Println(body)
	//apigw.AccountVerificationLambda()
	// do some shit
	http.Redirect(w, r, "/validation", http.StatusFound)
}

// ProcessSMSValidation process the sms code from the validation page form.
func ProcessSMSValidation(w http.ResponseWriter, r *http.Request) {
	body := r.FormValue("code")
	fmt.Println(body)
	// do some shit
	http.Redirect(w, r, "/newpassword", http.StatusFound)
}

// ProcessUpdatePassword process the new password from the newpassword page form.
func ProcessUpdatePassword(w http.ResponseWriter, r *http.Request) {
	body := r.FormValue("password")
	fmt.Println(body)
	// do some shit
	http.Redirect(w, r, "/index", http.StatusFound)
}
