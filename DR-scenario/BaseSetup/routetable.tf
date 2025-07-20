resource "aws_internet_gateway" "dr_igw" {
  vpc_id = aws_vpc.dr_vpc.id
}

resource "aws_route_table" "dr_route_table" {
  vpc_id = aws_vpc.dr_vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.dr_igw.id
  }
}

resource "aws_route_table_association" "dr_subnet_assoc" {
  route_table_id = aws_route_table.dr_route_table.id
  subnet_id      = aws_subnet.dr_vm_subnet.id
}