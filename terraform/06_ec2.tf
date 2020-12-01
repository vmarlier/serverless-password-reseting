data "aws_ami" "ami_amzn2_linux" {
  most_recent = true
  owners      = ["XXXXXXXXXXXX"]

  filter {
    name = "name"
    //values = ["amzn2-ami-hvm*x86*"]
    values = ["ubuntu/images/hvm-ssd/ubuntu-xenial-16.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

}

resource "aws_instance" "ec2" {
  ami                    = "${data.aws_ami.ami_amzn2_linux.id}"
  instance_type          = "${var.ec2_type}"
  iam_instance_profile   = "${aws_iam_instance_profile.EC2-S3-instance-profile.name}"
  subnet_id              = "${element(aws_subnet.private.*.id, 1)}"
  vpc_security_group_ids = ["${aws_security_group.allow_http.id}", "${aws_security_group.allow_ec2_to_apigw_eni.id}"]
  user_data              = "${data.template_file.user_data.rendered}"

  tags = {
    Name  = "${var.environment}-${var.application}-ec2"
    Owner = "${var.owner}"
  }
}

resource "aws_security_group" "allow_http" {
  name        = "allow_http"
  description = "Allow HTTP inbound traffic"
  vpc_id      = "${aws_vpc.vpc.id}"

  ingress {
    from_port       = 8080
    to_port         = 8080
    protocol        = "TCP"
    security_groups = ["${aws_security_group.sg-lb.id}"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "allow_ec2_to_apigw_eni" {
  name        = "allow_ec2_to_apigw_eni"
  description = "Allow EC2 to pass through apigw ENI"
  vpc_id      = "${aws_vpc.vpc.id}"

  egress {
    from_port       = 443
    to_port         = 443
    protocol        = "TCP"
    security_groups = ["${aws_security_group.allow_endpoint_apigw.id}"]
  }
}

data "template_file" "user_data" {
  template = "${file("userdata.txt")}"
  vars = {
    invoke_url = "${aws_api_gateway_deployment.deployment.invoke_url}"
  }
}

#### Load Balencer
resource "aws_lb" "lb" {
  name               = "${var.environment}-${var.application}-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = ["${aws_security_group.sg-lb.id}"]
  subnets            = ["${element(aws_subnet.public.*.id, 1)}", "${element(aws_subnet.private.*.id, 1)}"]

  enable_deletion_protection = false

  access_logs {
    bucket  = "${aws_s3_bucket.lb_logs.bucket}"
    prefix  = "alb-logs-${var.application}"
    enabled = true
  }

  tags = {
    Name  = "${var.environment}-${var.application}-alb"
    Owner = "${var.owner}"
  }
}

resource "aws_lb_target_group" "lb_tg" {
  name     = "${var.environment}-${var.application}-alb-tg"
  port     = 8080
  protocol = "HTTP"
  vpc_id   = "${aws_vpc.vpc.id}"
}

resource "aws_lb_target_group_attachment" "lb_tg_at" {
  target_group_arn = "${aws_lb_target_group.lb_tg.arn}"
  target_id        = "${aws_instance.ec2.id}"
  port             = 8080
}

resource "aws_lb_listener" "lb_l" {
  load_balancer_arn = "${aws_lb.lb.arn}"
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = "${aws_lb_target_group.lb_tg.arn}"
  }
}

resource "aws_security_group" "sg-lb" {
  name        = "load_balencer_sg"
  description = "allow lb to accept request on 8080 port from anywhere then redirect it to the EC2"
  vpc_id      = "${aws_vpc.vpc.id}"

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "TCP"
    cidr_blocks = ["0.0.0.0/0"]
  }
  /*
  egress {
    from_port       = 8080
    to_port         = 8080
    protocol        = "TCP"
    security_groups = ["${aws_security_group.allow_http.id}"]
  }*/
}

# Add the egress rule on sg-lb after creation to avoid the cycle terraform error with the allow_http sg
resource "aws_security_group_rule" "allow_all" {
  type                     = "egress"
  from_port                = 8080
  to_port                  = 8080
  protocol                 = "tcp"
  source_security_group_id = "${aws_security_group.allow_http.id}"

  security_group_id = "${aws_security_group.sg-lb.id}"
}

