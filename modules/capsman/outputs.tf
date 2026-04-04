output "wifi_passphrases" {
  description = "Map of WiFi network keys to their passphrases (provided or auto-generated)."
  value       = local.wifi_passphrases
  sensitive   = true
}

output "configured_ssids" {
  description = "List of all configured WiFi SSIDs."
  value       = [for k, v in var.wifi_networks : v.ssid]
}

output "bands_in_use" {
  description = "List of unique radio bands configured across all WiFi networks."
  value       = tolist(local.unique_bands)
}

output "provisioning_rule_count" {
  description = "Number of CAPsMAN provisioning rules created (one per band)."
  value       = length(routeros_wifi_provisioning.this)
}
