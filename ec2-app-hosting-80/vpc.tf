data "aws_availability_zones" "zones" {
  state = "available"
}
resource "aws_vpc" "app_vpc" {
  cidr_block = var.vpc_cidr
  tags = {
    Name = "bastion-vpc"
  }
}

resource "aws_subnet" "bastion_subnet" {
  count                   = var.public_subnet_count
  vpc_id                  = aws_vpc.app_vpc.id
  cidr_block              = cidrsubnet(var.vpc_cidr, 8, count.index + 1)
  map_public_ip_on_launch = true
  availability_zone       = data.aws_availability_zones.zones.names[count.index]
}

resource "aws_subnet" "app_server_subnet" {
  count             = var.private_subnet_count
  vpc_id            = aws_vpc.app_vpc.id
  cidr_block        = cidrsubnet(var.vpc_cidr, 8, count.index + 3)
  availability_zone = data.aws_availability_zones.zones.names[count.index]
}
