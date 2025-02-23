variable "nlb_listener" {
  type = map(object({
    name        = string
    port        = number
    target_port = number
     }
  ))
  default = {
    monitoring = {
      name        = "grafana-listener"
      port        = 80
      target_port = 30600
    },
    app = {
      name        = "app-listener"
      port        = 80
      target_port = 30500
    }
    }
}
