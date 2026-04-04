# =============================================================================
# CAPsMAN Settings
# https://registry.terraform.io/providers/terraform-routeros/routeros/latest/docs/resources/wifi_capsman
# =============================================================================
resource "routeros_wifi_capsman" "settings" {
  enabled                  = true
  interfaces               = var.capsman_interfaces
  upgrade_policy           = var.upgrade_policy
  require_peer_certificate = var.require_peer_certificate
}

# =============================================================================
# Locals
# =============================================================================
locals {
  # Extract unique bands from wifi_networks
  unique_bands = toset([for k, v in var.wifi_networks : v.band])

  # Map band identifiers to human-friendly channel names used in RouterOS
  band_to_channel_name = {
    "2ghz-ax" = "2.4ghz"
    "5ghz-ax" = "5ghz"
    "2ghz-n"  = "2.4ghz-n"
    "5ghz-n"  = "5ghz-n"
    "5ghz-ac" = "5ghz-ac"
  }

  # Create unique datapaths based on vlan_id + client_isolation combination.
  # Multiple networks sharing the same VLAN and isolation setting reuse
  # a single datapath resource.
  unique_datapaths = {
    for k, v in var.wifi_networks : "${v.vlan_id}-${v.client_isolation}" => {
      vlan_id          = v.vlan_id
      client_isolation = v.client_isolation
    }...
  }

  # Flatten to get one entry per unique combination
  datapath_configs = {
    for key, configs in local.unique_datapaths : key => configs[0]
  }

  # Group networks by band for provisioning rules
  networks_by_band = {
    for band in local.unique_bands : band => {
      for k, v in var.wifi_networks : k => v if v.band == band
    }
  }

  # Provisioning master/slave pattern:
  #
  # CAPsMAN provisioning rules require exactly one "master" configuration per
  # radio band. All other configurations for the same band are added as "slave"
  # configurations. The master is the primary SSID that the radio broadcasts,
  # while slaves are additional SSIDs (virtual APs) on the same radio.
  #
  # The master is chosen deterministically by sorting network keys alphabetically
  # and picking the first one. This ensures stable plans across applies.
  provisioning_master = {
    for band, networks in local.networks_by_band : band => sort(keys(networks))[0]
  }

  # Networks that need a generated passphrase (none provided by the caller)
  networks_needing_passphrase = {
    for k, v in var.wifi_networks : k => v if v.passphrase == null
  }

  # Resolve final passphrase for each network: use the provided value or
  # fall back to the randomly generated one.
  wifi_passphrases = {
    for k, v in var.wifi_networks : k => (
      v.passphrase != null ? v.passphrase : random_pet.wifi_passphrase[k].id
    )
  }
}

# =============================================================================
# WiFi Channels
# https://registry.terraform.io/providers/terraform-routeros/routeros/latest/docs/resources/wifi_channel
#
# Creates one channel resource per unique band used across all wifi_networks.
# =============================================================================
resource "routeros_wifi_channel" "this" {
  for_each = local.unique_bands

  name              = local.band_to_channel_name[each.value]
  band              = each.value
  frequency         = try(var.channel_settings[each.value].frequency, null)
  skip_dfs_channels = try(var.channel_settings[each.value].skip_dfs_channels, null)
  width             = try(var.channel_settings[each.value].width, null)
  reselect_interval = try(var.channel_settings[each.value].reselect_interval, null)
  reselect_time     = try(var.channel_settings[each.value].reselect_time, null)
}

# =============================================================================
# WiFi Security
# https://registry.terraform.io/providers/terraform-routeros/routeros/latest/docs/resources/wifi_security
#
# Creates a security profile for each WiFi network.
# =============================================================================
resource "random_pet" "wifi_passphrase" {
  for_each = local.networks_needing_passphrase

  length    = 4
  separator = "-"
}

resource "routeros_wifi_security" "this" {
  for_each = var.wifi_networks

  name                 = "${each.key}-wifi-security"
  authentication_types = var.authentication_types
  passphrase           = local.wifi_passphrases[each.key]
}

# =============================================================================
# WiFi Datapath
# https://registry.terraform.io/providers/terraform-routeros/routeros/latest/docs/resources/wifi_datapath
#
# Creates a datapath for each unique VLAN + client_isolation combination.
# Networks that share the same VLAN and isolation setting reuse one datapath.
# =============================================================================
resource "routeros_wifi_datapath" "this" {
  for_each = local.datapath_configs

  name             = "vlan-${each.value.vlan_id}-tagging"
  comment          = "WiFi -> VLAN ${each.value.vlan_id}"
  vlan_id          = each.value.vlan_id
  client_isolation = each.value.client_isolation
}

# =============================================================================
# WiFi Configurations
# https://registry.terraform.io/providers/terraform-routeros/routeros/latest/docs/resources/wifi_configuration
#
# Creates a WiFi configuration for each network, linking its channel,
# datapath, and security profile together.
# =============================================================================
resource "routeros_wifi_configuration" "this" {
  for_each = var.wifi_networks

  name    = each.value.ssid
  ssid    = each.value.ssid
  country = var.country

  channel = {
    config = routeros_wifi_channel.this[each.value.band].name
  }
  datapath = {
    config = routeros_wifi_datapath.this["${each.value.vlan_id}-${each.value.client_isolation}"].name
  }
  security = {
    config = routeros_wifi_security.this[each.key].name
  }
}

# =============================================================================
# WiFi Provisioning
# https://registry.terraform.io/providers/terraform-routeros/routeros/latest/docs/resources/wifi_provisioning
#
# Creates one provisioning rule per band. CAPsMAN uses these rules to
# automatically configure CAP radios that match the supported band.
#
# Master/slave pattern:
#   - Each band has exactly one master configuration (the primary SSID).
#   - All other SSIDs on the same band are slave configurations (virtual APs).
#   - The master is chosen alphabetically by network key for determinism.
# =============================================================================
resource "routeros_wifi_provisioning" "this" {
  for_each = local.networks_by_band

  action          = var.provisioning_action
  comment         = routeros_wifi_configuration.this[local.provisioning_master[each.key]].name
  supported_bands = [each.key]

  master_configuration = routeros_wifi_configuration.this[local.provisioning_master[each.key]].name

  slave_configurations = [
    for k in sort(keys(each.value)) :
    routeros_wifi_configuration.this[k].name
    if k != local.provisioning_master[each.key]
  ]
}
