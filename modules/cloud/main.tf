resource "routeros_ip_cloud" "this" {
  ddns_enabled         = var.ddns_enabled ? "yes" : "no"
  ddns_update_interval = var.ddns_update_interval
  back_to_home_vpn     = var.back_to_home_vpn
  update_time          = var.update_time
}

resource "routeros_ip_cloud_advanced" "this" {
  use_local_address = var.advanced_use_local_address
}
