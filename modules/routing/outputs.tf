# --- Static Route Outputs -----------------------------------------------------

output "static_route_count" {
  description = "Total number of static routes managed by this module."
  value       = length(var.static_routes)
}

output "static_route_ids" {
  description = "Map of static route keys to their RouterOS resource IDs."
  value       = { for k, v in routeros_ip_route.this : k => v.id }
}
