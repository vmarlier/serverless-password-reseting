provider "aws" {
  region = "${var.region}"
}

resource "aws_vpc" "vpc" {
  cidr_block           = "${var.cidr_block}"
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name  = "${var.environment}-${var.application}-VPC"
    Owner = "${var.owner}"
  }
}

##### ENDPOINT S3
resource "aws_vpc_endpoint" "s3" {
  vpc_id              = "${aws_vpc.vpc.id}"
  service_name        = "com.amazonaws.eu-west-1.s3"
  private_dns_enabled = false
  vpc_endpoint_type   = "Gateway"
  route_table_ids     = ["${aws_route_table.rtpr.id}"]
  policy              = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "Access-from-specific-VPC-only",
      "Principal": "*",
      "Action": "s3:*",
      "Effect": "Deny",
      "Resource": [
        "arn:aws:s3:::${aws_s3_bucket.bucket.bucket}",
        "arn:aws:s3:::${aws_s3_bucket.bucket.bucket}/*"
      ],
      "Condition": {
        "StringNotEquals": {
          "aws:sourceVpc": "${aws_vpc.vpc.id}"
        }
      }
    },
    {
      "Sid": "Access-to-specific-bucket-only",
      "Principal": "*",
      "Action": [
        "s3:*"
      ],
      "Effect": "Allow",
      "Resource": [
        "arn:aws:s3:::${aws_s3_bucket.bucket.bucket}",
        "arn:aws:s3:::${aws_s3_bucket.bucket.bucket}/*"
      ]
    }
  ]
}	
EOF
}

##### Endpoint APIGW
resource "aws_vpc_endpoint" "apigw" {
  vpc_id            = "${aws_vpc.vpc.id}"
  service_name      = "com.amazonaws.eu-west-1.execute-api"
  vpc_endpoint_type = "Interface"
  subnet_ids        = ["${element(aws_subnet.private.*.id, 1)}"]

  security_group_ids = [
    "${aws_security_group.allow_endpoint_apigw.id}",
  ]

  private_dns_enabled = true
}

# sg for the endpoint
resource "aws_security_group" "allow_endpoint_apigw" {
  name        = "allow_endpoint_apigw"
  description = "allow the endpoint to be contacted via the port 443 from the CIDR block 10.0.0.0/16"
  vpc_id      = "${aws_vpc.vpc.id}"

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "TCP"
    cidr_blocks = ["10.0.0.0/16"]
  }
}
