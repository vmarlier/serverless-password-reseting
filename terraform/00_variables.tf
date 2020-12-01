#### region specification
variable region {
  default = "eu-west-1"
}


#### global variables used for all ressources
variable application {
  default = "password-reseting"
}

variable environment {
  default = "XEnterprise"
}

variable owner {
  default = "me"
}

#### 01_vpc
variable "cidr_block" {
  default = "10.0.0.0/16"
}


#### subnet cidr
variable "cidr_snpb" {
  default = "10.0.10.0/24"
}

variable "cidr_snpr" {
  default = "10.0.20.0/24"
}


#### specify availability zones for subnets creation
variable "azs" {

  default = "eu-west-1a,eu-west-1b"
}

variable "map_public_ip_on_launch" {
  default = "true"
}


#### EC2 configuration
variable "ec2_type" {
  default = "t2.nano"
}

variable "public_key" {
  default = "ssh-rsa AAAAB3NzaC1yc2EAAAA... user@localhost"
}

#### Lambda
variable "lambda-filenames" {
  type = "map"
  default = {
    "checkAccount" = "../lambda/checkAccount/main.zip"
    "sendCode" = "../lambda/sendCode/main.zip"
    "changePassword" = "../lambda/changePassword/main.zip"
  }  
}

#### IAM
variable "enterprise_boundary-arn" {
  default = "arn:aws:iam::XXXXXXXXXXXX:policy/enterprise-boundary"
}


####################### TEST

variable "lambda-arn" {
  default = "arn:aws:lambda:eu-west-1:XXXXXXXXXXXX:function:test-API-GATEWAY"
}

variable "accountId" {
  default = "XXXXXXXXXXXX"
}





