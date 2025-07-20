data "aws_availability_zones" "zones" {
  state = "available"
}

locals {
  selected_az = var.az_failure ? data.aws_availability_zones.zones.names[1] : data.aws_availability_zones.zones.names[0]
}

resource "aws_vpc" "dr_vpc" {
  cidr_block = var.vpc_cidr
  tags = {
    "Name" = "DR-VPC"
  }
}

resource "aws_subnet" "dr_vm_subnet" {
  vpc_id                  = aws_vpc.dr_vpc.id
  cidr_block              = cidrsubnet(var.vpc_cidr, 4, 15)
  availability_zone       = local.selected_az
  map_public_ip_on_launch = true
  tags = {
    "Name" = "vm-subnet"
  }
}