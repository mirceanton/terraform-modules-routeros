# --- Static Routes ------------------------------------------------------------

variable "static_routes" {
  description = <<-EOT
    Map of static routes to create. The key is a human-readable identifier
    included in the auto-generated comment if no explicit comment is provided.

    Example:
    {
      "default-via-isp" = {
        dst_address = "0.0.0.0/0"
        gateway     = "192.168.1.1"
        distance    = 1
      }
      "lan-via-vpn" = {
        dst_address = "10.0.0.0/8"
        gateway     = "wg0"
        comment     = "Route LAN traffic through WireGuard"
      }
      "blackhole-rfc1918" = {
        dst_address = "172.16.0.0/12"
        gateway     = ""
        blackhole   = true
      }
    }
  EOT
  type = map(object({
    gateway       = string
    dst_address   = optional(string)
    distance      = optional(number)
    comment       = optional(string)
    disabled      = optional(bool, false)
    blackhole     = optional(bool, false)
    check_gateway = optional(string)
    routing_table = optional(string)
    pref_src      = optional(string)
  }))
  default = {}

  validation {
    condition = alltrue([
      for k, v in var.static_routes :
      v.check_gateway == null || contains(["arp", "bfd", "bfd-mlag", "ping", "recurse"], v.check_gateway)
    ])
    error_message = "check_gateway must be one of: \"arp\", \"bfd\", \"bfd-mlag\", \"ping\", \"recurse\"."
  }

  validation {
    condition = alltrue([
      for k, v in var.static_routes :
      v.distance == null || (v.distance >= 1 && v.distance <= 255)
    ])
    error_message = "distance must be between 1 and 255."
  }
}
