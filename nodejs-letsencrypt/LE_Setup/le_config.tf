data "terraform_remote_state" "infra_state" {
  backend = "s3"
  config = {
    bucket = "lb-80-app"
    key    = "le-infra.tfstate"
    region = "ap-south-1"
  }
}

resource "null_resource" "certbot" {
  provisioner "remote-exec" {
    connection {
      type        = "ssh"
      host        = data.terraform_remote_state.infra_state.outputs.elastic_ip
      user        = "ubuntu"
      private_key = data.terraform_remote_state.infra_state.outputs.private_key
    }
    inline = [
      # Replace server_name _ with domain name
      "sudo sed -i 's/server_name _;/server_name test.infrawithmayank.com;/' /etc/nginx/sites-available/default",
      # Reload nginx with updated config
      "sudo nginx -t && sudo systemctl reload nginx",
      # Install certbot
      "sudo apt-get update",
      "sudo apt-get install -y software-properties-common",
      "sudo add-apt-repository universe -y",
      "sudo apt-get update",
      "sudo apt-get install -y certbot python3-certbot-nginx",
      "sudo certbot --nginx --non-interactive --agree-tos -m contact@infrawithmayank.com -d test.infrawithmayank.com",
    ]
  }
}