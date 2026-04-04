variable "ddns_enabled" {
  description = "Whether to enable MikroTik Dynamic DNS (DDNS). When enabled, the router registers a DNS name under sn.mynetname.net."
  type        = bool
  default     = false
}

variable "ddns_update_interval" {
  description = "How often to update the DDNS record. Must be a RouterOS time duration (e.g. '30s', '5m', '1h'). Empty string uses the router default."
  type        = string
  default     = "5m"

  validation {
    condition     = can(regex("^([0-9]+[smhdw])+$", var.ddns_update_interval)) || var.ddns_update_interval == ""
    error_message = "ddns_update_interval must be a valid RouterOS time duration (e.g. '30s', '5m', '1h', '1d') or an empty string for the router default."
  }
}

variable "back_to_home_vpn" {
  description = "Back to Home VPN feature mode. Controls the built-in VPN service provided by MikroTik Cloud."
  type        = string
  default     = "revoked-and-disabled"

  validation {
    condition     = contains(["enabled", "disabled", "revoked-and-disabled"], var.back_to_home_vpn)
    error_message = "back_to_home_vpn must be one of: 'enabled', 'disabled', 'revoked-and-disabled'."
  }
}

variable "update_time" {
  description = "Whether to synchronize the router clock with the MikroTik Cloud server. Useful when no NTP client is configured."
  type        = bool
  default     = false
}

variable "advanced_use_local_address" {
  description = "Whether to assign a local (internal) router address to the dynamic DNS name instead of the public address."
  type        = bool
  default     = false
}
