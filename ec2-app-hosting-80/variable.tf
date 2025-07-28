variable "region" {
  type    = string
  default = "ap-south-1"
}

variable "profile" {
  type    = string
  default = "default"
}

variable "app_instance_count" {
  type    = string
  default = "2"
}

variable "vpc_cidr" {
  type    = string
  default = "10.0.0.0/16"
}

variable "public_subnet_count" {
  type    = number
  default = 2
}

variable "private_subnet_count" {
  type    = number
  default = 2
}

variable "bucket_name" {
  type    = string
  default = "lb-80-app"
}

variable "domain" {
  type    = string
  default = "test.infrawithmayank.com"
}

variable "rolename" {
  type = string
  description = "Rolename to be assumed by pipeline"
}