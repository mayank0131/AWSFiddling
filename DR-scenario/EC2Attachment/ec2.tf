data "aws_ami" "latest_ubuntu" {
  most_recent = "true"
  owners      = ["099720109477"]
  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-*-*-amd64-server-*"]
  }
}

data "aws_subnet" "instance_subnet" {
  filter {
    name   = "tag:Name"
    values = ["vm-subnet"]
  }
}

data "aws_ebs_volume" "volume" {
  most_recent = true
  filter {
    name   = "tag:Name"
    values = ["volume-1"]
  }
  filter {
    name   = "availability-zone"
    values = [data.aws_subnet.instance_subnet.availability_zone]
  }
  # filter {
  #   name   = "status"
  #   values = ["available"]
  # }
}

data "aws_network_interface" "eni" {
  filter {
    name   = "tag:Name"
    values = ["eni-1"]
  }
}

data "aws_eip" "elastic_ip" {
  filter {
    name   = "tag:Name"
    values = ["dr-elastic-ip"]
  }
}

resource "tls_private_key" "login_key" {
  algorithm = "RSA"
}

resource "aws_key_pair" "dr_login_key" {
  public_key = trimspace(tls_private_key.login_key.public_key_openssh)
  key_name   = "login_key"
}

resource "aws_instance" "dr_instance" {
  ami           = data.aws_ami.latest_ubuntu.image_id
  key_name      = aws_key_pair.dr_login_key.key_name
  instance_type = "t3.micro"
  user_data     = file("install-apache.sh")
  network_interface {
    network_interface_id = data.aws_network_interface.eni.id
    device_index         = 0
  }
}

resource "aws_volume_attachment" "dr_volume" {
  instance_id = aws_instance.dr_instance.id
  volume_id   = data.aws_ebs_volume.volume.id
  device_name = "/dev/sdh"
}

resource "aws_network_interface_sg_attachment" "dr_sg" {
  network_interface_id = data.aws_network_interface.eni.id
  security_group_id    = data.aws_security_group.allow-sg.id
}

resource "null_resource" "ebs_volume_setup" {
  depends_on = [aws_volume_attachment.dr_volume, aws_security_group_rule.add_current_ip]

  connection {
    type        = "ssh"
    user        = "ubuntu"
    private_key = trimspace(tls_private_key.login_key.private_key_openssh)
    host        = data.aws_eip.elastic_ip.public_ip
  }

  provisioner "file" {
    source      = "mount-ebs.sh"
    destination = "/tmp/mount-ebs.sh"
  }

  provisioner "remote-exec" {
    inline = [
      "chmod +x /tmp/mount-ebs.sh",
      "sudo /tmp/mount-ebs.sh"
    ]
  }
}