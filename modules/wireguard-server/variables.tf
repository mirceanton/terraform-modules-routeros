variable "name" {
  description = "The name of the WireGuard interface to create (e.g. \"wg0\")."
  type        = string
}

variable "comment" {
  description = "An optional comment or description for the WireGuard interface and its IP address."
  type        = string
  default     = ""
}

variable "listen_port" {
  description = "The UDP port on which the WireGuard interface will listen for incoming connections."
  type        = number
  default     = 51820

  validation {
    condition     = var.listen_port >= 1 && var.listen_port <= 65535
    error_message = "listen_port must be between 1 and 65535."
  }
}

variable "mtu" {
  description = "The Maximum Transmission Unit (MTU) size for the WireGuard interface. The default of 1420 accounts for WireGuard overhead on standard 1500-byte links."
  type        = number
  default     = 1420

  validation {
    condition     = var.mtu >= 68 && var.mtu <= 9000
    error_message = "mtu must be between 68 and 9000."
  }
}

variable "address" {
  description = "The IP address in CIDR notation to assign to the WireGuard interface (e.g. \"10.0.0.1/24\")."
  type        = string

  validation {
    condition     = can(cidrhost(var.address, 0))
    error_message = "address must be a valid CIDR notation (e.g. \"10.0.0.1/24\")."
  }
}

variable "private_key" {
  description = "An optional WireGuard private key. If omitted, RouterOS will auto-generate a key pair."
  type        = string
  sensitive   = true
  default     = null
}

variable "disabled" {
  description = "Whether the WireGuard interface should be disabled."
  type        = bool
  default     = false
}
