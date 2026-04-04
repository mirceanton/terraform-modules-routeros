variable "interface" {
  description = "The name of the WireGuard interface to which the peers will be added."
  type        = string

  validation {
    condition     = length(var.interface) > 0
    error_message = "The interface name must not be empty."
  }
}

variable "peers" {
  description = <<-EOT
    A map of peer configurations keyed by peer name.

    Each peer object supports the following attributes:
      - allowed_address:      List of IP/CIDR ranges the peer is allowed to send traffic from.
      - comment:              An optional comment for the peer.
      - endpoint_address:     The remote endpoint hostname or IP address.
      - endpoint_port:        The remote endpoint port number.
      - persistent_keepalive: Interval (in seconds) for sending keepalive packets (e.g., "25").
      - preshared_key:        An optional pre-shared key for additional security.
      - is_responder:         Whether this peer acts only as a responder (does not initiate connections).
      - client_dns:           DNS server address to assign to the peer (used for client configuration).
      - client_endpoint:      The endpoint address the client should use to connect.
  EOT

  type = map(object({
    allowed_address      = list(string)
    comment              = optional(string, "")
    endpoint_address     = optional(string)
    endpoint_port        = optional(number)
    persistent_keepalive = optional(string)
    preshared_key        = optional(string)
    is_responder         = optional(bool)
    client_dns           = optional(string)
    client_endpoint      = optional(string)
  }))

  validation {
    condition     = length(var.peers) > 0
    error_message = "At least one peer must be defined."
  }

  validation {
    condition = alltrue([
      for name, peer in var.peers : length(peer.allowed_address) > 0
    ])
    error_message = "Each peer must have at least one entry in allowed_address."
  }

  validation {
    condition = alltrue([
      for name, peer in var.peers :
      peer.endpoint_port == null ? true : (peer.endpoint_port >= 1 && peer.endpoint_port <= 65535)
    ])
    error_message = "The endpoint_port for each peer must be between 1 and 65535."
  }
}
