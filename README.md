# Password-Reseting
### developed in 2018
Reset your LDAP password from a website.
Project develop in Golang on an AWS architecture.

The application infrastructure is terraformed, you can deploy it with :
Before you need to add a golang executable into the directory under the name: go1.12.7.linux-amd64.tar.gz. It will be exported to a S3 bucket and used to initialize the EC2.
```
$ terraform apply
```
## Improvement

The website was first hosted on an EC2, the goal was to move it to S3 and to use lambda for the backend after checking that the application backend was working properly.

## Updating the website

The website only contain the backend. You will need to create the front.
After modification you will have to go into `website/cmd/` then:
```
$ make all
```
This command will build the new code, then zip all the source code and move it into `terraform/website.zip`.

## Terraform resources
The above command will deploy severals AWS resources:
* 1 VPC - CIDR 10.0.0.0/16
    * 2 VPC Endpoints:
        * One endpoint gateway for S3.
        * One endpoint interface for accessing API Gateway resources.
* 2 subnets:
    * 1 public ->  CIDR 10.0.10.0/24.
    * 1 private -> CIDR 10.0.20.0/24.
* 1 Internet Gateway.
* 1 Nat Gateway.
* 2 S3 buckets:
    * First one contain the golang website zipped source code.
    * Second one contain ALB access logs.
* 3 Lambdas:
    * First one for checking account existance into the Active Directory.
    * Second for sending a code (like MFA) with SNS SMS to the user (getting the users phone number via Salesforce).
    * Third for updating the password into the Active Directory.
* 1 API Gateway:
    * To invoke the lambda functions from EC2.
* 1 EC2:
    * To host the golang website.
* 1 Application Load Balancer:
    * To access the EC2 into the private subnet without exposing it.
* severals IAM roles/policies.
* severals Security Groups.

## How to commit ?
Here is a guide to make clean commit in this project.

### Format
```
$ git commit -m "[STATUS]Here is the message"
```

### Status
* ADD : When you add a new file or a new function(ality)
* CHANGE or UPDATE : When you modify a function(ality)
* DONE : When you finish a task/function
* WIP : When your work still in progress
* BUG : In case you create a Bug ^^
* FIXED : When you fixed a bug

### Examples
```
git commit -m "[ADD] newFunction()"
```
```
git commit -m "[DONE] Lambda x"
```
```
git commit -m "[WIP] missing return statement newFunction()"
```
```
git commit -m "[BUG] callLambda() don't work"
```
```
git commit -m "[FIXED] callLambda() don't work: API gateway did not allowed usage of GET method"
```
You can combine status
```
git commit -m "[WIP/BUG] still working on callLambda() bug"
```
or
```
git commit -m "[ADD] newFunction(), [BUG] still working on callLambda() bug"
```
