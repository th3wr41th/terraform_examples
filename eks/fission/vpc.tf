# VPC Resources
#  * VPC
#  * Subnets
#  * Internet Gateway
#  * Route Table
resource "aws_vpc" "fission" {
  cidr_block = "10.0.0.0/16"

  tags = "${
    map(
      "Name", "${var.node-name}",
      "kubernetes.io/cluster/${var.cluster-name}", "shared",
    )
  }"
}

resource "aws_subnet" "fission" {
  count = 2

  availability_zone = "${data.aws_availability_zones.available.names[count.index]}"
  cidr_block        = "10.0.${count.index}.0/24"
  vpc_id            = "${aws_vpc.fission.id}"

  tags = "${
    map(
      "Name", "${var.node-name}",
      "kubernetes.io/cluster/${var.cluster-name}", "shared",
    )
  }"
}

resource "aws_internet_gateway" "fission" {
  vpc_id = "${aws_vpc.fission.id}"

  tags = {
    Name = "terraform-eks-demo"
  }
}

resource "aws_route_table" "fission" {
  vpc_id = "${aws_vpc.fission.id}"

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_internet_gateway.fission.id}"
  }
}

resource "aws_route_table_association" "fission" {
  count = 2

  subnet_id      = "${aws_subnet.fission.*.id[count.index]}"
  route_table_id = "${aws_route_table.fission.id}"
}
