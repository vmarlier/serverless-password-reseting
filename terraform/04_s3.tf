#### Create S3 bucket for hosting the zipped website
resource "aws_s3_bucket" "bucket" {
  bucket = "website-sourcebucket-rstpwd0212"
  acl    = "private"

  tags = {
    Name  = "${var.environment}-${var.application}-s3"
    Owner = "${var.owner}"
  }
}

resource "aws_s3_bucket_policy" "bucket-policy" {
  bucket = "${aws_s3_bucket.bucket.id}"

  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "AllowAllForUserValentin",
            "Effect": "Allow",
            "Principal": {
                "AWS": "arn:aws:iam::XXXXXXXXXXXX:user/valentin"
            },
            "Action": "s3:*",
            "Resource": "arn:aws:s3:::${aws_s3_bucket.bucket.bucket}"
        },
        {
            "Sid": "AllowRequestFromVpce",
            "Effect": "Allow",
            "Principal": "*",
            "Action": [
                "s3:Get*",
                "s3:List*"
            ],
            "Resource": "arn:aws:s3:::${aws_s3_bucket.bucket.bucket}/*",
            "Condition": {
                "StringEquals": {
                    "aws:sourceVpce": "${aws_vpc_endpoint.s3.id}"
                }
            }
        }
    ]
}
EOF
}

resource "aws_s3_bucket" "lb_logs" {
  bucket = "alb-logs-${var.application}"
  acl    = "private"

  tags = {
    Name  = "${var.environment}-${var.application}-s3"
    Owner = "${var.owner}"
  }
}

resource "aws_s3_bucket_policy" "lb_logs-policy" {
  bucket = "${aws_s3_bucket.lb_logs.id}"

  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "AllowAllForUserValentin",
            "Effect": "Allow",
            "Principal": {
                "AWS": "arn:aws:iam::781377162230:user/valentin"
            },
            "Action": "s3:*",
            "Resource": "arn:aws:s3:::${aws_s3_bucket.lb_logs.bucket}"
        },
        {
          "Sid": "AllowALBtoUseBucket",
          "Effect": "Allow",
          "Principal": {
            "AWS": ["156460612806"]
          },
          "Resource": "arn:aws:s3:::${aws_s3_bucket.lb_logs.bucket}/*",
          "Action": [
            "s3:PutObject"
          ]
        }
    ]
}
EOF
}

#### Upload the website zip file into the bucket
resource "aws_s3_bucket_object" "website" {
  bucket = "${aws_s3_bucket.bucket.id}"
  key    = "website.zip"
  source = "./website.zip"
}

#### Upload the golang zip file into the bucket
resource "aws_s3_bucket_object" "golang" {
  bucket = "${aws_s3_bucket.bucket.id}"
  key    = "golang.tar.gz"
  source = "./go1.12.7.linux-amd64.tar.gz"
}

