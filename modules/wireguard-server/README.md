# mikrotik-wireguard-server

Terraform module for creating a WireGuard server interface on a MikroTik device running RouterOS.

This module provisions a WireGuard interface along with its associated IP address. It handles key generation automatically (RouterOS generates a key pair if no private key is supplied) and exposes the public key as an output so it can be shared with peers.

## Usage

```hcl
module "wireguard" {
  source = "path/to/modules/mikrotik-wireguard-server"

  name        = "wg0"
  address     = "10.0.0.1/24"
  listen_port = 51820
  comment     = "WireGuard VPN server"
}

output "wireguard_public_key" {
  description = "Share this key with WireGuard peers."
  value       = module.wireguard.public_key
}
```

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.0 |
| <a name="requirement_routeros"></a> [routeros](#requirement\_routeros) | >= 1.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_routeros"></a> [routeros](#provider\_routeros) | >= 1.0 |

## Resources

| Name | Type |
|------|------|
| [routeros_interface_wireguard.this](https://registry.terraform.io/providers/terraform-routeros/routeros/latest/docs/resources/interface_wireguard) | resource |
| [routeros_ip_address.this](https://registry.terraform.io/providers/terraform-routeros/routeros/latest/docs/resources/ip_address) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_address"></a> [address](#input\_address) | The IP address in CIDR notation to assign to the WireGuard interface (e.g. "10.0.0.1/24"). | `string` | n/a | yes |
| <a name="input_comment"></a> [comment](#input\_comment) | An optional comment or description for the WireGuard interface and its IP address. | `string` | `""` | no |
| <a name="input_disabled"></a> [disabled](#input\_disabled) | Whether the WireGuard interface should be disabled. | `bool` | `false` | no |
| <a name="input_listen_port"></a> [listen\_port](#input\_listen\_port) | The UDP port on which the WireGuard interface will listen for incoming connections. | `number` | `51820` | no |
| <a name="input_mtu"></a> [mtu](#input\_mtu) | The Maximum Transmission Unit (MTU) size for the WireGuard interface. The default of 1420 accounts for WireGuard overhead on standard 1500-byte links. | `number` | `1420` | no |
| <a name="input_name"></a> [name](#input\_name) | The name of the WireGuard interface to create (e.g. "wg0"). | `string` | n/a | yes |
| <a name="input_private_key"></a> [private\_key](#input\_private\_key) | An optional WireGuard private key. If omitted, RouterOS will auto-generate a key pair. | `string` | `null` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_address"></a> [address](#output\_address) | The IP address in CIDR notation assigned to the WireGuard interface. |
| <a name="output_listen_port"></a> [listen\_port](#output\_listen\_port) | The UDP port the WireGuard interface is listening on. |
| <a name="output_mtu"></a> [mtu](#output\_mtu) | The MTU configured on the WireGuard interface. |
| <a name="output_name"></a> [name](#output\_name) | The name of the created WireGuard interface. |
| <a name="output_private_key"></a> [private\_key](#output\_private\_key) | The WireGuard private key of the server interface. |
| <a name="output_public_key"></a> [public\_key](#output\_public\_key) | The WireGuard public key of the server interface. Share this with peers to establish connections. |
| <a name="output_running"></a> [running](#output\_running) | Whether the WireGuard interface is currently running. |
<!-- END_TF_DOCS -->
