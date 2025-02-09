variable "compute_instance" {
  type = map(object({
    env_name       = string
    instance_name  = string
    instance_count = number
    image_family   = string
    public_ip      = bool
    label          = string
    serial_port    = number
    platform       = optional(string)
    core_fraction  = optional(number)
    cores          = optional(number)
    memory         = optional(number)
    preemptible    = optional(bool)
    internal_ip    = optional(string)
    }
  ))
  default = {
    worker-nod = {
      env_name       = "diplom"
      instance_name  = "worker-nod"
      instance_count = 2
      image_family   = "ubuntu-2404-lts-oslogin"
      public_ip      = true
      label          = "worker"
      serial_port    = 1
      platform       = "standard-v3"
      core_fraction  = 20
      cores          = 2
      memory         = 2
      preemptible    = true
    },
    master-nod = {
      env_name       = "diplom"
      instance_name  = "master-nod"
      instance_count = 1
      image_family   = "ubuntu-2404-lts-oslogin"
      public_ip      = true
      label          = "master"
      serial_port    = 1
      platform       = "standard-v3"
      core_fraction  = 20
      cores          = 2
      memory         = 2
      preemptible    = true
    },
    nat = {
      env_name       = "diplom"
      instance_name  = "nat-instance"
      instance_count = 1
      image_family   = "nat-instance-ubuntu-2204"
      public_ip      = true
      label          = "public"
      serial_port    = 1
      platform       = "standard-v3"
      core_fraction  = 20
      cores          = 2
      memory         = 2
      preemptible    = true
      internal_ip    = "192.168.30.254"
    },
  }
}
