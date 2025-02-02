variable "vpc_name" {
  type        = string
  default     = "my-vpc"
  description = "VPC network"
}

variable "public_subnets" {
  type = object({
    name = string,
    cidr = string,
    zone = string
  })
  default     = { name = "public", zone = "ru-central1-a", cidr = "192.168.10.0/24" }
  description = "name, cidr and zone for subnets"
}

variable "private_subnets" {
  type = object({
    name = string,
    cidr = string,
    zone = string
  })
  default     = { name = "private", zone = "ru-central1-b", cidr = "192.168.20.0/24" }
  description = "name, cidr and zone for subnets"
}
