# mikrotik-cloud

Terraform module for managing the [MikroTik IP Cloud](https://help.mikrotik.com/docs/spaces/ROS/pages/328129/Cloud) service on RouterOS devices.

MikroTik IP Cloud provides Dynamic DNS (DDNS), public IP detection, and the optional Back to Home VPN feature. This module configures the `/ip/cloud` and `/ip/cloud/advanced` settings on a target router.

## Usage

```hcl
module "cloud" {
  source = "./modules/mikrotik-cloud"

  ddns_enabled         = true
  ddns_update_interval = "5m"
  back_to_home_vpn     = "disabled"
  update_time          = false
}

output "router_dns_name" {
  value = module.cloud.dns_name
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
| [routeros_ip_cloud.this](https://registry.terraform.io/providers/terraform-routeros/routeros/latest/docs/resources/ip_cloud) | resource |
| [routeros_ip_cloud_advanced.this](https://registry.terraform.io/providers/terraform-routeros/routeros/latest/docs/resources/ip_cloud_advanced) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_advanced_use_local_address"></a> [advanced\_use\_local\_address](#input\_advanced\_use\_local\_address) | Whether to assign a local (internal) router address to the dynamic DNS name instead of the public address. | `bool` | `false` | no |
| <a name="input_back_to_home_vpn"></a> [back\_to\_home\_vpn](#input\_back\_to\_home\_vpn) | Back to Home VPN feature mode. Controls the built-in VPN service provided by MikroTik Cloud. | `string` | `"revoked-and-disabled"` | no |
| <a name="input_ddns_enabled"></a> [ddns\_enabled](#input\_ddns\_enabled) | Whether to enable MikroTik Dynamic DNS (DDNS). When enabled, the router registers a DNS name under sn.mynetname.net. | `bool` | `false` | no |
| <a name="input_ddns_update_interval"></a> [ddns\_update\_interval](#input\_ddns\_update\_interval) | How often to update the DDNS record. Must be a RouterOS time duration (e.g. '30s', '5m', '1h'). Empty string uses the router default. | `string` | `"5m"` | no |
| <a name="input_update_time"></a> [update\_time](#input\_update\_time) | Whether to synchronize the router clock with the MikroTik Cloud server. Useful when no NTP client is configured. | `bool` | `false` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_dns_name"></a> [dns\_name](#output\_dns\_name) | The DDNS hostname assigned by MikroTik Cloud (e.g. <serial>.sn.mynetname.net). Only populated when ddns\_enabled is true. |
| <a name="output_public_address"></a> [public\_address](#output\_public\_address) | The public IPv4 address of the router as detected by MikroTik Cloud. |
| <a name="output_public_address_ipv6"></a> [public\_address\_ipv6](#output\_public\_address\_ipv6) | The public IPv6 address of the router as detected by MikroTik Cloud. |
<!-- END_TF_DOCS -->
