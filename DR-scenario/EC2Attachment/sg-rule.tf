data "http" "current_ip" {
  url = "https://ipv4.icanhazip.com"
}

locals {
  local_ip_cidr = "${trimspace(data.http.current_ip.response_body)}/32"
}

data "aws_security_group" "allow-sg" {
  name = "AllowTraffic"
}

resource "aws_security_group_rule" "add_current_ip" {
  security_group_id = data.aws_security_group.allow-sg.id
  protocol          = "tcp"
  from_port         = "22"
  to_port           = "22"
  type              = "ingress"
  cidr_blocks       = [local.local_ip_cidr]
}

resource "null_resource" "cleanup_sg_rule" {
  depends_on = [null_resource.ebs_volume_setup]
  provisioner "local-exec" {
    command = <<EOT
      echo "Revoking temp rule for ${local.local_ip_cidr}"
      aws ec2 revoke-security-group-ingress \
        --region ap-south-1 \
        --group-id ${data.aws_security_group.allow-sg} \
        --protocol tcp \
        --port 22 \
        --cidr ${local.local_ip_cidr}
    EOT
  }
}