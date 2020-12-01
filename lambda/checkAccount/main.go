package main

import (
	"crypto/tls"
	"fmt"
	"log"
	"os"

	"github.com/aws/aws-lambda-go/events"
	"github.com/aws/aws-lambda-go/lambda"
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
	return events.APIGatewayProxyResponse{
		StatusCode: 200,
		Body:       checkAdUser(request.Body),
	}, nil
}

func checkAdUser(userToCheck string) string {
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

	// First bind with a user
	err = l.Bind(admin, adminPass)
	if err != nil {
		log.Fatal(err)
	}

	// Search for a specific user
	searchRequest := ldap.NewSearchRequest(dc, ldap.ScopeWholeSubtree, ldap.NeverDerefAliases, 0, 0, false,
		fmt.Sprintf("(&(objectClass=organizationalPerson)(sAMAccountName=%s))", userToCheck), []string{"dn"}, nil)

	sr, err := l.Search(searchRequest)
	if err != nil {
		log.Fatal(err)
	}

	if len(sr.Entries) == 0 {
		log.Fatal("User does not exist")
	} else if len(sr.Entries) > 1 {
		log.Fatal("Too many entries returned")
	}

	return sr.Entries[0].DN
}
