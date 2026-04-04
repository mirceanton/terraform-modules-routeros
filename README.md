# Terraform/OpenTofu Modules: RouterOS

A collection of reusable [OpenTofu](https://opentofu.org/) / [Terraform](https://www.terraform.io/) modules for configuring [MikroTik RouterOS](https://mikrotik.com/) devices using the [`routeros`](https://registry.terraform.io/providers/terraform-routeros/routeros/latest) provider.

## Modules

| Module                                        | Description                                                                   |
| --------------------------------------------- | ----------------------------------------------------------------------------- |
| [base](modules/base/)                         | System identity, NTP, certificates, IP services, bridge/VLANs, bonding, users |
| [firewall](modules/firewall/)                 | Firewall filter rules, NAT rules, and interface lists                         |
| [dhcp-server](modules/dhcp-server/)           | DHCP server with pools, networks, static leases, and DNS records              |
| [dns-server](modules/dns-server/)             | DNS server, static DNS records, and ad-blocking                               |
| [pppoe-client](modules/pppoe-client/)         | PPPoE client interface configuration                                          |
| [capsman](modules/capsman/)                   | CAPsMAN wireless controller (WiFi channels, security, provisioning)           |
| [cloud](modules/cloud/)                       | MikroTik IP Cloud (DDNS, public IP detection)                                 |
| [wireguard-server](modules/wireguard-server/) | WireGuard server interface and IP address                                     |
| [wireguard-peers](modules/wireguard-peers/)   | WireGuard peer management with auto-generated keys                            |

## Usage

### From OCI Registry (OpenTofu >= 1.8)

```hcl
module "base" {
  source  = "oci://ghcr.io/mirceanton/terraform-routeros-modules/base"
  version = "1.0.0"

  hostname = "my-router"
  # ...
}
```

### From Git

```hcl
module "base" {
  source = "git::https://github.com/mirceanton/terraform-routeros-modules.git//modules/base?ref=v1.0.0"

  hostname = "my-router"
  # ...
}
```

## Versioning

This repository uses a single [semver](https://semver.org/) tag (e.g., `v1.0.0`) for all modules. All modules in a release share the same version.

## License

MIT - see [LICENSE](LICENSE).
