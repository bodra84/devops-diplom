variable "vpc_name" {
  type        = string
  default     = "my-vpc"
  description = "VPC network"
}

variable "sub-zone-a" {
  type = object({
    name = string,
    cidr = string,
    zone = string
  })
  default     = { name = "sub-zone-a", zone = "ru-central1-a", cidr = "192.168.10.0/24" }
  description = "name, cidr and zone for subnets"
}

variable "sub-zone-b" {
  type = object({
    name = string,
    cidr = string,
    zone = string
  })
  default     = { name = "sub-zone-b", zone = "ru-central1-b", cidr = "192.168.20.0/24" }
  description = "name, cidr and zone for subnets"
}

variable "sub-zone-d" {
  type = object({
    name = string,
    cidr = string,
    zone = string
  })
  default     = { name = "sub-zone-d", zone = "ru-central1-d", cidr = "192.168.30.0/24" }
  description = "name, cidr and zone for subnets"
}
