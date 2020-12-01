o099720109477utput "vpc_id" {
  value = "${aws_vpc.vpc.id}"
}

output "azs" {
  value = "${split(",",var.azs,)}"
}

output "public_subnets_id" {
  value = ["${aws_subnet.public.*.id}"]
}

output "private_subnets_id" {
  value = ["${aws_subnet.private.*.id}"]
}

output "aws_region" {
  value = "${var.region}"
}

output "ec2_public_ip" {
  value = ["${aws_instance.ec2.public_ip}"]
}

output "api_endpoint" {
  value = "${aws_api_gateway_deployment.deployment.invoke_url}"
}


output "lambda_sendCode_env_salesforce-cred" {
  value = "You have to set salesforce creds manually into the env variable"
}
