# =================================================================================================
# Device settings
# =================================================================================================
variable "hostname" {
  type        = string
  description = "The hostname (system identity) to assign to this MikroTik device."
}

variable "timezone" {
  type        = string
  default     = "UTC"
  description = "The timezone to set on the device (e.g., 'UTC', 'America/New_York', 'Europe/London')."

  validation {
    condition     = can(regex("^[A-Z][a-zA-Z0-9_]+(/[A-Z][a-zA-Z0-9_-]+)*$", var.timezone)) || var.timezone == "UTC"
    error_message = "Timezone must be a valid tz database name (e.g., 'UTC', 'America/New_York')."
  }
}

variable "disable_ipv6" {
  type        = bool
  default     = false
  description = "Whether to disable IPv6 on the device."
}

variable "ntp_servers" {
  type        = list(string)
  default     = ["time.cloudflare.com"]
  description = "List of NTP server addresses for time synchronization."
}

variable "ntp_mode" {
  type        = string
  default     = "unicast"
  description = "NTP client mode. Valid values: unicast, broadcast, multicast, manycast."

  validation {
    condition     = contains(["unicast", "broadcast", "multicast", "manycast"], var.ntp_mode)
    error_message = "NTP mode must be one of: unicast, broadcast, multicast, manycast."
  }
}

# =================================================================================================
# Management access
# =================================================================================================
variable "mac_server_interfaces" {
  type        = string
  default     = "all"
  description = "Interface list to allow MAC server access on (e.g., 'all', 'none', or a specific interface list name)."
}

variable "bandwidth_server_enabled" {
  type        = bool
  default     = false
  description = "Whether to enable the bandwidth test server."
}

# =================================================================================================
# IP Services
# =================================================================================================
variable "ip_services" {
  type = map(object({
    enabled = bool
    port    = number
  }))
  default = {
    "api"     = { enabled = false, port = 8728 }
    "api-ssl" = { enabled = true, port = 8729 }
    "ftp"     = { enabled = false, port = 21 }
    "ssh"     = { enabled = false, port = 22 }
    "telnet"  = { enabled = false, port = 23 }
    "winbox"  = { enabled = true, port = 8291 }
    "www"     = { enabled = false, port = 80 }
    "www-ssl" = { enabled = true, port = 443 }
  }
  description = "Map of IP services to configure. Each service has an 'enabled' flag and a 'port' number. TLS services (api-ssl, www-ssl) automatically use the device certificate."

  validation {
    condition = alltrue([
      for name, svc in var.ip_services : svc.port > 0 && svc.port <= 65535
    ])
    error_message = "All service ports must be between 1 and 65535."
  }
}

variable "tls_version" {
  type        = string
  default     = "only-1.2"
  description = "TLS version to use for SSL-enabled IP services (api-ssl, www-ssl)."

  validation {
    condition     = contains(["only-1.2", "only-1.0", "any"], var.tls_version)
    error_message = "TLS version must be one of: only-1.2, only-1.0, any."
  }
}

# =================================================================================================
# Certificate settings
# =================================================================================================
variable "certificate_common_name" {
  type        = string
  description = "Common Name (CN) for the device TLS certificate."
}

variable "certificate_country" {
  type        = string
  default     = ""
  description = "Country code (C) for the device certificate (e.g., 'US', 'DE')."
}

variable "certificate_locality" {
  type        = string
  default     = ""
  description = "Locality (L) for the device certificate (e.g., 'San Francisco')."
}

variable "certificate_organization" {
  type        = string
  default     = ""
  description = "Organization (O) for the device certificate."
}

variable "certificate_unit" {
  type        = string
  default     = ""
  description = "Organizational Unit (OU) for the device certificate."
}

variable "certificate_key_type" {
  type        = string
  default     = "prime256v1"
  description = "Key type/size for generated certificates (e.g., 'prime256v1', 'secp384r1', '2048', '4096')."
}

variable "certificate_validity_days" {
  type        = number
  default     = 3650
  description = "Validity period for the device certificate in days."

  validation {
    condition     = var.certificate_validity_days > 0
    error_message = "Certificate validity must be greater than 0 days."
  }
}

# =================================================================================================
# Bridge settings
# =================================================================================================
variable "bridge_name" {
  type        = string
  default     = "bridge"
  description = "Name of the main bridge interface."
}

variable "bridge_comment" {
  type        = string
  default     = ""
  description = "Comment for the bridge interface."
}

variable "bridge_mtu" {
  type        = number
  default     = 1514
  description = "MTU for the bridge interface."

  validation {
    condition     = var.bridge_mtu >= 68 && var.bridge_mtu <= 65535
    error_message = "Bridge MTU must be between 68 and 65535."
  }
}

variable "bridge_vlan_filtering" {
  type        = bool
  default     = true
  description = "Whether to enable VLAN filtering on the bridge."
}

# =================================================================================================
# VLAN Configuration
# =================================================================================================
variable "vlans" {
  type = map(object({
    name    = string
    vlan_id = number
    mtu     = optional(number, 1500)
  }))
  default     = {}
  description = "Map of VLANs to configure. Each entry requires a human-readable name and a VLAN ID."

  validation {
    condition = alltrue([
      for k, v in var.vlans : v.vlan_id >= 1 && v.vlan_id <= 4094
    ])
    error_message = "VLAN IDs must be between 1 and 4094."
  }
}

# =================================================================================================
# Interface Configuration
# =================================================================================================
variable "ethernet_interfaces" {
  type = map(object({
    comment     = optional(string, "")
    bridge_port = optional(bool, true)
    l2mtu       = optional(number, 1514)
    mtu         = optional(number, 1500)
    tagged      = optional(list(string))
    untagged    = optional(string)
  }))
  default     = {}
  description = "Map of ethernet interfaces to configure. Keys are interface names (e.g., 'ether1'). Supports bridge membership and VLAN tagging."
}

variable "bond_interfaces" {
  type = map(object({
    comment              = optional(string, "")
    slaves               = list(string)
    mode                 = optional(string, "802.3ad")
    transmit_hash_policy = optional(string, "layer-2-and-3")
    mtu                  = optional(number, 1500)
    tagged               = optional(list(string))
    untagged             = optional(string)
  }))
  default     = {}
  description = "Map of bond interfaces to configure. Keys are bond names. Supports LACP (802.3ad), balance-rr, balance-xor, broadcast, active-backup, balance-tlb, and balance-alb modes."
}

# =================================================================================================
# User and Groups Configuration
# =================================================================================================
variable "groups" {
  type = map(object({
    policies = list(string)
    comment  = optional(string, "")
  }))
  default     = {}
  description = "Map of user groups to create. Keys are group names, values define policies and an optional comment."
}

variable "users" {
  type = map(object({
    group              = string
    password           = optional(string)
    comment            = optional(string, "")
    address            = optional(string, "")
    inactivity_policy  = optional(string)
    inactivity_timeout = optional(string)
  }))
  default     = {}
  description = "Map of users to create. Keys are usernames. If password is omitted, a random 16-character password is generated."
}
