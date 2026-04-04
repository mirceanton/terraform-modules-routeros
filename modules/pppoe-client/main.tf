resource "routeros_interface_pppoe_client" "this" {
  interface         = var.interface
  name              = var.name
  comment           = var.comment
  disabled          = var.disabled
  add_default_route = var.add_default_route
  use_peer_dns      = var.use_peer_dns
  user              = var.username
  password          = var.password
  max_mtu           = var.max_mtu
  max_mru           = var.max_mru
  keepalive_timeout = var.keepalive_timeout
  service_name      = var.service_name
  ac_name           = var.ac_name
  profile           = var.profile
}
