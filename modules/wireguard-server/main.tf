resource "routeros_interface_wireguard" "this" {
  name        = var.name
  comment     = var.comment
  listen_port = var.listen_port
  mtu         = var.mtu
  private_key = var.private_key
  disabled    = var.disabled
}

resource "routeros_ip_address" "this" {
  address   = var.address
  interface = routeros_interface_wireguard.this.name
  comment   = var.comment
  disabled  = var.disabled
}
