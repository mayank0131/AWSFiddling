data "aws_availability_zones" "zones" {
  state = "available"
}
resource "aws_vpc" "app_vpc" {
  cidr_block = "10.1.0.0/16"
  tags = {
    Name = "bastion-vpc"
  }
}

resource "aws_subnet" "bastion_subnet" {
  count                   = 2
  vpc_id                  = aws_vpc.app_vpc.id
  cidr_block              = cidrsubnet(aws_vpc.app_vpc.cidr_block, 8, count.index + 1)
  map_public_ip_on_launch = true
  availability_zone       = data.aws_availability_zones.zones.names[count.index]
}

resource "aws_subnet" "app_server_subnet" {
  count             = 2
  vpc_id            = aws_vpc.app_vpc.id
  cidr_block        = cidrsubnet(aws_vpc.app_vpc.cidr_block, 8, count.index + 3)
  availability_zone = data.aws_availability_zones.zones.names[count.index]
}
