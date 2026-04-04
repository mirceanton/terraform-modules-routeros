# -----------------------------------------------------------------------------
# CAPsMAN Settings
# -----------------------------------------------------------------------------
variable "country" {
  description = "Country name for WiFi regulatory compliance. Must match a value accepted by RouterOS (e.g. 'Romania', 'United States', 'Germany'). Set to null to leave unset."
  type        = string
  default     = null
}

variable "capsman_interfaces" {
  description = "List of interfaces where CAPsMAN will listen for CAP connections."
  type        = list(string)
  default     = ["all"]
}

variable "upgrade_policy" {
  description = "Firmware upgrade policy for managed CAP devices. Valid values: 'none', 'suggest-same-version', 'require-same-version'."
  type        = string
  default     = "none"

  validation {
    condition     = contains(["none", "suggest-same-version", "require-same-version"], var.upgrade_policy)
    error_message = "upgrade_policy must be one of: none, suggest-same-version, require-same-version."
  }
}

variable "require_peer_certificate" {
  description = "Whether to require CAP devices to present a valid certificate before being managed."
  type        = bool
  default     = false
}

# -----------------------------------------------------------------------------
# WiFi Security
# -----------------------------------------------------------------------------
variable "authentication_types" {
  description = "List of authentication types for WiFi security profiles. Common values: 'wpa2-psk', 'wpa3-psk'."
  type        = list(string)
  default     = ["wpa2-psk", "wpa3-psk"]
}

# -----------------------------------------------------------------------------
# WiFi Provisioning
# -----------------------------------------------------------------------------
variable "provisioning_action" {
  description = "Action to take when a CAP device matches a provisioning rule. Valid values: 'create-enabled', 'create-disabled', 'create-dynamic-enabled', 'none'."
  type        = string
  default     = "create-dynamic-enabled"

  validation {
    condition     = contains(["create-enabled", "create-disabled", "create-dynamic-enabled", "none"], var.provisioning_action)
    error_message = "provisioning_action must be one of: create-enabled, create-disabled, create-dynamic-enabled, none."
  }
}

# -----------------------------------------------------------------------------
# Channel Settings
# -----------------------------------------------------------------------------
variable "channel_settings" {
  description = <<-EOT
    Per-band channel configuration overrides for fine-tuning radio behavior.
    The map key must match one of the bands used in wifi_networks.

    Example:
    {
      "5ghz-ax" = {
        skip_dfs_channels = "all"
        width             = "80mhz"
      }
    }
  EOT
  type = map(object({
    frequency         = optional(list(string))
    skip_dfs_channels = optional(string)
    width             = optional(string)
    reselect_interval = optional(string)
    reselect_time     = optional(string)
  }))
  default = {}

  validation {
    condition = alltrue([
      for k, v in var.channel_settings :
      v.skip_dfs_channels == null || contains(["disabled", "10min-cac", "all"], v.skip_dfs_channels)
    ])
    error_message = "skip_dfs_channels must be one of: disabled, 10min-cac, all."
  }

  validation {
    condition = alltrue([
      for k, v in var.channel_settings :
      contains(["2ghz-ax", "5ghz-ax", "2ghz-n", "5ghz-n", "5ghz-ac"], k)
    ])
    error_message = "channel_settings keys must be valid band names: 2ghz-ax, 5ghz-ax, 2ghz-n, 5ghz-n, 5ghz-ac."
  }
}

# -----------------------------------------------------------------------------
# WiFi Networks
# -----------------------------------------------------------------------------
variable "wifi_networks" {
  description = <<-EOT
    Map of WiFi networks to configure. Each entry creates a security profile,
    datapath (for VLAN tagging), WiFi configuration, and provisioning rule.

    The map key is used as a unique identifier for the network resources.
    Networks sharing the same band are grouped into a single provisioning rule,
    with the first network (alphabetically by key) becoming the master configuration.

    If passphrase is omitted, a random one is generated automatically.

    Example:
    {
      guest = {
        ssid             = "MyGuest"
        band             = "2ghz-ax"
        vlan_id          = 50
        client_isolation = true
        passphrase       = "guest-password"
      }
      home_2ghz = {
        ssid    = "MyHome"
        band    = "2ghz-ax"
        vlan_id = 40
      }
      home_5ghz = {
        ssid    = "MyHome-5G"
        band    = "5ghz-ax"
        vlan_id = 40
      }
    }
  EOT
  type = map(object({
    ssid             = string
    band             = string
    vlan_id          = number
    client_isolation = optional(bool, false)
    passphrase       = optional(string)
  }))
  default = {}

  validation {
    condition = alltrue([
      for k, v in var.wifi_networks :
      contains(["2ghz-ax", "5ghz-ax", "2ghz-n", "5ghz-n", "5ghz-ac"], v.band)
    ])
    error_message = "Band must be one of: 2ghz-ax, 5ghz-ax, 2ghz-n, 5ghz-n, 5ghz-ac."
  }

  validation {
    condition = alltrue([
      for k, v in var.wifi_networks : v.vlan_id >= 1 && v.vlan_id <= 4094
    ])
    error_message = "vlan_id must be between 1 and 4094."
  }
}
