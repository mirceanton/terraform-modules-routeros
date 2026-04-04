# --- Interface & Naming ---

variable "interface" {
  description = "Name of the RouterOS interface the DHCP server is bound to."
  type        = string

  validation {
    condition     = length(var.interface) > 0
    error_message = "The interface name must not be empty."
  }
}

variable "server_name" {
  description = "Name for the DHCP server resource. Defaults to the interface name if not specified."
  type        = string
  default     = null
}

variable "pool_name" {
  description = "Name for the DHCP IP pool. Defaults to '{interface}-dhcp-pool' if not specified."
  type        = string
  default     = null
}

variable "comment" {
  description = "Comment prefix used for all created resources. Defaults to the interface name."
  type        = string
  default     = null
}

# --- Network Configuration ---

variable "address" {
  description = "IP address in CIDR notation to assign to the interface (e.g., '192.168.1.1/24')."
  type        = string

  validation {
    condition     = can(cidrhost(var.address, 0))
    error_message = "The address must be in valid CIDR notation (e.g., '192.168.1.1/24')."
  }
}

variable "network" {
  description = "Network address in CIDR notation (e.g., '192.168.1.0/24')."
  type        = string

  validation {
    condition     = can(cidrhost(var.network, 0))
    error_message = "The network must be in valid CIDR notation (e.g., '192.168.1.0/24')."
  }
}

variable "gateway" {
  description = "Gateway IP address for the network. If not specified, defaults to the first usable IP in the network (the network address + 1)."
  type        = string
  default     = null

  validation {
    condition     = var.gateway == null || can(regex("^\\d{1,3}\\.\\d{1,3}\\.\\d{1,3}\\.\\d{1,3}$", var.gateway))
    error_message = "The gateway must be a valid IPv4 address (e.g., '192.168.1.1')."
  }
}

variable "dhcp_pool" {
  description = "List of IP ranges for the DHCP pool (e.g., ['192.168.1.100-192.168.1.200'])."
  type        = list(string)

  validation {
    condition     = length(var.dhcp_pool) > 0
    error_message = "At least one DHCP pool range must be specified."
  }

  validation {
    condition     = alltrue([for r in var.dhcp_pool : can(regex("^\\d{1,3}\\.\\d{1,3}\\.\\d{1,3}\\.\\d{1,3}-\\d{1,3}\\.\\d{1,3}\\.\\d{1,3}\\.\\d{1,3}$", r))])
    error_message = "Each pool range must be in the format 'START_IP-END_IP' (e.g., '192.168.1.100-192.168.1.200')."
  }
}

# --- DHCP Options ---

variable "dns_servers" {
  description = "List of DNS server IP addresses to provide to DHCP clients."
  type        = list(string)
  default     = []
}

variable "domain" {
  description = "Domain name to provide to DHCP clients."
  type        = string
  default     = ""
}

variable "lease_time" {
  description = "Default DHCP lease time (e.g., '00:10:00' for 10 minutes, '1d 00:00:00' for 1 day). If not set, RouterOS default is used."
  type        = string
  default     = null
}

variable "authoritative" {
  description = "Whether the DHCP server is authoritative. When set to 'yes', the server will send a NAK to clients requesting an address that is not in the pool."
  type        = string
  default     = "yes"

  validation {
    condition     = contains(["yes", "no", "after-2sec-delay", "after-10sec-delay"], var.authoritative)
    error_message = "The authoritative value must be one of: 'yes', 'no', 'after-2sec-delay', 'after-10sec-delay'."
  }
}

# --- Server Behavior ---

variable "client_mac_limit" {
  description = "Maximum number of MAC addresses allowed per client."
  type        = number
  default     = 1

  validation {
    condition     = var.client_mac_limit >= 0
    error_message = "The client MAC limit must be a non-negative number."
  }
}

variable "conflict_detection" {
  description = "Whether to enable conflict detection for DHCP leases."
  type        = bool
  default     = false
}

variable "dynamic_lease_identifiers" {
  description = "Specifies which fields are used to identify dynamic DHCP leases."
  type        = string
  default     = "client-mac,client-id"
}

# --- Static Leases & DNS ---

variable "static_leases" {
  description = "Map of static DHCP leases keyed by IP address. Each entry requires 'mac' and 'name'. Optionally set 'create_dns_record' to override the global DNS record creation flag, and 'match_subdomain' to enable wildcard DNS matching."
  type = map(object({
    mac               = string
    name              = string
    create_dns_record = optional(bool)
    match_subdomain   = optional(bool)
  }))
  default = {}
}

variable "create_dns_records" {
  description = "Whether to create static DNS A records for each static lease. Can be overridden per-lease via the 'create_dns_record' attribute."
  type        = bool
  default     = true
}
