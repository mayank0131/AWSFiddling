# Commented out logic for getting local ip addresses
# data "http" "current_ip" {
#   url = "https://ipv4.icanhazip.com"
# }

locals {
  #   local_ip_cidr = "${trimspace(data.http.current_ip.response_body)}/32"
  ip_list = [for ip in split(",", data.external.env_var.result.ip_list) : trim(ip, " ")]
  cidr_blocks = [
    for ip in local.ip_list : "${ip}/32"
  ]
}

resource "aws_security_group" "lb_sg" {
  name   = "lb-sg"
  vpc_id = aws_vpc.app_vpc.id
  ingress {
    protocol    = "tcp"
    from_port   = "443"
    to_port     = "443"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    protocol    = "-1"
    from_port   = "0"
    to_port     = "0"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "bastion_sg" {
  name   = "bastion-sg"
  vpc_id = aws_vpc.app_vpc.id
  ingress {
    protocol    = "tcp"
    from_port   = "22"
    to_port     = "22"
    cidr_blocks = local.cidr_blocks
  }
  egress {
    protocol    = "-1"
    from_port   = "0"
    to_port     = "0"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "app_sg" {
  name   = "app-sg"
  vpc_id = aws_vpc.app_vpc.id
  ingress {
    protocol        = "tcp"
    from_port       = "80"
    to_port         = "80"
    security_groups = [aws_security_group.lb_sg.id]
  }
  ingress {
    protocol        = "tcp"
    from_port       = "22"
    to_port         = "22"
    security_groups = [aws_security_group.bastion_sg.id]
  }
  egress {
    protocol    = "-1"
    from_port   = "0"
    to_port     = "0"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
