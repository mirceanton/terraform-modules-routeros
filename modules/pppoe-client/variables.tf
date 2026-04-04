variable "interface" {
  description = "Physical interface to use for PPPoE connection (e.g., ether1)."
  type        = string

  validation {
    condition     = length(var.interface) > 0
    error_message = "The interface name must not be empty."
  }
}

variable "name" {
  description = "Name for the PPPoE client interface."
  type        = string

  validation {
    condition     = length(var.name) > 0
    error_message = "The PPPoE client interface name must not be empty."
  }
}

variable "comment" {
  description = "Optional comment or description for the PPPoE client interface."
  type        = string
  default     = ""
}

variable "disabled" {
  description = "Whether the PPPoE client interface is disabled."
  type        = bool
  default     = false
}

variable "username" {
  description = "PPPoE authentication username."
  type        = string
  sensitive   = true
}

variable "password" {
  description = "PPPoE authentication password."
  type        = string
  sensitive   = true
}

variable "add_default_route" {
  description = "Whether to add a default route when connected."
  type        = bool
  default     = true
}

variable "use_peer_dns" {
  description = "Whether to use DNS servers provided by the PPPoE server."
  type        = bool
  default     = false
}

variable "max_mtu" {
  description = "Maximum Transmission Unit size for the PPPoE client interface. Common values are 1480 or 1492."
  type        = number
  default     = null

  validation {
    condition     = var.max_mtu == null || (var.max_mtu >= 68 && var.max_mtu <= 65535)
    error_message = "max_mtu must be between 68 and 65535."
  }
}

variable "max_mru" {
  description = "Maximum Receive Unit size for the PPPoE client interface. Common values are 1480 or 1492."
  type        = number
  default     = null

  validation {
    condition     = var.max_mru == null || (var.max_mru >= 68 && var.max_mru <= 65535)
    error_message = "max_mru must be between 68 and 65535."
  }
}

variable "keepalive_timeout" {
  description = "PPP keepalive timeout in seconds. Defines how long to wait before considering the connection dead."
  type        = number
  default     = null

  validation {
    condition     = var.keepalive_timeout == null || var.keepalive_timeout >= 0
    error_message = "keepalive_timeout must be a non-negative number."
  }
}

variable "service_name" {
  description = "PPPoE service name. Used to connect to a specific service when multiple services are available."
  type        = string
  default     = null
}

variable "ac_name" {
  description = "PPPoE Access Concentrator name. Used to connect to a specific access concentrator."
  type        = string
  default     = null
}

variable "profile" {
  description = "PPP profile to use for the connection."
  type        = string
  default     = "default"
}
