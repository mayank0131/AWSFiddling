data "http" "current_ip" {
  url = "https://ipv4.icanhazip.com"
}

locals {
  local_ip_cidr = "${trimspace(data.http.current_ip.response_body)}/32"
}

resource "aws_security_group" "ssh_app_allow" {
  vpc_id = aws_vpc.le_vpc.id
  ingress {
    description = "Allow SSH"
    cidr_blocks = [local.local_ip_cidr]
    from_port   = "22"
    to_port     = "22"
    protocol    = "tcp"
  }
  ingress {
    description = "Allow HTTP"
    cidr_blocks = ["0.0.0.0/0"]
    from_port   = "80"
    to_port     = "80"
    protocol    = "tcp"
  }
  ingress {
    description = "Allow HTTP"
    cidr_blocks = ["0.0.0.0/0"]
    from_port   = "443"
    to_port     = "443"
    protocol    = "tcp"
  }
  egress {
    description = "Allow Outbound"
    cidr_blocks = ["0.0.0.0/0"]
    from_port   = "0"
    to_port     = "0"
    protocol    = "-1"
  }
}