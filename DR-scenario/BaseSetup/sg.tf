# data "http" "current_ip" {
#   url = "https://ipv4.icanhazip.com"
# }

# locals {
#   local_ip_cidr = "${trimspace(data.http.current_ip.response_body)}/32"
# }

locals {
  ip_list = [for ip in split(",", data.external.env_var.result.ip_list) : trim(ip, " ")]
  cidr_blocks = [
    for ip in local.ip_list : "${ip}/32"
  ]
}

resource "aws_security_group" "allow_traffic" {
  name   = "AllowTraffic"
  vpc_id = aws_vpc.dr_vpc.id
  ingress {
    from_port   = "22"
    to_port     = "22"
    protocol    = "tcp"
    cidr_blocks = local.cidr_blocks
  }
  ingress {
    from_port   = "80"
    to_port     = "80"
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port   = "0"
    to_port     = "0"
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}