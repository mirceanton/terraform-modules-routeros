output "name" {
  description = "The name of the created WireGuard interface."
  value       = routeros_interface_wireguard.this.name
}

output "public_key" {
  description = "The WireGuard public key of the server interface. Share this with peers to establish connections."
  value       = routeros_interface_wireguard.this.public_key
}

output "private_key" {
  description = "The WireGuard private key of the server interface."
  value       = routeros_interface_wireguard.this.private_key
  sensitive   = true
}

output "address" {
  description = "The IP address in CIDR notation assigned to the WireGuard interface."
  value       = routeros_ip_address.this.address
}

output "listen_port" {
  description = "The UDP port the WireGuard interface is listening on."
  value       = routeros_interface_wireguard.this.listen_port
}

output "mtu" {
  description = "The MTU configured on the WireGuard interface."
  value       = routeros_interface_wireguard.this.mtu
}

output "running" {
  description = "Whether the WireGuard interface is currently running."
  value       = routeros_interface_wireguard.this.running
}
