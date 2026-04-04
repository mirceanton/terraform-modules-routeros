# MikroTik WireGuard Peers

Terraform module for managing WireGuard peers on MikroTik RouterOS devices.

This module generates WireGuard key pairs for each peer and creates the corresponding peer configuration on a specified WireGuard interface. It is designed to simplify bulk peer provisioning on MikroTik routers using the [terraform-routeros/routeros](https://registry.terraform.io/providers/terraform-routeros/routeros/latest) provider.

## Usage

```hcl
module "wireguard_peers" {
  source = "./modules/mikrotik-wireguard-peers"

  interface = "wireguard1"

  peers = {
    laptop = {
      allowed_address      = ["10.0.0.2/32"]
      comment              = "Work laptop"
      persistent_keepalive = "25"
    }

    phone = {
      allowed_address  = ["10.0.0.3/32"]
      comment          = "Mobile phone"
      endpoint_address = "vpn.example.com"
      endpoint_port    = 51820
    }

    site-b = {
      allowed_address      = ["10.0.0.4/32", "192.168.2.0/24"]
      comment              = "Site-to-site tunnel to Site B"
      endpoint_address     = "site-b.example.com"
      endpoint_port        = 51820
      persistent_keepalive = "25"
      preshared_key        = "base64encodedpresharedkey="
      is_responder         = false
    }
  }
}

# Retrieve the generated private key for client configuration
output "laptop_private_key" {
  value     = module.wireguard_peers.peers["laptop"].private_key
  sensitive = true
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
| [routeros_interface_wireguard_peer.this](https://registry.terraform.io/providers/terraform-routeros/routeros/latest/docs/resources/interface_wireguard_peer) | resource |
| [routeros_wireguard_keys.peers](https://registry.terraform.io/providers/terraform-routeros/routeros/latest/docs/resources/wireguard_keys) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_interface"></a> [interface](#input\_interface) | The name of the WireGuard interface to which the peers will be added. | `string` | n/a | yes |
| <a name="input_peers"></a> [peers](#input\_peers) | A map of peer configurations keyed by peer name.<br/><br/>Each peer object supports the following attributes:<br/>  - allowed\_address:      List of IP/CIDR ranges the peer is allowed to send traffic from.<br/>  - comment:              An optional comment for the peer.<br/>  - endpoint\_address:     The remote endpoint hostname or IP address.<br/>  - endpoint\_port:        The remote endpoint port number.<br/>  - persistent\_keepalive: Interval (in seconds) for sending keepalive packets (e.g., "25").<br/>  - preshared\_key:        An optional pre-shared key for additional security.<br/>  - is\_responder:         Whether this peer acts only as a responder (does not initiate connections).<br/>  - client\_dns:           DNS server address to assign to the peer (used for client configuration).<br/>  - client\_endpoint:      The endpoint address the client should use to connect. | <pre>map(object({<br/>    allowed_address      = list(string)<br/>    comment              = optional(string, "")<br/>    endpoint_address     = optional(string)<br/>    endpoint_port        = optional(number)<br/>    persistent_keepalive = optional(string)<br/>    preshared_key        = optional(string)<br/>    is_responder         = optional(bool)<br/>    client_dns           = optional(string)<br/>    client_endpoint      = optional(string)<br/>  }))</pre> | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_peer_count"></a> [peer\_count](#output\_peer\_count) | The total number of WireGuard peers managed by this module. |
| <a name="output_peer_names"></a> [peer\_names](#output\_peer\_names) | A list of all peer names managed by this module. |
| <a name="output_peers"></a> [peers](#output\_peers) | A map of peer name to generated WireGuard key pairs (public and private keys). |
<!-- END_TF_DOCS -->
