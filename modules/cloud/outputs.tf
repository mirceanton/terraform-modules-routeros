output "dns_name" {
  description = "The DDNS hostname assigned by MikroTik Cloud (e.g. <serial>.sn.mynetname.net). Only populated when ddns_enabled is true."
  value       = routeros_ip_cloud.this.dns_name
}

output "public_address" {
  description = "The public IPv4 address of the router as detected by MikroTik Cloud."
  value       = routeros_ip_cloud.this.public_address
}

output "public_address_ipv6" {
  description = "The public IPv6 address of the router as detected by MikroTik Cloud."
  value       = routeros_ip_cloud.this.public_address_ipv6
}
