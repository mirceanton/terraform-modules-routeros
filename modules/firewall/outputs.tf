# --- Interface List Outputs ----------------------------------------------------

output "interface_list_names" {
  description = "List of interface list names created by this module."
  value       = [for k, v in routeros_interface_list.this : v.name]
}

output "interface_list_ids" {
  description = "Map of interface list names to their RouterOS resource IDs."
  value       = { for k, v in routeros_interface_list.this : k => v.id }
}

# --- NAT Rule Outputs ---------------------------------------------------------

output "nat_rule_count" {
  description = "Total number of NAT rules managed by this module."
  value       = length(var.nat_rules)
}

output "nat_rule_ids" {
  description = "Map of NAT rule sort keys to their RouterOS resource IDs."
  value       = { for k, v in routeros_ip_firewall_nat.this : k => v.id }
}

# --- Filter Rule Outputs ------------------------------------------------------

output "filter_rule_count" {
  description = "Total number of filter rules managed by this module."
  value       = length(var.filter_rules)
}

output "filter_rule_ids" {
  description = "Map of filter rule sort keys to their RouterOS resource IDs."
  value       = { for k, v in routeros_ip_firewall_filter.this : k => v.id }
}
