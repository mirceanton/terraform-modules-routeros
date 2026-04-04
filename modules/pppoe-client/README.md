# mikrotik-pppoe-client

Terraform module for managing a PPPoE client interface on MikroTik RouterOS devices using the `routeros` provider.

This module creates and configures a `routeros_interface_pppoe_client` resource, providing a simple interface for establishing PPPoE connections commonly used with DSL, fiber, and other broadband services.

## Usage

```hcl
module "pppoe_wan" {
  source = "./modules/mikrotik-pppoe-client"

  interface         = "ether1"
  name              = "pppoe-wan"
  comment           = "ISP WAN connection"
  username          = var.pppoe_username
  password          = var.pppoe_password
  add_default_route = true
  use_peer_dns      = false
}
```

### Advanced example

```hcl
module "pppoe_wan" {
  source = "./modules/mikrotik-pppoe-client"

  interface         = "ether1"
  name              = "pppoe-wan"
  comment           = "ISP WAN connection"
  username          = var.pppoe_username
  password          = var.pppoe_password
  add_default_route = true
  use_peer_dns      = false
  max_mtu           = 1492
  max_mru           = 1492
  keepalive_timeout = 30
  service_name      = "internet"
  profile           = "default"
}
```

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.0 |
| <a name="requirement_routeros"></a> [routeros](#requirement\_routeros) | >= 1.99.1 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_routeros"></a> [routeros](#provider\_routeros) | >= 1.99.1 |

## Resources

| Name | Type |
|------|------|
| [routeros_interface_pppoe_client.this](https://registry.terraform.io/providers/terraform-routeros/routeros/latest/docs/resources/interface_pppoe_client) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_ac_name"></a> [ac\_name](#input\_ac\_name) | PPPoE Access Concentrator name. Used to connect to a specific access concentrator. | `string` | `null` | no |
| <a name="input_add_default_route"></a> [add\_default\_route](#input\_add\_default\_route) | Whether to add a default route when connected. | `bool` | `true` | no |
| <a name="input_comment"></a> [comment](#input\_comment) | Optional comment or description for the PPPoE client interface. | `string` | `""` | no |
| <a name="input_disabled"></a> [disabled](#input\_disabled) | Whether the PPPoE client interface is disabled. | `bool` | `false` | no |
| <a name="input_interface"></a> [interface](#input\_interface) | Physical interface to use for PPPoE connection (e.g., ether1). | `string` | n/a | yes |
| <a name="input_keepalive_timeout"></a> [keepalive\_timeout](#input\_keepalive\_timeout) | PPP keepalive timeout in seconds. Defines how long to wait before considering the connection dead. | `number` | `null` | no |
| <a name="input_max_mru"></a> [max\_mru](#input\_max\_mru) | Maximum Receive Unit size for the PPPoE client interface. Common values are 1480 or 1492. | `number` | `null` | no |
| <a name="input_max_mtu"></a> [max\_mtu](#input\_max\_mtu) | Maximum Transmission Unit size for the PPPoE client interface. Common values are 1480 or 1492. | `number` | `null` | no |
| <a name="input_name"></a> [name](#input\_name) | Name for the PPPoE client interface. | `string` | n/a | yes |
| <a name="input_password"></a> [password](#input\_password) | PPPoE authentication password. | `string` | n/a | yes |
| <a name="input_profile"></a> [profile](#input\_profile) | PPP profile to use for the connection. | `string` | `"default"` | no |
| <a name="input_service_name"></a> [service\_name](#input\_service\_name) | PPPoE service name. Used to connect to a specific service when multiple services are available. | `string` | `null` | no |
| <a name="input_use_peer_dns"></a> [use\_peer\_dns](#input\_use\_peer\_dns) | Whether to use DNS servers provided by the PPPoE server. | `bool` | `false` | no |
| <a name="input_username"></a> [username](#input\_username) | PPPoE authentication username. | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_disabled"></a> [disabled](#output\_disabled) | Whether the PPPoE client interface is disabled. |
| <a name="output_id"></a> [id](#output\_id) | The unique identifier of the PPPoE client resource. |
| <a name="output_name"></a> [name](#output\_name) | The name of the PPPoE client interface. |
| <a name="output_running"></a> [running](#output\_running) | Whether the PPPoE client interface is currently running. |
<!-- END_TF_DOCS -->
