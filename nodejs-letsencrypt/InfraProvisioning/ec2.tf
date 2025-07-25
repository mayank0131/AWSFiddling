data "aws_ami" "latest_ubuntu" {
  most_recent = "true"
  owners      = ["099720109477"]
  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-*-*-amd64-server-*"]
  }
}

resource "tls_private_key" "le_key" {
  algorithm = "RSA"
}

resource "aws_key_pair" "le_key_pair" {
  key_name   = "le_key_pair"
  public_key = trimspace(tls_private_key.le_key.public_key_openssh)
}

resource "aws_instance" "le_app_server" {
  subnet_id              = aws_subnet.le_subnet.id
  key_name               = aws_key_pair.le_key_pair.key_name
  ami                    = data.aws_ami.latest_ubuntu.image_id
  instance_type          = "t3.micro"
  vpc_security_group_ids = [aws_security_group.ssh_app_allow.id]
  user_data              = file("nginx_pm2_install.sh")
}

output "private_key" {
  value     = trimspace(tls_private_key.le_key.private_key_pem)
  sensitive = true
}