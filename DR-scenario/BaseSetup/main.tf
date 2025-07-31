terraform {
  required_version = "~> 1.12.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.6.0"
    }
    http = {
      source  = "hashicorp/http"
      version = "~> 3.5.0"
    }
  }
  backend "s3" {
    bucket       = "lb-80-app"
    key          = "dr.tfstate"
    region       = "ap-south-1" # cannot refer variables
    use_lockfile = true
  }
}

data "external" "env_var" {
  program = ["jq", "-n", "env"]
}