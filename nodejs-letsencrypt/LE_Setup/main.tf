terraform {
  required_version = "~> 1.12.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
  backend "s3" {
    bucket       = "lb-80-app"
    key          = "le-setup.tfstate"
    region       = "ap-south-1"
    profile      = "default"
    use_lockfile = "true"
  }
}