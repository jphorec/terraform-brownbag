variable az_count { default = 2}
variable name {}
variable map_public_up { default = true }
# Create a VPC to launch our instances into
resource "aws_vpc" "brownbag_vpc" {
  cidr_block = "10.0.0.0/16"
}
data "aws_availability_zones" "available" {}
resource "aws_subnet" "brownbag_subnet" {
  count             = "${var.az_count}"
  cidr_block        = "${cidrsubnet(aws_vpc.brownbag_vpc.cidr_block, 8, count.index)}"
  availability_zone = "${data.aws_availability_zones.available.names[count.index]}"
  vpc_id            = "${aws_vpc.brownbag_vpc.id}"
  map_public_ip_on_launch = "${var.map_public_up}"
}

# Create an internet gateway to give our subnet access to the outside world
resource "aws_internet_gateway" "brownbag_gateway" {
  vpc_id = "${aws_vpc.brownbag_vpc.id}"
}

resource "aws_route_table" "r" {
  vpc_id = "${aws_vpc.brownbag_vpc.id}"

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_internet_gateway.brownbag_gateway.id}"
  }
}

resource "aws_route_table_association" "a" {
  count          = "${var.az_count}"
  subnet_id      = "${element(aws_subnet.brownbag_subnet.*.id, count.index)}"
  route_table_id = "${aws_route_table.r.id}"
}

output "vpc_id" {
    value = "${aws_vpc.brownbag_vpc.id}"
}
output "subnet_id" {
    value = "${aws_subnet.brownbag_subnet.0.id}"
}
output "subnet_ids" {
    value = ["${aws_subnet.brownbag_subnet.*.id}"]
}