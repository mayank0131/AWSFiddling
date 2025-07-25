resource "aws_internet_gateway" "le_igw" {
  vpc_id = aws_vpc.le_vpc.id
}

resource "aws_route_table" "le_rtb" {
  vpc_id = aws_vpc.le_vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.le_igw.id
  }
}

resource "aws_route_table_association" "le_subnet_assoc" {
  route_table_id = aws_route_table.le_rtb.id
  subnet_id      = aws_subnet.le_subnet.id
}

resource "aws_eip" "le_eip" {
  depends_on = [aws_internet_gateway.le_igw]
  domain     = "vpc"
}

resource "aws_eip_association" "eip_instance" {
  allocation_id = aws_eip.le_eip.id
  instance_id   = aws_instance.le_app_server.id
}

output "elastic_ip" {
  value = aws_eip.le_eip.public_ip
}