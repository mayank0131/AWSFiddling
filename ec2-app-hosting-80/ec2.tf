resource "random_shuffle" "public_subnet" {
  input        = aws_subnet.bastion_subnet[*].id
  result_count = 1
  keepers = {
    instance_name = "bastion-server"
  }
}

resource "tls_private_key" "private_key" {
  algorithm = "RSA"
}

resource "aws_key_pair" "key_pair" {
  key_name   = "bastion-ssh-key"
  public_key = trimspace(tls_private_key.private_key.public_key_openssh)
}

data "aws_ami" "ubuntu_ami" {
  most_recent = "true"
  owners      = ["099720109477"]
  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-*-*-amd64-server-*"]
  }
}

resource "aws_instance" "bastion_ec2" {
  ami                    = data.aws_ami.ubuntu_ami.image_id
  instance_type          = "t3.nano"
  subnet_id              = random_shuffle.public_subnet.result[0]
  key_name               = aws_key_pair.key_pair.key_name
  vpc_security_group_ids = [aws_security_group.bastion_sg.id]
  tags = {
    "Name" = "bastion-server"
  }
}

resource "aws_instance" "application_ec2" {
  count                  = var.app_instance_count
  ami                    = data.aws_ami.ubuntu_ami.image_id
  instance_type          = "t3.micro"
  subnet_id              = aws_subnet.app_server_subnet[count.index % length(aws_subnet.app_server_subnet)].id
  key_name               = aws_key_pair.key_pair.key_name
  vpc_security_group_ids = [aws_security_group.app_sg.id]
  user_data              = file("install-apache.sh")
  tags = {
    "Name" = "app-${count.index}"
  }
}
