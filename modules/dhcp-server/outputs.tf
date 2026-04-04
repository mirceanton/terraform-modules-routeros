output "server_name" {
  description = "The name of the DHCP server resource."
  value       = routeros_ip_dhcp_server.this.name
}

output "server_id" {
  description = "The ID of the DHCP server resource."
  value       = routeros_ip_dhcp_server.this.id
}

output "pool_name" {
  description = "The name of the DHCP IP pool."
  value       = routeros_ip_pool.this.name
}

output "network_address" {
  description = "The network address in CIDR notation served by this DHCP server."
  value       = var.network
}

output "gateway" {
  description = "The gateway IP address provided to DHCP clients."
  value       = local.gateway
}

output "static_lease_count" {
  description = "The number of static DHCP leases configured."
  value       = length(var.static_leases)
}

output "dns_record_count" {
  description = "The number of DNS records created for static leases."
  value       = length(local.leases_with_dns)
}
