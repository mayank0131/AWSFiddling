terraform {
  required_version = "~> 1.12.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.6.0"
    }
    null = {
      source  = "hashicorp/null"
      version = "~> 3.2.0"
    }
    tls = {
      source  = "hashicorp/tls"
      version = "~> 4.1.0"
    }
  }
  backend "s3" {
    bucket       = "lb-80-app"
    key          = "dr-attachment.tfstate"
    region       = "ap-south-1" # cannot refer variables
    profile      = "default"    #cannot refer variables
    use_lockfile = true
  }
}