resource "aws_vpc" "pkvpc" {
  cidr_block = var.cidr
}

resource "aws_subnet" "pksubnet1" {
    vpc_id     = aws_vpc.pkvpc.id
    cidr_block = "10.0.0.0/24"
    availability_zone = "us-east-1a"
    map_public_ip_on_launch = true
}

resource "aws_subnet" "pksubnet2" {
    vpc_id     = aws_vpc.pkvpc.id
    cidr_block = "10.0.0.0/24"
    availability_zone = "us-east-1b"
    map_public_ip_on_launch = true
}