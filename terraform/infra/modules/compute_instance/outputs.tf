output "vm_info" {
  value = [for i in yandex_compute_instance.vm : {
    name   = i["name"]
    ext_ip = i["network_interface"][0]["nat_ip_address"]
    int_ip = i["network_interface"][0]["ip_address"]
  }]
}
