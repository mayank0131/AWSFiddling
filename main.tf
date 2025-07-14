terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.2.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.7.0"
    }
  }
  required_version = "~> 1.12.0"
  # backend "s3" {
  #   bucket = "lb-80-app"
  #   key = "terraform.tfstate"
  #   region = "ap-south-1" # cannot refer variables
  #   profile = "default" #cannot refer variables
  # }
}

provider "aws" {
  region  = var.region
  profile = var.profile
}