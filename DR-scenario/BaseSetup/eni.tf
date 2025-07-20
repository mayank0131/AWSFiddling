resource "aws_network_interface" "eni" {
  subnet_id = aws_subnet.dr_vm_subnet.id
  tags = {
    "Name" = "eni-1"
  }
}

resource "aws_eip" "eni_eip" {
  network_interface = aws_network_interface.eni.id
  depends_on        = [aws_internet_gateway.dr_igw]
  tags = {
    "Name" = "dr-elastic-ip"
  }
}