resource "aws_vpc" "le_vpc" {
  cidr_block = var.vpc_cidr
}

resource "aws_subnet" "le_subnet" {
  cidr_block              = cidrsubnet(var.vpc_cidr, 8, 1)
  vpc_id                  = aws_vpc.le_vpc.id
  map_public_ip_on_launch = true
}
