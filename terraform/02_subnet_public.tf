#### EIP creation
/*
resource "aws_eip" "ec2_eip" {
  vpc      = true
}


#### Associate EIP on EC2
resource "aws_eip_association" "eip_assoc" {
  instance_id   = "${aws_instance.ec2.id}"
  allocation_id = "${aws_eip.ec2_eip.id}"
}
*/

#### internet gateway creation
resource "aws_internet_gateway" "gw" {
  vpc_id = "${aws_vpc.vpc.id}"

  tags = {
    Name  = "${var.environment}-${var.application}-igw"
    Owner = "${var.owner}"
  }
}

#### public subnet creation
resource "aws_subnet" "public" {
  vpc_id                  = "${aws_vpc.vpc.id}"
  count                   = "1"
  cidr_block              = "${var.cidr_snpb}"
  availability_zone       = "eu-west-1a"
  map_public_ip_on_launch = "${var.map_public_ip_on_launch}"

  tags = {
    Name  = "${var.environment}-${var.application}-public-${count.index + 1}"
    Owner = "${var.owner}"
  }
}

#### public subnet route table creation
resource "aws_route_table" "rtpb" {
  vpc_id = "${aws_vpc.vpc.id}"

  tags = {
    Name  = "${lower("${var.environment}-${var.application}-public-routetable")}"
    Owner = "${var.owner}"
  }
}

resource "aws_route" "routepb" {
  route_table_id         = "${aws_route_table.rtpb.id}"
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = "${aws_internet_gateway.gw.id}"
}

#### public subnet route table association
resource "aws_route_table_association" "rtappb" {
  count          = "${length(split(",", var.azs))}"
  subnet_id      = "${element(aws_subnet.public.*.id, count.index)}"
  route_table_id = "${aws_route_table.rtpb.id}"
}
