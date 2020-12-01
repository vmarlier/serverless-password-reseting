#### EIP creation
resource "aws_eip" "nat_gateway_eip" {
  vpc = true
}


#### Nat gateway creation with EIP association
resource "aws_nat_gateway" "gw" {
  allocation_id = "${aws_eip.nat_gateway_eip.id}"
  subnet_id     = "${element(aws_subnet.public.*.id, 1)}"

  tags = {
    Name  = "${lower("${var.environment}-${var.application}-nat_gateway")}"
    Owner = "${var.owner}"
  }
}

#### Private subnet creation
resource "aws_subnet" "private" {
  vpc_id                  = "${aws_vpc.vpc.id}"
  count                   = "1"
  cidr_block              = "${var.cidr_snpr}"
  availability_zone       = "eu-west-1b"
  map_public_ip_on_launch = "false"

  tags = {
    Name  = "${var.environment}-${var.application}-private-${count.index + 1}"
    Owner = "${var.owner}"
  }
}

#### Private subnet route table creation
resource "aws_route_table" "rtpr" {
  vpc_id = "${aws_vpc.vpc.id}"

  tags = {
    Name  = "${lower("${var.environment}-${var.application}-private-routetable")}"
    Owner = "${var.owner}"
  }
}

resource "aws_route" "routepr" {
  route_table_id         = "${aws_route_table.rtpr.id}"
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = "${aws_nat_gateway.gw.id}"
}

#### Private subnet route table association
resource "aws_route_table_association" "rtappr" {
  count          = "${length(split(",", var.azs))}"
  subnet_id      = "${element(aws_subnet.private.*.id, count.index)}"
  route_table_id = "${aws_route_table.rtpr.id}"
}
