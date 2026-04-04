# mikrotik-dhcp-server

Terraform module for configuring a DHCP server on a MikroTik RouterOS device.

This module creates a complete DHCP server setup including the interface IP address, IP pool, DHCP network, DHCP server, static leases, and optional DNS records for static leases. It is designed for per-VLAN or per-interface DHCP deployments.

## Usage

```hcl
module "dhcp_trusted" {
  source = "./modules/mikrotik-dhcp-server"

  interface = "vlan-trusted"
  address   = "192.168.10.1/24"
  network   = "192.168.10.0/24"
  dhcp_pool = ["192.168.10.100-192.168.10.200"]

  dns_servers = ["1.1.1.1", "8.8.8.8"]
  domain      = "home.example.com"
  lease_time  = "1d 00:00:00"

  static_leases = {
    "192.168.10.10" = {
      mac  = "AA:BB:CC:DD:EE:01"
      name = "nas"
    }
    "192.168.10.11" = {
      mac               = "AA:BB:CC:DD:EE:02"
      name              = "printer"
      create_dns_record = false
    }
    "192.168.10.12" = {
      mac             = "AA:BB:CC:DD:EE:03"
      name            = "homeassistant"
      match_subdomain = true
    }
  }
}
```

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.0 |
| <a name="requirement_routeros"></a> [routeros](#requirement\_routeros) | >= 1.80.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_routeros"></a> [routeros](#provider\_routeros) | >= 1.80.0 |

## Resources

| Name | Type |
|------|------|
| [routeros_ip_address.this](https://registry.terraform.io/providers/terraform-routeros/routeros/latest/docs/resources/ip_address) | resource |
| [routeros_ip_dhcp_server.this](https://registry.terraform.io/providers/terraform-routeros/routeros/latest/docs/resources/ip_dhcp_server) | resource |
| [routeros_ip_dhcp_server_lease.this](https://registry.terraform.io/providers/terraform-routeros/routeros/latest/docs/resources/ip_dhcp_server_lease) | resource |
| [routeros_ip_dhcp_server_network.this](https://registry.terraform.io/providers/terraform-routeros/routeros/latest/docs/resources/ip_dhcp_server_network) | resource |
| [routeros_ip_dns_record.this](https://registry.terraform.io/providers/terraform-routeros/routeros/latest/docs/resources/ip_dns_record) | resource |
| [routeros_ip_pool.this](https://registry.terraform.io/providers/terraform-routeros/routeros/latest/docs/resources/ip_pool) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_address"></a> [address](#input\_address) | IP address in CIDR notation to assign to the interface (e.g., '192.168.1.1/24'). | `string` | n/a | yes |
| <a name="input_authoritative"></a> [authoritative](#input\_authoritative) | Whether the DHCP server is authoritative. When set to 'yes', the server will send a NAK to clients requesting an address that is not in the pool. | `string` | `"yes"` | no |
| <a name="input_client_mac_limit"></a> [client\_mac\_limit](#input\_client\_mac\_limit) | Maximum number of MAC addresses allowed per client. | `number` | `1` | no |
| <a name="input_comment"></a> [comment](#input\_comment) | Comment prefix used for all created resources. Defaults to the interface name. | `string` | `null` | no |
| <a name="input_conflict_detection"></a> [conflict\_detection](#input\_conflict\_detection) | Whether to enable conflict detection for DHCP leases. | `bool` | `false` | no |
| <a name="input_create_dns_records"></a> [create\_dns\_records](#input\_create\_dns\_records) | Whether to create static DNS A records for each static lease. Can be overridden per-lease via the 'create\_dns\_record' attribute. | `bool` | `true` | no |
| <a name="input_dhcp_pool"></a> [dhcp\_pool](#input\_dhcp\_pool) | List of IP ranges for the DHCP pool (e.g., ['192.168.1.100-192.168.1.200']). | `list(string)` | n/a | yes |
| <a name="input_dns_servers"></a> [dns\_servers](#input\_dns\_servers) | List of DNS server IP addresses to provide to DHCP clients. | `list(string)` | `[]` | no |
| <a name="input_domain"></a> [domain](#input\_domain) | Domain name to provide to DHCP clients. | `string` | `""` | no |
| <a name="input_dynamic_lease_identifiers"></a> [dynamic\_lease\_identifiers](#input\_dynamic\_lease\_identifiers) | Specifies which fields are used to identify dynamic DHCP leases. | `string` | `"client-mac,client-id"` | no |
| <a name="input_gateway"></a> [gateway](#input\_gateway) | Gateway IP address for the network. If not specified, defaults to the first usable IP in the network (the network address + 1). | `string` | `null` | no |
| <a name="input_interface"></a> [interface](#input\_interface) | Name of the RouterOS interface the DHCP server is bound to. | `string` | n/a | yes |
| <a name="input_lease_time"></a> [lease\_time](#input\_lease\_time) | Default DHCP lease time (e.g., '00:10:00' for 10 minutes, '1d 00:00:00' for 1 day). If not set, RouterOS default is used. | `string` | `null` | no |
| <a name="input_network"></a> [network](#input\_network) | Network address in CIDR notation (e.g., '192.168.1.0/24'). | `string` | n/a | yes |
| <a name="input_pool_name"></a> [pool\_name](#input\_pool\_name) | Name for the DHCP IP pool. Defaults to '{interface}-dhcp-pool' if not specified. | `string` | `null` | no |
| <a name="input_server_name"></a> [server\_name](#input\_server\_name) | Name for the DHCP server resource. Defaults to the interface name if not specified. | `string` | `null` | no |
| <a name="input_static_leases"></a> [static\_leases](#input\_static\_leases) | Map of static DHCP leases keyed by IP address. Each entry requires 'mac' and 'name'. Optionally set 'create\_dns\_record' to override the global DNS record creation flag, and 'match\_subdomain' to enable wildcard DNS matching. | <pre>map(object({<br/>    mac               = string<br/>    name              = string<br/>    create_dns_record = optional(bool)<br/>    match_subdomain   = optional(bool)<br/>  }))</pre> | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_dns_record_count"></a> [dns\_record\_count](#output\_dns\_record\_count) | The number of DNS records created for static leases. |
| <a name="output_gateway"></a> [gateway](#output\_gateway) | The gateway IP address provided to DHCP clients. |
| <a name="output_network_address"></a> [network\_address](#output\_network\_address) | The network address in CIDR notation served by this DHCP server. |
| <a name="output_pool_name"></a> [pool\_name](#output\_pool\_name) | The name of the DHCP IP pool. |
| <a name="output_server_id"></a> [server\_id](#output\_server\_id) | The ID of the DHCP server resource. |
| <a name="output_server_name"></a> [server\_name](#output\_server\_name) | The name of the DHCP server resource. |
| <a name="output_static_lease_count"></a> [static\_lease\_count](#output\_static\_lease\_count) | The number of static DHCP leases configured. |
<!-- END_TF_DOCS -->
