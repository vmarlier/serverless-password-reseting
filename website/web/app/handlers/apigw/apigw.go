package apigw

import (
	"bytes"
	"encoding/json"
	"errors"
	"io/ioutil"
	"log"
	"net/http"
	"os"
	"website/internal/app/tools"
)

// Response is the basic return of API GW endpoint
type Response struct {
	StatusCode int
	Body       string
}

// AccountVerificationLambda call the api gateway endpoint to trigered the account verification lambda.
func AccountVerificationLambda(email string) error {
	body, err := json.Marshal(map[string]string{
		"email": email,
	})
	tools.HandlerErr(4, "accountValidationLambda()", err)

	resp, err := http.Post(os.Getenv("URL")+"/activeDirectory/change", "application/json", bytes.NewBuffer((body)))
	tools.HandlerErr(4, "accountValidationLambda()", err)

	defer resp.Body.Close()

	body, err = ioutil.ReadAll(resp.Body)
	tools.HandlerErr(4, "accountValidationLambda()", err)

	log.Println(body)

	var rsp Response
	err = json.Unmarshal(body, &rsp)

	switch rsp.StatusCode {
	case 0:
		return nil
	case 1:
		return errors.New("ERROR: AWS or AD can be in cause")
	case 2:
		return errors.New("ERROR: User does not exist")
	}

	return nil
}

// SendCodeLambda call the api gateway endpoint to trigered the sendCode lambda.
func SendCodeLambda(email string, code string) error {
	body, err := json.Marshal(map[string]string{
		"email": email,
		"code":  code,
	})
	tools.HandlerErr(4, "sendCodeLambda()", err)

	resp, err := http.Post(os.Getenv("URL")+"/sendCode", "application/json", bytes.NewBuffer(body))
	tools.HandlerErr(4, "sendCodeLambda()", err)

	defer resp.Body.Close()

	body, err = ioutil.ReadAll(resp.Body)
	tools.HandlerErr(4, "sendCodeLambda", err)

	log.Println(body)

	var rsp Response
	err = json.Unmarshal(body, &rsp)

	switch rsp.StatusCode {
	case 0:
		return nil
	case 1:
		return errors.New("ERROR: User's email, salesforce or phone number can be the soure")
	case 2:
		return errors.New("ERROR: AWS, SNS or the sms can be the source")
	}

	return nil
}

// PasswordUpdateLambda call the api gateway endpoint to trigered the password change lambda.
func PasswordUpdateLambda(email string, password string) error {
	body, err := json.Marshal(map[string]string{
		"email":    email,
		"password": password,
	})
	tools.HandlerErr(4, "accountValidationLambda()", err)

	resp, err := http.Post(os.Getenv("URl")+"/activeDirectory/check", "application/json", bytes.NewBuffer((body)))
	tools.HandlerErr(4, "accountValidationLambda()", err)

	defer resp.Body.Close()

	body, err = ioutil.ReadAll(resp.Body)
	tools.HandlerErr(4, "accountValidationLambda()", err)

	log.Println(body)

	var rsp Response
	err = json.Unmarshal(body, &rsp)

	switch rsp.StatusCode {
	case 0:
		return nil
	case 1:
		return errors.New("ERROR: AWS or AD can be in cause")
	case 2:
		return errors.New("ERROR: User does not exist")
	}

	return nil
}
