# Создание сети
resource "yandex_vpc_network" "vpc" {
  name = var.vpc_name
}

# Создание подсетей в зонах доступности a, b, d
resource "yandex_vpc_subnet" "sub-zone-a" {
  name           = var.sub-zone-a.name
  zone           = var.sub-zone-a.zone
  network_id     = yandex_vpc_network.vpc.id
  v4_cidr_blocks = [var.sub-zone-a.cidr]
}

resource "yandex_vpc_subnet" "sub-zone-b" {
  name           = var.sub-zone-b.name
  zone           = var.sub-zone-b.zone
  network_id     = yandex_vpc_network.vpc.id
  v4_cidr_blocks = [var.sub-zone-b.cidr]
}

resource "yandex_vpc_subnet" "sub-zone-d" {
  name           = var.sub-zone-d.name
  zone           = var.sub-zone-d.zone
  network_id     = yandex_vpc_network.vpc.id
  v4_cidr_blocks = [var.sub-zone-d.cidr]
}

# Создание инстансов для worker node
module "worker-nod" {
  source                 = "./modules/compute_instance"
  env_name               = var.compute_instance.worker-nod.env_name
  network_id             = yandex_vpc_network.vpc.id
  subnet_zones           = [var.sub-zone-a.zone, var.sub-zone-b.zone]
  subnet_ids             = [yandex_vpc_subnet.sub-zone-a.id, yandex_vpc_subnet.sub-zone-b.id]
  instance_name          = var.compute_instance.worker-nod.instance_name
  instance_count         = var.compute_instance.worker-nod.instance_count
  image_family           = var.compute_instance.worker-nod.image_family
  public_ip              = var.compute_instance.worker-nod.public_ip
  boot_disk_size         = var.compute_instance.worker-nod.disk_size
  platform               = var.compute_instance.worker-nod.platform
  instance_core_fraction = var.compute_instance.worker-nod.core_fraction
  instance_cores         = var.compute_instance.worker-nod.cores
  instance_memory        = var.compute_instance.worker-nod.memory
  preemptible            = var.compute_instance.worker-nod.preemptible

  labels = {
    k8s = var.compute_instance.worker-nod.label
  }

  metadata = {
    user-data          = data.template_file.cloudinit.rendered
    serial-port-enable = var.compute_instance.worker-nod.serial_port
  }
}

# Создание инстанса для master node
module "master-nod" {
  source                 = "./modules/compute_instance"
  env_name               = var.compute_instance.master-nod.env_name
  network_id             = yandex_vpc_network.vpc.id
  subnet_zones           = [var.sub-zone-d.zone]
  subnet_ids             = [yandex_vpc_subnet.sub-zone-d.id]
  instance_name          = var.compute_instance.master-nod.instance_name
  instance_count         = var.compute_instance.master-nod.instance_count
  image_family           = var.compute_instance.master-nod.image_family
  public_ip              = var.compute_instance.master-nod.public_ip
  boot_disk_size         = var.compute_instance.master-nod.disk_size
  platform               = var.compute_instance.master-nod.platform
  instance_core_fraction = var.compute_instance.master-nod.core_fraction
  instance_cores         = var.compute_instance.master-nod.cores
  instance_memory        = var.compute_instance.master-nod.memory
  preemptible            = var.compute_instance.master-nod.preemptible

  labels = {
    k8s = var.compute_instance.master-nod.label
  }

  metadata = {
    user-data          = data.template_file.cloudinit.rendered
    serial-port-enable = var.compute_instance.master-nod.serial_port
  }
}

data "template_file" "cloudinit" {
  template = file("./cloud-init.yml")
  vars = {
    username       = local.username
    ssh_public_key = local.ssh_public_key
  }
}

# Получение информации о vm
locals {
  master_nodes = [for i in module.master-nod.vm_info: i]
  worker_nodes = [for i in module.worker-nod.vm_info: i]
  all_vms = concat(module.worker-nod.vm_info, module.master-nod.vm_info)  
}

# Сохранение файла hosts.ini
resource "null_resource" "vm_provision" {
  depends_on = [
    module.master-nod,
    module.worker-nod
  ]

  provisioner "local-exec" {
    command = <<-EOA
    echo "${templatefile("./hosts.tmpl",
    {master-nods = local.master_nodes,
     worker-nods = local.worker_nodes,
})}" > hosts.ini
    EOA  
}
triggers = {
  always_run = "${timestamp()}"
}
}

# Создание target_group для nlb
resource "yandex_lb_target_group" "all-vms" {
  name      = "all-vms"
  dynamic "target" {
    for_each = local.all_vms
    content {
      subnet_id = target.value.subnet_id
      address   = target.value.int_ip
    }
  }
}

# Создание nlb для мониторинга и приложения
resource "yandex_lb_network_load_balancer" "nlb-monitoring" {
  name = "my-nlb-monitoring"
 
  listener {
    name = var.nlb_listener.monitoring.name
    port = var.nlb_listener.monitoring.port
    target_port = var.nlb_listener.monitoring.target_port
    external_address_spec {
      ip_version = "ipv4"
    }
  }
  
  attached_target_group {
    target_group_id = "${yandex_lb_target_group.all-vms.id}"

    healthcheck {
      name = var.nlb_listener.monitoring.name
      tcp_options {
        port = var.nlb_listener.monitoring.target_port
      }
    }
  }  
  depends_on = [yandex_lb_target_group.all-vms]
}

resource "yandex_lb_network_load_balancer" "nlb-app" {
  name = "my-nlb-app"
  
  listener {
    name = var.nlb_listener.app.name
    port = var.nlb_listener.app.port
    target_port = var.nlb_listener.app.target_port
    external_address_spec {
      ip_version = "ipv4"
    }
  }

  attached_target_group {
    target_group_id = "${yandex_lb_target_group.all-vms.id}"

    healthcheck {
      name = var.nlb_listener.app.name
      tcp_options {
        port = var.nlb_listener.app.target_port
      }
    }
  }
  depends_on = [yandex_lb_target_group.all-vms, yandex_lb_network_load_balancer.nlb-monitoring]
}