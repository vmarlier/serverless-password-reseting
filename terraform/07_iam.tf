#### IAM role for lambdas (see lambda.tf)
resource "aws_iam_role" "role-lambda-sendCode" {
  name                 = "${var.environment}-${var.application}-sendCode-role"
  permissions_boundary = "${var.d2si_boundary-arn}"
  assume_role_policy   = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "",
      "Effect": "Allow",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}

resource "aws_iam_role" "role-lambda-checkAccount" {
  name                 = "${var.environment}-${var.application}-checkAccount-role"
  permissions_boundary = "${var.d2si_boundary-arn}"
  assume_role_policy   = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "",
      "Effect": "Allow",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}

resource "aws_iam_role" "role-lambda-changePassword" {
  name                 = "${var.environment}-${var.application}-changePassword-role"
  permissions_boundary = "${var.d2si_boundary-arn}"
  assume_role_policy   = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "",
      "Effect": "Allow",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}

# Add policy to the sendCode lambda role
# Don't forget to change the policy to give less right to the lambda
resource "aws_iam_role_policy_attachment" "sns_lambda_role" {
  role       = "${aws_iam_role.role-lambda-sendCode.id}"
  policy_arn = "arn:aws:iam::aws:policy/AmazonSNSFullAccess"
}

#### IAM role for the EC2 can access S3
resource "aws_iam_role" "role-EC2-S3" {
  name                 = "${var.environment}-${var.application}-EC2-read-S3"
  permissions_boundary = "${var.d2si_boundary-arn}"
  assume_role_policy   = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "",
      "Effect": "Allow",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}

# Policy for the EC2 can access S3
resource "aws_iam_role_policy" "policy-EC2-S3" {
  name   = "${var.environment}-${var.application}-EC2-read-S3"
  role   = "${aws_iam_role.role-EC2-S3.name}"
  policy = <<EOF
{
 "Version": "2012-10-17",
 "Statement": [
 {
 "Effect": "Allow",
 "Action": [
 "s3:ListBucket"
 ],
 "Resource": [
 "arn:aws:s3:::${aws_s3_bucket.bucket.bucket}"
 ]
 },
 {
 "Effect": "Allow",
 "Action": [
 "s3:Get*",
 "s3:List*"
 ],
 "Resource": [
 "arn:aws:s3:::${aws_s3_bucket.bucket.bucket}/*"
 ]
 }
 ]
}
EOF
}

# Create instance profile to attach the role to the EC2
resource "aws_iam_instance_profile" "EC2-S3-instance-profile" {
  name = "EC2-profile-to-S3"
  role = "${aws_iam_role.role-EC2-S3.name}"
}

# Add ssm policy to the EC2 role
resource "aws_iam_role_policy_attachment" "ssm_for_ec2" {
  role       = "${aws_iam_role.role-EC2-S3.name}"
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2RoleforSSM"
}

