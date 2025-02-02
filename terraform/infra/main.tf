resource "yandex_vpc_network" "vpc" {
  name = var.vpc_name
}

resource "yandex_vpc_subnet" "public" {
  name           = var.public_subnets.name
  zone           = var.public_subnets.zone
  network_id     = yandex_vpc_network.vpc.id
  v4_cidr_blocks = [var.public_subnets.cidr]
}

resource "yandex_vpc_subnet" "private" {
  name           = var.private_subnets.name
  zone           = var.private_subnets.zone
  network_id     = yandex_vpc_network.vpc.id
  v4_cidr_blocks = [var.private_subnets.cidr]
}
