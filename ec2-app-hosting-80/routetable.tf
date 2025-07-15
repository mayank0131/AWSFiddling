resource "aws_internet_gateway" "app_igw" {
  vpc_id = aws_vpc.app_vpc.id
}

resource "aws_route_table" "app_rtb" {
  vpc_id = aws_vpc.app_vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.app_igw.id
  }
}

resource "aws_route_table_association" "app_rtb_assoc" {
  for_each       = { for subnet in aws_subnet.bastion_subnet : subnet.availability_zone => subnet }
  subnet_id      = each.value.id
  route_table_id = aws_route_table.app_rtb.id
}

resource "aws_eip" "nat_gw_eip" {
  for_each = { for subnet in aws_subnet.bastion_subnet : subnet.availability_zone => subnet }
  domain   = "vpc"
}

resource "aws_nat_gateway" "nat" {
  for_each      = { for subnet in aws_subnet.bastion_subnet : subnet.availability_zone => subnet }
  allocation_id = aws_eip.nat_gw_eip[each.key].id
  subnet_id     = each.value.id
}

resource "aws_route_table" "nat_rtb" {
  for_each = aws_nat_gateway.nat
  vpc_id   = aws_vpc.app_vpc.id
  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = each.value.id
  }
}

resource "aws_route_table_association" "nat_rtb_assoc" {
  for_each       = { for subnet in aws_subnet.app_server_subnet : subnet.availability_zone => subnet }
  subnet_id      = each.value.id
  route_table_id = aws_route_table.nat_rtb[each.key].id
}