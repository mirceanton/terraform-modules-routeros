# MikroTik Routing

Terraform module for managing routing configurations on a MikroTik RouterOS device. It manages static routes, supporting standard next-hop routes, blackhole routes, and policy routing via routing tables.

## Usage

```hcl
module "routing" {
  source = "git::https://github.com/mirceanton/terraform-modules-routeros.git//modules/routing?ref=main"
  # source = "oci://ghcr.io/mirceanton/terraform-modules-routeros/routing:latest"

  static_routes = {
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
    "isp-failover" = {
      dst_address   = "0.0.0.0/0"
      gateway       = "192.168.2.1"
      distance      = 10
      check_gateway = "ping"
      comment       = "Failover route via secondary ISP"
    }
  }
}
```

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
| ---- | ------- |
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.0 |
| <a name="requirement_routeros"></a> [routeros](#requirement\_routeros) | >= 1.99.1 |

## Providers

| Name | Version |
| ---- | ------- |
| <a name="provider_routeros"></a> [routeros](#provider\_routeros) | >= 1.99.1 |

## Resources

| Name | Type |
| ---- | ---- |
| [routeros_ip_route.this](https://registry.terraform.io/providers/terraform-routeros/routeros/latest/docs/resources/ip_route) | resource |

## Inputs

| Name | Description | Type | Default | Required |
| ---- | ----------- | ---- | ------- | :------: |
| <a name="input_static_routes"></a> [static\_routes](#input\_static\_routes) | Map of static routes to create. The key is a human-readable identifier<br/>included in the auto-generated comment if no explicit comment is provided.<br/><br/>Example:<br/>{<br/>  "default-via-isp" = {<br/>    dst\_address = "0.0.0.0/0"<br/>    gateway     = "192.168.1.1"<br/>    distance    = 1<br/>  }<br/>  "lan-via-vpn" = {<br/>    dst\_address = "10.0.0.0/8"<br/>    gateway     = "wg0"<br/>    comment     = "Route LAN traffic through WireGuard"<br/>  }<br/>  "blackhole-rfc1918" = {<br/>    dst\_address = "172.16.0.0/12"<br/>    gateway     = ""<br/>    blackhole   = true<br/>  }<br/>} | <pre>map(object({<br/>    gateway       = string<br/>    dst_address   = optional(string)<br/>    distance      = optional(number)<br/>    comment       = optional(string)<br/>    disabled      = optional(bool, false)<br/>    blackhole     = optional(bool, false)<br/>    check_gateway = optional(string)<br/>    routing_table = optional(string)<br/>    pref_src      = optional(string)<br/>  }))</pre> | `{}` | no |

## Outputs

| Name | Description |
| ---- | ----------- |
| <a name="output_static_route_count"></a> [static\_route\_count](#output\_static\_route\_count) | Total number of static routes managed by this module. |
| <a name="output_static_route_ids"></a> [static\_route\_ids](#output\_static\_route\_ids) | Map of static route keys to their RouterOS resource IDs. |
<!-- END_TF_DOCS -->