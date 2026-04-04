# MikroTik CAPsMAN WiFi Module

Terraform module for managing **MikroTik CAPsMAN** (Controlled Access Point system Manager) WiFi configurations using the [routeros](https://registry.terraform.io/providers/terraform-routeros/routeros/latest) provider.

CAPsMAN is MikroTik's centralized wireless management system. It allows a single router to control the WiFi configuration of multiple access points (CAPs) in the network. This module automates the creation of WiFi channels, security profiles, datapaths (VLAN tagging), configurations, and provisioning rules.

## Features

- Automatic channel resource creation per unique radio band
- Per-network security profiles with WPA2/WPA3 support
- VLAN-based datapaths with optional client isolation
- Automatic passphrase generation when not explicitly provided
- Deterministic master/slave provisioning for multi-SSID setups
- Full parameterization with sensible defaults

## Usage

```hcl
module "capsman" {
  source = "./modules/mikrotik-capsman"

  country        = "United States"
  upgrade_policy = "suggest-same-version"

  channel_settings = {
    "5ghz-ax" = {
      skip_dfs_channels = "all"
      width             = "80mhz"
    }
    "2ghz-ax" = {
      width = "20mhz"
    }
  }

  wifi_networks = {
    home_5ghz = {
      ssid    = "MyHome-5G"
      band    = "5ghz-ax"
      vlan_id = 40
    }
    home_2ghz = {
      ssid    = "MyHome"
      band    = "2ghz-ax"
      vlan_id = 40
    }
    guest = {
      ssid             = "MyHome-Guest"
      band             = "2ghz-ax"
      vlan_id          = 50
      client_isolation = true
      passphrase       = "welcome-guest"
    }
  }
}

# Retrieve generated passphrases
output "wifi_passphrases" {
  value     = module.capsman.wifi_passphrases
  sensitive = true
}
```

## How Provisioning Works

CAPsMAN provisioning rules automatically configure CAP radios based on their supported band. This module creates one provisioning rule per band:

- **Master configuration**: The primary SSID for that radio. Chosen deterministically as the first network key alphabetically within each band.
- **Slave configurations**: All other SSIDs on the same band become virtual APs (slave configurations).

For example, if you define `guest` and `home_2ghz` on the `2ghz-ax` band, `guest` becomes the master (alphabetically first) and `home_2ghz` becomes a slave.

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.0 |
| <a name="requirement_random"></a> [random](#requirement\_random) | >= 3.0 |
| <a name="requirement_routeros"></a> [routeros](#requirement\_routeros) | >= 1.99.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_random"></a> [random](#provider\_random) | >= 3.0 |
| <a name="provider_routeros"></a> [routeros](#provider\_routeros) | >= 1.99.0 |

## Resources

| Name | Type |
|------|------|
| [random_pet.wifi_passphrase](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/pet) | resource |
| [routeros_wifi_capsman.settings](https://registry.terraform.io/providers/terraform-routeros/routeros/latest/docs/resources/wifi_capsman) | resource |
| [routeros_wifi_channel.this](https://registry.terraform.io/providers/terraform-routeros/routeros/latest/docs/resources/wifi_channel) | resource |
| [routeros_wifi_configuration.this](https://registry.terraform.io/providers/terraform-routeros/routeros/latest/docs/resources/wifi_configuration) | resource |
| [routeros_wifi_datapath.this](https://registry.terraform.io/providers/terraform-routeros/routeros/latest/docs/resources/wifi_datapath) | resource |
| [routeros_wifi_provisioning.this](https://registry.terraform.io/providers/terraform-routeros/routeros/latest/docs/resources/wifi_provisioning) | resource |
| [routeros_wifi_security.this](https://registry.terraform.io/providers/terraform-routeros/routeros/latest/docs/resources/wifi_security) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_authentication_types"></a> [authentication\_types](#input\_authentication\_types) | List of authentication types for WiFi security profiles. Common values: 'wpa2-psk', 'wpa3-psk'. | `list(string)` | <pre>[<br/>  "wpa2-psk",<br/>  "wpa3-psk"<br/>]</pre> | no |
| <a name="input_capsman_interfaces"></a> [capsman\_interfaces](#input\_capsman\_interfaces) | List of interfaces where CAPsMAN will listen for CAP connections. | `list(string)` | <pre>[<br/>  "all"<br/>]</pre> | no |
| <a name="input_channel_settings"></a> [channel\_settings](#input\_channel\_settings) | Per-band channel configuration overrides for fine-tuning radio behavior.<br/>The map key must match one of the bands used in wifi\_networks.<br/><br/>Example:<br/>{<br/>  "5ghz-ax" = {<br/>    skip\_dfs\_channels = "all"<br/>    width             = "80mhz"<br/>  }<br/>} | <pre>map(object({<br/>    frequency         = optional(list(string))<br/>    skip_dfs_channels = optional(string)<br/>    width             = optional(string)<br/>    reselect_interval = optional(string)<br/>    reselect_time     = optional(string)<br/>  }))</pre> | `{}` | no |
| <a name="input_country"></a> [country](#input\_country) | Country name for WiFi regulatory compliance. Must match a value accepted by RouterOS (e.g. 'Romania', 'United States', 'Germany'). Set to null to leave unset. | `string` | `null` | no |
| <a name="input_provisioning_action"></a> [provisioning\_action](#input\_provisioning\_action) | Action to take when a CAP device matches a provisioning rule. Valid values: 'create-enabled', 'create-disabled', 'create-dynamic-enabled', 'none'. | `string` | `"create-dynamic-enabled"` | no |
| <a name="input_require_peer_certificate"></a> [require\_peer\_certificate](#input\_require\_peer\_certificate) | Whether to require CAP devices to present a valid certificate before being managed. | `bool` | `false` | no |
| <a name="input_upgrade_policy"></a> [upgrade\_policy](#input\_upgrade\_policy) | Firmware upgrade policy for managed CAP devices. Valid values: 'none', 'suggest-same-version', 'require-same-version'. | `string` | `"none"` | no |
| <a name="input_wifi_networks"></a> [wifi\_networks](#input\_wifi\_networks) | Map of WiFi networks to configure. Each entry creates a security profile,<br/>datapath (for VLAN tagging), WiFi configuration, and provisioning rule.<br/><br/>The map key is used as a unique identifier for the network resources.<br/>Networks sharing the same band are grouped into a single provisioning rule,<br/>with the first network (alphabetically by key) becoming the master configuration.<br/><br/>If passphrase is omitted, a random one is generated automatically.<br/><br/>Example:<br/>{<br/>  guest = {<br/>    ssid             = "MyGuest"<br/>    band             = "2ghz-ax"<br/>    vlan\_id          = 50<br/>    client\_isolation = true<br/>    passphrase       = "guest-password"<br/>  }<br/>  home\_2ghz = {<br/>    ssid    = "MyHome"<br/>    band    = "2ghz-ax"<br/>    vlan\_id = 40<br/>  }<br/>  home\_5ghz = {<br/>    ssid    = "MyHome-5G"<br/>    band    = "5ghz-ax"<br/>    vlan\_id = 40<br/>  }<br/>} | <pre>map(object({<br/>    ssid             = string<br/>    band             = string<br/>    vlan_id          = number<br/>    client_isolation = optional(bool, false)<br/>    passphrase       = optional(string)<br/>  }))</pre> | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_bands_in_use"></a> [bands\_in\_use](#output\_bands\_in\_use) | List of unique radio bands configured across all WiFi networks. |
| <a name="output_configured_ssids"></a> [configured\_ssids](#output\_configured\_ssids) | List of all configured WiFi SSIDs. |
| <a name="output_provisioning_rule_count"></a> [provisioning\_rule\_count](#output\_provisioning\_rule\_count) | Number of CAPsMAN provisioning rules created (one per band). |
| <a name="output_wifi_passphrases"></a> [wifi\_passphrases](#output\_wifi\_passphrases) | Map of WiFi network keys to their passphrases (provided or auto-generated). |
<!-- END_TF_DOCS -->
