variable "upstream_dns" {
  type        = list(string)
  description = "List of upstream DNS server addresses to forward queries to (e.g., [\"1.1.1.1\", \"8.8.8.8\"])."

  validation {
    condition     = length(var.upstream_dns) > 0
    error_message = "At least one upstream DNS server must be specified."
  }
}

variable "allow_remote_requests" {
  type        = bool
  default     = true
  description = "Whether to allow DNS requests from remote hosts (clients on the network). Set to false to restrict DNS to the router itself."
}

variable "cache_size" {
  type        = number
  default     = 8192
  description = "Size of the DNS cache in KiB. Higher values use more memory but can improve performance."

  validation {
    condition     = var.cache_size > 0
    error_message = "Cache size must be a positive number."
  }
}

variable "cache_max_ttl" {
  type        = string
  default     = "1d"
  description = "Maximum time-to-live for cached DNS entries. Accepts RouterOS duration format (e.g., '1d', '12h', '30m', '3600')."

  validation {
    condition     = can(regex("^[0-9]+(d|h|m|s)?$", var.cache_max_ttl))
    error_message = "Cache max TTL must be a valid RouterOS duration (e.g., '1d', '12h', '30m', '3600')."
  }
}

variable "adlist_url" {
  type        = string
  default     = null
  description = "URL to an adblock list for DNS-based ad blocking. Set to null to disable ad blocking."
}

variable "adlist_ssl_verify" {
  type        = bool
  default     = false
  description = "Whether to verify SSL certificates when fetching the adblock list. Only relevant when adlist_url is set."
}

variable "static_dns" {
  type = map(object({
    type            = string
    address         = optional(string)
    cname           = optional(string)
    mx_exchange     = optional(string)
    mx_preference   = optional(number)
    srv_port        = optional(number)
    srv_target      = optional(string)
    srv_priority    = optional(number)
    srv_weight      = optional(number)
    text            = optional(string)
    ttl             = optional(string)
    match_subdomain = optional(bool, false)
    disabled        = optional(bool, false)
    comment         = optional(string, "")
  }))
  default     = {}
  description = <<-EOT
    Map of static DNS records. The map key is used as the record name (FQDN).

    Supported record types and their required fields:
    - A/AAAA:  set 'address' to the target IP
    - CNAME:   set 'cname' to the canonical name
    - MX:      set 'mx_exchange' and optionally 'mx_preference'
    - SRV:     set 'srv_target', 'srv_port', and optionally 'srv_priority' / 'srv_weight'
    - TXT:     set 'text' to the TXT record content
    - FWD:     set 'address' to the forwarding server address
    - NXDOMAIN: no additional fields required (sinkhole record)
  EOT

  validation {
    condition = alltrue([
      for name, record in var.static_dns :
      contains(["A", "AAAA", "CNAME", "FWD", "MX", "NS", "NXDOMAIN", "SRV", "TXT"], record.type)
    ])
    error_message = "Record type must be one of: A, AAAA, CNAME, FWD, MX, NS, NXDOMAIN, SRV, TXT."
  }
}
