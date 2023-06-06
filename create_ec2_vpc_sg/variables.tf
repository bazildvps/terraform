variable "vpc_cidr" {
  default = "192.168.0.0/20"
}

variable "env" {
  default = "For Ansible test"
}

variable "EC2_type" {
  default = "t2.micro"
}
variable "public_subnet_cidrs" {
  default = [
    "192.168.1.0/24",
    "192.168.2.0/24",
    "192.168.3.0/24"
  ]
}

variable "allow_ingress_ports_for_all" {
  type = list(number)
  default = [
    80,
    443,
    8080
  ]
}

variable "allow_ingress_ports_for_some_IPs" {
  type = list(any)
  default = [
    22
  ]
}

variable "IPs_to_allow_acces_from" {
  type = list(string)
  default = [
    "93.170.47.140/32"
  ]
}

variable "general_tags" {
  description = "Common tags for all"
  type        = map(any)
  default = {
    Owner      = "Bazil"
    Created_by = "Terraform"
    project    = "DevOps"
  }
}
