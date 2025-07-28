variable "vpc_cidr" {
  type    = string
  default = "10.1.1.0/24"
}

variable "az_failure" {
  type    = bool
  default = false
}

variable "create_volume_from_snapshot" {
  type    = bool
  default = false
}