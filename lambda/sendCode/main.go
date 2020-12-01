package main

import (
	"encoding/json"
	"fmt"
	"log"
	"os"
	"strings"

	"github.com/aws/aws-lambda-go/events"
	"github.com/aws/aws-lambda-go/lambda"
	"github.com/aws/aws-sdk-go/aws"
	"github.com/aws/aws-sdk-go/aws/session"
	"github.com/aws/aws-sdk-go/service/sns"
	"github.com/simpleforce/simpleforce"
)

type authData struct {
	Access_Token string
	Instance_URL string
	ID           string
	Token_Type   string
	Issued_At    string
	Signature    string
}

type infoUsers struct {
	URL   string `json:"url"`
	Phone string `json:"phone"`
}

type smsOutput struct {
	Phone   string             `json:"phone"`
	Message string             `json:"message"`
	Output  *sns.PublishOutput `json:"output"`
}

const (
	sender    = "SENDER"
	smsBody   = "Votre code de vérification est"
	smsFooter = "Si vous n'êtes pas à l'origine de cette demande, merci de le signaler à admin@test.fr."
)

var (
	// Salesforce authentication credentials
	sfURL      = "https://eu9.salesforce.com/"
	sfUser     = os.Getenv("USERNAME")
	sfPassword = os.Getenv("PASSWORD")
	sfToken    = os.Getenv("SECURITYTOKEN")
	// Message Type
	kind = "Transactional"
)

// Use HandleRequest as main to run this code on AWS Lambda
func main() {
	lambda.Start(handleRequest)
}

func handleRequest(request events.APIGatewayProxyRequest) (events.APIGatewayProxyResponse, error) {

	client := createSfClient()
	if client == nil {
		log.Fatal("Retrieving client failed")
	} else {
		log.Println("Client Retrieved")
	}

	user := getUsersData(client, request.QueryStringParameters["email"])

	out, msg := sendSMS(formatNumber(user.Phone), request.Body)

	jsn, err := json.Marshal(&smsOutput{
		Phone:   formatNumber(user.Phone),
		Message: msg,
		Output:  out,
	})
	if err != nil {
		log.Println(err)
	}

	return events.APIGatewayProxyResponse{
		StatusCode: 200,
		Body:       string(jsn),
	}, nil
}

// sendSMS() will send and sms to the desired number with the appropriate validation code
// sendSMS() return a struct with the sns output
func sendSMS(num string, vcode string) (*sns.PublishOutput, string) {
	sess := session.Must(session.NewSession())
	attrs := map[string]*sns.MessageAttributeValue{}

	svc := sns.New(sess)

	attrs["AWS.SNS.SMS.SenderID"] = &sns.MessageAttributeValue{
		DataType:    aws.String("String"),
		StringValue: aws.String(sender),
	}

	attrs["AWS.SNS.SMS.SMSType"] = &sns.MessageAttributeValue{
		DataType:    aws.String("String"),
		StringValue: aws.String(kind),
	}

	msg := fmt.Sprintf("%s %s \n %s", smsBody, vcode, smsFooter)

	params := &sns.PublishInput{
		Message:           aws.String(msg),
		PhoneNumber:       aws.String(num),
		MessageAttributes: attrs,
	}

	resp, err := svc.Publish(params)
	if err != nil {
		log.Fatalln(err)
	}

	return resp, msg
}

// formatNumber will remove all caracters which isn't an number between 0 and 9
// and will add telephone code to number without telephone code
func formatNumber(num string) string {
	var number string
	var newNumber string

	r := []rune(num)

	for _, n := range r {
		if n >= 48 && n <= 57 || n == 43 {
			number += string(n)
		}
	}

	if strings.Contains(number, "+") {
		if strings.Contains(number, "+33") {
			r := []rune(number)

			for i, n := range r {
				if i == 3 && string(n) != "0" {
					newNumber += string(n)
				} else if i == 3 && string(n) == "0" {
				} else {
					newNumber += string(n)

				}
			}
			return newNumber
		}
	} else {
		r := []rune(number)

		for i, n := range r {
			if i == 0 && string(n) == "0" {
				newNumber += "+33"
			} else {
				newNumber += string(n)
			}
		}

		return newNumber
	}
	return number
}

// Get users email and phone number from salesforce
func getUsersData(client *simpleforce.Client, email string) infoUsers {
	var list infoUsers
	query := "SELECT+Email,Phone+from+Contact+Where+Type_de_contact__c='Salarié'+AND+A_quitte_la_societe__c=False+AND+Email='" + email + "'"

	result, err := client.Query(query)
	if err != nil {
		fmt.Println("Query Failed")
	}

	for _, record := range result.Records {
		attrs := record.AttributesField()
		list = infoUsers{URL: attrs.URL, Phone: fmt.Sprintln(record["Phone"])}

	}

	return list
}

// Create an SF client via simpleforce package
func createSfClient() *simpleforce.Client {
	client := simpleforce.NewClient(sfURL, simpleforce.DefaultClientID, simpleforce.DefaultAPIVersion)
	if client == nil {
		log.Fatal("SF Client Initialization Failed")
		return nil
	}

	err := client.LoginPassword(sfUser, sfPassword, sfToken)
	if err != nil {
		log.Fatal("Authentication Failed", err)
		return nil
	}

	return client
}
