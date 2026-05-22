# mikrotik-base

A Terraform module for configuring MikroTik (RouterOS) devices with a consistent baseline. Manages system identity, timezone, NTP, IPv6 settings, TLS certificates, IP services, bridge and VLAN configuration, bonding, user management, and MAC/bandwidth server settings.

## Usage

```hcl
module "mikrotik" {
  source = "./modules/mikrotik-base"

  hostname              = "my-router"
  certificate_common_name = "my-router.local"

  # Network interfaces
  ethernet_interfaces = {
    ether1 = { comment = "WAN", bridge_port = false }
    ether2 = { comment = "LAN", tagged = ["servers", "mgmt"] }
    ether3 = { comment = "IOT", untagged = "iot" }
  }

  # VLANs
  vlans = {
    servers = { name = "servers", vlan_id = 10 }
    mgmt    = { name = "mgmt",   vlan_id = 20 }
    iot     = { name = "iot",    vlan_id = 30, mtu = 1500 }
  }

  # Users
  groups = {
    operators = {
      policies = ["read", "write", "api", "winbox"]
    }
  }
  users = {
    admin = { group = "full" }
    ops   = { group = "operators" }
  }

  # IP services - override defaults as needed
  ip_services = {
    "api"     = { enabled = false, port = 8728 }
    "api-ssl" = { enabled = true,  port = 8729 }
    "ftp"     = { enabled = false, port = 21 }
    "ssh"     = { enabled = true,  port = 22 }
    "telnet"  = { enabled = false, port = 23 }
    "winbox"  = { enabled = true,  port = 8291 }
    "www"     = { enabled = false, port = 80 }
    "www-ssl" = { enabled = true,  port = 443 }
  }
}
```

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.0 |
| <a name="requirement_random"></a> [random](#requirement\_random) | >= 3.0 |
| <a name="requirement_routeros"></a> [routeros](#requirement\_routeros) | >= 1.99.1 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_random"></a> [random](#provider\_random) | >= 3.0 |
| <a name="provider_routeros"></a> [routeros](#provider\_routeros) | >= 1.99.1 |

## Resources

| Name | Type |
|------|------|
| [random_password.passwords](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/password) | resource |
| [routeros_interface_bonding.bonds](https://registry.terraform.io/providers/terraform-routeros/routeros/latest/docs/resources/interface_bonding) | resource |
| [routeros_interface_bridge.bridge](https://registry.terraform.io/providers/terraform-routeros/routeros/latest/docs/resources/interface_bridge) | resource |
| [routeros_interface_bridge_port.bond_ports](https://registry.terraform.io/providers/terraform-routeros/routeros/latest/docs/resources/interface_bridge_port) | resource |
| [routeros_interface_bridge_port.ethernet_ports](https://registry.terraform.io/providers/terraform-routeros/routeros/latest/docs/resources/interface_bridge_port) | resource |
| [routeros_interface_bridge_vlan.bridge_vlans](https://registry.terraform.io/providers/terraform-routeros/routeros/latest/docs/resources/interface_bridge_vlan) | resource |
| [routeros_interface_ethernet.ethernet](https://registry.terraform.io/providers/terraform-routeros/routeros/latest/docs/resources/interface_ethernet) | resource |
| [routeros_interface_vlan.vlans](https://registry.terraform.io/providers/terraform-routeros/routeros/latest/docs/resources/interface_vlan) | resource |
| [routeros_ip_service.services](https://registry.terraform.io/providers/terraform-routeros/routeros/latest/docs/resources/ip_service) | resource |
| [routeros_ip_service.tls_services](https://registry.terraform.io/providers/terraform-routeros/routeros/latest/docs/resources/ip_service) | resource |
| [routeros_ipv6_settings.disable](https://registry.terraform.io/providers/terraform-routeros/routeros/latest/docs/resources/ipv6_settings) | resource |
| [routeros_system_certificate.local-root-ca-cert](https://registry.terraform.io/providers/terraform-routeros/routeros/latest/docs/resources/system_certificate) | resource |
| [routeros_system_certificate.webfig](https://registry.terraform.io/providers/terraform-routeros/routeros/latest/docs/resources/system_certificate) | resource |
| [routeros_system_clock.timezone](https://registry.terraform.io/providers/terraform-routeros/routeros/latest/docs/resources/system_clock) | resource |
| [routeros_system_identity.identity](https://registry.terraform.io/providers/terraform-routeros/routeros/latest/docs/resources/system_identity) | resource |
| [routeros_system_ntp_client.client](https://registry.terraform.io/providers/terraform-routeros/routeros/latest/docs/resources/system_ntp_client) | resource |
| [routeros_system_ntp_server.server](https://registry.terraform.io/providers/terraform-routeros/routeros/latest/docs/resources/system_ntp_server) | resource |
| [routeros_system_user.users](https://registry.terraform.io/providers/terraform-routeros/routeros/latest/docs/resources/system_user) | resource |
| [routeros_system_user_group.groups](https://registry.terraform.io/providers/terraform-routeros/routeros/latest/docs/resources/system_user_group) | resource |
| [routeros_tool_bandwidth_server.bandwidth_server](https://registry.terraform.io/providers/terraform-routeros/routeros/latest/docs/resources/tool_bandwidth_server) | resource |
| [routeros_tool_mac_server.mac_server](https://registry.terraform.io/providers/terraform-routeros/routeros/latest/docs/resources/tool_mac_server) | resource |
| [routeros_tool_mac_server_winbox.mac_server_winbox](https://registry.terraform.io/providers/terraform-routeros/routeros/latest/docs/resources/tool_mac_server_winbox) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_bandwidth_server_enabled"></a> [bandwidth\_server\_enabled](#input\_bandwidth\_server\_enabled) | Whether to enable the bandwidth test server. | `bool` | `false` | no |
| <a name="input_bond_interfaces"></a> [bond\_interfaces](#input\_bond\_interfaces) | Map of bond interfaces to configure. Keys are bond names. Supports LACP (802.3ad), balance-rr, balance-xor, broadcast, active-backup, balance-tlb, and balance-alb modes. | <pre>map(object({<br/>    comment              = optional(string, "")<br/>    slaves               = list(string)<br/>    mode                 = optional(string, "802.3ad")<br/>    transmit_hash_policy = optional(string, "layer-2-and-3")<br/>    mtu                  = optional(number, 1500)<br/>    tagged               = optional(list(string))<br/>    untagged             = optional(string)<br/>  }))</pre> | `{}` | no |
| <a name="input_bridge_comment"></a> [bridge\_comment](#input\_bridge\_comment) | Comment for the bridge interface. | `string` | `""` | no |
| <a name="input_bridge_mtu"></a> [bridge\_mtu](#input\_bridge\_mtu) | MTU for the bridge interface. | `number` | `1514` | no |
| <a name="input_bridge_name"></a> [bridge\_name](#input\_bridge\_name) | Name of the main bridge interface. | `string` | `"bridge"` | no |
| <a name="input_bridge_vlan_filtering"></a> [bridge\_vlan\_filtering](#input\_bridge\_vlan\_filtering) | Whether to enable VLAN filtering on the bridge. | `bool` | `true` | no |
| <a name="input_certificate_common_name"></a> [certificate\_common\_name](#input\_certificate\_common\_name) | Common Name (CN) for the device TLS certificate. | `string` | n/a | yes |
| <a name="input_certificate_country"></a> [certificate\_country](#input\_certificate\_country) | Country code (C) for the device certificate (e.g., 'US', 'DE'). | `string` | `""` | no |
| <a name="input_certificate_key_type"></a> [certificate\_key\_type](#input\_certificate\_key\_type) | Key type/size for generated certificates (e.g., 'prime256v1', 'secp384r1', '2048', '4096'). | `string` | `"prime256v1"` | no |
| <a name="input_certificate_locality"></a> [certificate\_locality](#input\_certificate\_locality) | Locality (L) for the device certificate (e.g., 'San Francisco'). | `string` | `""` | no |
| <a name="input_certificate_organization"></a> [certificate\_organization](#input\_certificate\_organization) | Organization (O) for the device certificate. | `string` | `""` | no |
| <a name="input_certificate_unit"></a> [certificate\_unit](#input\_certificate\_unit) | Organizational Unit (OU) for the device certificate. | `string` | `""` | no |
| <a name="input_certificate_validity_days"></a> [certificate\_validity\_days](#input\_certificate\_validity\_days) | Validity period for the device certificate in days. | `number` | `3650` | no |
| <a name="input_disable_ipv6"></a> [disable\_ipv6](#input\_disable\_ipv6) | Whether to disable IPv6 on the device. | `bool` | `false` | no |
| <a name="input_ethernet_interfaces"></a> [ethernet\_interfaces](#input\_ethernet\_interfaces) | Map of ethernet interfaces to configure. Keys are interface names (e.g., 'ether1'). Supports bridge membership and VLAN tagging. | <pre>map(object({<br/>    comment     = optional(string, "")<br/>    bridge_port = optional(bool, true)<br/>    l2mtu       = optional(number, 1514)<br/>    mtu         = optional(number, 1500)<br/>    tagged      = optional(list(string))<br/>    untagged    = optional(string)<br/>  }))</pre> | `{}` | no |
| <a name="input_groups"></a> [groups](#input\_groups) | Map of user groups to create. Keys are group names, values define policies and an optional comment. | <pre>map(object({<br/>    policies = list(string)<br/>    comment  = optional(string, "")<br/>  }))</pre> | `{}` | no |
| <a name="input_hostname"></a> [hostname](#input\_hostname) | The hostname (system identity) to assign to this MikroTik device. | `string` | n/a | yes |
| <a name="input_ip_services"></a> [ip\_services](#input\_ip\_services) | Map of IP services to configure. Each service has an 'enabled' flag and a 'port' number. TLS services (api-ssl, www-ssl) automatically use the device certificate. | <pre>map(object({<br/>    enabled = bool<br/>    port    = number<br/>  }))</pre> | <pre>{<br/>  "api": {<br/>    "enabled": false,<br/>    "port": 8728<br/>  },<br/>  "api-ssl": {<br/>    "enabled": true,<br/>    "port": 8729<br/>  },<br/>  "ftp": {<br/>    "enabled": false,<br/>    "port": 21<br/>  },<br/>  "ssh": {<br/>    "enabled": false,<br/>    "port": 22<br/>  },<br/>  "telnet": {<br/>    "enabled": false,<br/>    "port": 23<br/>  },<br/>  "winbox": {<br/>    "enabled": true,<br/>    "port": 8291<br/>  },<br/>  "www": {<br/>    "enabled": false,<br/>    "port": 80<br/>  },<br/>  "www-ssl": {<br/>    "enabled": true,<br/>    "port": 443<br/>  }<br/>}</pre> | no |
| <a name="input_mac_server_interfaces"></a> [mac\_server\_interfaces](#input\_mac\_server\_interfaces) | Interface list to allow MAC server access on (e.g., 'all', 'none', or a specific interface list name). | `string` | `"all"` | no |
| <a name="input_ntp_mode"></a> [ntp\_mode](#input\_ntp\_mode) | NTP client mode. Valid values: unicast, broadcast, multicast, manycast. | `string` | `"unicast"` | no |
| <a name="input_ntp_servers"></a> [ntp\_servers](#input\_ntp\_servers) | List of NTP server addresses for time synchronization. | `list(string)` | <pre>[<br/>  "time.cloudflare.com"<br/>]</pre> | no |
| <a name="input_timezone"></a> [timezone](#input\_timezone) | The timezone to set on the device (e.g., 'UTC', 'America/New\_York', 'Europe/London'). | `string` | `"UTC"` | no |
| <a name="input_tls_version"></a> [tls\_version](#input\_tls\_version) | TLS version to use for SSL-enabled IP services (api-ssl, www-ssl). | `string` | `"only-1.2"` | no |
| <a name="input_users"></a> [users](#input\_users) | Map of users to create. Keys are usernames. If password is omitted, a random 16-character password is generated. | <pre>map(object({<br/>    group              = string<br/>    password           = optional(string)<br/>    comment            = optional(string, "")<br/>    address            = optional(string, "")<br/>    inactivity_policy  = optional(string)<br/>    inactivity_timeout = optional(string)<br/>  }))</pre> | `{}` | no |
| <a name="input_vlans"></a> [vlans](#input\_vlans) | Map of VLANs to configure. Each entry requires a human-readable name and a VLAN ID. | <pre>map(object({<br/>    name    = string<br/>    vlan_id = number<br/>    mtu     = optional(number, 1500)<br/>  }))</pre> | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_bridge_id"></a> [bridge\_id](#output\_bridge\_id) | The resource ID of the bridge interface. |
| <a name="output_bridge_name"></a> [bridge\_name](#output\_bridge\_name) | The name of the bridge interface. |
| <a name="output_ca_certificate_name"></a> [ca\_certificate\_name](#output\_ca\_certificate\_name) | The name of the root CA certificate. |
| <a name="output_certificate_common_name"></a> [certificate\_common\_name](#output\_certificate\_common\_name) | The Common Name (CN) of the device TLS certificate. |
| <a name="output_certificate_fingerprint"></a> [certificate\_fingerprint](#output\_certificate\_fingerprint) | The fingerprint of the device TLS certificate. |
| <a name="output_certificate_name"></a> [certificate\_name](#output\_certificate\_name) | The name of the device TLS certificate. |
| <a name="output_hostname"></a> [hostname](#output\_hostname) | The configured hostname (system identity) of the device. |
| <a name="output_user_passwords"></a> [user\_passwords](#output\_user\_passwords) | Map of usernames to their passwords (generated or provided). |
| <a name="output_vlan_ids"></a> [vlan\_ids](#output\_vlan\_ids) | Map of VLAN names to their VLAN IDs. |
| <a name="output_vlan_interfaces"></a> [vlan\_interfaces](#output\_vlan\_interfaces) | Map of VLAN names to their interface details (name, VLAN ID, MTU). |
<!-- END_TF_DOCS -->
