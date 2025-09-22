resource "aws_vpc" "pkvpc" {
  cidr_block = var.cidr
}

resource "aws_subnet" "pksubnet1" {
  vpc_id                  = aws_vpc.pkvpc.id
  cidr_block              = "10.0.0.0/24"
  availability_zone       = "us-east-1a"
  map_public_ip_on_launch = true
}

resource "aws_subnet" "pksubnet2" {
  vpc_id                  = aws_vpc.pkvpc.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = "us-east-1b"
  map_public_ip_on_launch = true
}

resource "aws_internet_gateway" "pkigw" {
  vpc_id = aws_vpc.pkvpc.id
}

resource "aws_route_table" "pkrt" {
  vpc_id = aws_vpc.pkvpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.pkigw.id
  }
}

resource "aws_route_table_association" "pkrouteasso1" {
  subnet_id      = aws_subnet.pksubnet1.id
  route_table_id = aws_route_table.pkrt.id
}
resource "aws_route_table_association" "pkrouteasso2" {
  subnet_id      = aws_subnet.pksubnet2.id
  route_table_id = aws_route_table.pkrt.id
}