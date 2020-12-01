package main

import (
	"crypto/tls"
	"fmt"
	"log"
	"os"

	"github.com/aws/aws-lambda-go/events"
	"github.com/aws/aws-lambda-go/lambda"
	"golang.org/x/text/encoding/unicode"
	"gopkg.in/ldap.v2"
)

const (
	// OU where we can find the user
	dc = "OU=Users,OU=Workspace Services,OU=...,DC=test,DC=fr"
)

var (
	// admin credentials, need admin who have rights to modify other users
	admin     = os.Getenv("ADMIN")
	adminPass = os.Getenv("ADMINPASS")
	// Active Directory URL and Port
	ad  = os.Getenv("AD")
	adp = os.Getenv("ADP")
)

func main() {
	lambda.Start(handleRequest)
}

func handleRequest(request events.APIGatewayProxyRequest) (events.APIGatewayProxyResponse, error) {
	str := ""

	if updatePassword(request.Body) == true {
		str = "Succesfully update the password"
	} else {
		str = "there is a problem"
	}

	return events.APIGatewayProxyResponse{
		StatusCode: 200,
		Body:       str,
	}, nil
}

func updatePassword(dn string) bool {
	l, err := ldap.Dial("tcp", fmt.Sprintf("%s:%d", ad, adp))
	if err != nil {
		log.Fatal(err)
	}
	defer l.Close()

	// Reconnect with TLS
	err = l.StartTLS(&tls.Config{InsecureSkipVerify: true})
	if err != nil {
		log.Fatal(err)
	}

	err = l.Bind(admin, adminPass)
	if err != nil {
		log.Fatal(err)
	}

	utf16 := unicode.UTF16(unicode.LittleEndian, unicode.IgnoreBOM)
	// According to the MS docs in the links above
	// The password needs to be enclosed in quotes
	pwdEncoded, _ := utf16.NewEncoder().String("\"S€cureP@ssword\"")
	passReq := &ldap.ModifyRequest{
		DN: dn, // DN for the user we're resetting
		ReplaceAttributes: []ldap.PartialAttribute{
			{"unicodePwd", []string{pwdEncoded}},
		},
	}
	if l.Modify(passReq) == nil {
		return true
	}

	return false
}
