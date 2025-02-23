output "worker-nod_info" {
  value = (module.worker-nod
  )
}

output "master-nod_info" {
  value = (module.master-nod
  )
}

output "nlb-monitoring_ext_ip" {
  value = yandex_lb_network_load_balancer.nlb-monitoring.listener.*.external_address_spec[0].*.address  
}

output "nlb-app_ext_ip" {
  value = yandex_lb_network_load_balancer.nlb-app.listener.*.external_address_spec[0].*.address 
}