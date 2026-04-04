output "name" {
  description = "The name of the PPPoE client interface."
  value       = routeros_interface_pppoe_client.this.name
}

output "id" {
  description = "The unique identifier of the PPPoE client resource."
  value       = routeros_interface_pppoe_client.this.id
}

output "running" {
  description = "Whether the PPPoE client interface is currently running."
  value       = routeros_interface_pppoe_client.this.running
}

output "disabled" {
  description = "Whether the PPPoE client interface is disabled."
  value       = routeros_interface_pppoe_client.this.disabled
}
