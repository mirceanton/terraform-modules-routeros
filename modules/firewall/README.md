# MikroTik Firewall Terraform Module

A Terraform module for managing MikroTik RouterOS firewall configuration, including interface lists, NAT rules, and filter rules. It uses the [terraform-routeros/routeros](https://registry.terraform.io/providers/terraform-routeros/routeros/latest) provider and provides deterministic rule ordering through a numeric `order` field on each rule.

## Usage

```hcl
module "firewall" {
  source = "./modules/mikrotik-firewall"

  # --- Interface Lists ---
  interface_lists = {
    WAN = {
      comment    = "Public-facing interfaces"
      interfaces = ["ether1"]
    }
    LAN = {
      comment    = "Local network interfaces"
      interfaces = ["bridge", "vlan-trusted"]
    }
  }

  # --- NAT Rules ---
  nat_rules = {
    "masquerade-wan" = {
      chain              = "srcnat"
      action             = "masquerade"
      out_interface_list = "WAN"
      order              = 100
    }
  }

  # --- Filter Rules ---
  filter_rules = {
    # Input chain
    "input-accept-established" = {
      chain            = "input"
      action           = "accept"
      connection_state = "established,related,untracked"
      order            = 100
    }
    "input-drop-invalid" = {
      chain            = "input"
      action           = "drop"
      connection_state = "invalid"
      order            = 200
    }
    "input-accept-icmp" = {
      chain    = "input"
      action   = "accept"
      protocol = "icmp"
      order    = 300
    }
    "input-drop-all" = {
      chain  = "input"
      action = "drop"
      order  = 900
    }

    # Forward chain
    "forward-fasttrack" = {
      chain            = "forward"
      action           = "fasttrack-connection"
      connection_state = "established,related"
      hw_offload       = true
      order            = 1000
    }
    "forward-accept-established" = {
      chain            = "forward"
      action           = "accept"
      connection_state = "established,related,untracked"
      order            = 1100
    }
    "forward-drop-invalid" = {
      chain            = "forward"
      action           = "drop"
      connection_state = "invalid"
      order            = 1200
    }
    "forward-drop-all" = {
      chain  = "forward"
      action = "drop"
      order  = 1900
    }
  }
}
```

## How Rule Ordering Works

Each rule requires a numeric `order` field. The module generates a zero-padded sort key (`NNNN-name`) from the order and the rule map key. After all rules are created, a `routeros_move_items` resource reorders them on the router so they are evaluated in the correct sequence. Lower order numbers are evaluated first.

Use gaps between order values (e.g., 100, 200, 300) to leave room for inserting rules later without renumbering everything.

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
| [routeros_interface_list.this](https://registry.terraform.io/providers/terraform-routeros/routeros/latest/docs/resources/interface_list) | resource |
| [routeros_interface_list_member.this](https://registry.terraform.io/providers/terraform-routeros/routeros/latest/docs/resources/interface_list_member) | resource |
| [routeros_ip_firewall_addr_list.this](https://registry.terraform.io/providers/terraform-routeros/routeros/latest/docs/resources/ip_firewall_addr_list) | resource |
| [routeros_ip_firewall_filter.this](https://registry.terraform.io/providers/terraform-routeros/routeros/latest/docs/resources/ip_firewall_filter) | resource |
| [routeros_ip_firewall_nat.this](https://registry.terraform.io/providers/terraform-routeros/routeros/latest/docs/resources/ip_firewall_nat) | resource |
| [routeros_move_items.filter_rules](https://registry.terraform.io/providers/terraform-routeros/routeros/latest/docs/resources/move_items) | resource |
| [routeros_move_items.nat_rules](https://registry.terraform.io/providers/terraform-routeros/routeros/latest/docs/resources/move_items) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_address_lists"></a> [address\_lists](#input\_address\_lists) | Map of address lists to create with their member addresses.<br/>Each key becomes the address list name on the router.<br/><br/>Example:<br/>{<br/>  wireguard-clients = {<br/>    comment   = "WireGuard client IPs"<br/>    addresses = ["10.10.0.2", "10.10.0.3"]<br/>  }<br/>  trusted-hosts = {<br/>    comment   = "Trusted management hosts"<br/>    addresses = ["192.168.1.10/32"]<br/>  }<br/>} | <pre>map(object({<br/>    comment   = optional(string, "")<br/>    addresses = list(string)<br/>  }))</pre> | `{}` | no |
| <a name="input_filter_rules"></a> [filter\_rules](#input\_filter\_rules) | Map of firewall filter rules to create. Rules are ordered by the 'order'<br/>field, which determines their placement in the RouterOS filter chain. Lower<br/>numbers are evaluated first. The key is used as a human-readable identifier<br/>and is included in the auto-generated comment if no explicit comment is<br/>provided.<br/><br/>Example:<br/>{<br/>  "accept-established" = {<br/>    chain            = "input"<br/>    action           = "accept"<br/>    connection\_state = "established,related,untracked"<br/>    order            = 100<br/>  }<br/>  "drop-invalid" = {<br/>    chain            = "input"<br/>    action           = "drop"<br/>    connection\_state = "invalid"<br/>    order            = 200<br/>  }<br/>} | <pre>map(object({<br/>    chain              = string<br/>    action             = string<br/>    order              = number<br/>    comment            = optional(string)<br/>    connection_state   = optional(string)<br/>    src_address        = optional(string)<br/>    dst_address        = optional(string)<br/>    src_address_list   = optional(string)<br/>    dst_address_list   = optional(string)<br/>    src_port           = optional(string)<br/>    dst_port           = optional(string)<br/>    protocol           = optional(string)<br/>    in_interface       = optional(string)<br/>    out_interface      = optional(string)<br/>    in_interface_list  = optional(string)<br/>    out_interface_list = optional(string)<br/>    hw_offload         = optional(bool)<br/>    log                = optional(bool)<br/>    log_prefix         = optional(string)<br/>    jump_target        = optional(string)<br/>  }))</pre> | `{}` | no |
| <a name="input_interface_lists"></a> [interface\_lists](#input\_interface\_lists) | Map of interface lists to create with their members.<br/>Each key becomes the interface list name on the router.<br/><br/>Example:<br/>{<br/>  WAN = {<br/>    comment    = "All Public-Facing Interfaces"<br/>    interfaces = ["ether1"]<br/>  }<br/>  LAN = {<br/>    comment    = "All Local Interfaces"<br/>    interfaces = ["bridge", "vlan-trusted", "vlan-iot"]<br/>  }<br/>} | <pre>map(object({<br/>    comment    = optional(string, "")<br/>    interfaces = list(string)<br/>  }))</pre> | `{}` | no |
| <a name="input_nat_rules"></a> [nat\_rules](#input\_nat\_rules) | Map of NAT rules to create. Rules are ordered by the 'order' field, which<br/>determines their placement in the RouterOS NAT chain. Lower numbers are<br/>evaluated first. The key is used as a human-readable identifier and is<br/>included in the auto-generated comment if no explicit comment is provided.<br/><br/>Example:<br/>{<br/>  "masquerade-wan" = {<br/>    chain              = "srcnat"<br/>    action             = "masquerade"<br/>    out\_interface\_list = "WAN"<br/>    order              = 100<br/>  }<br/>  "port-forward-web" = {<br/>    chain        = "dstnat"<br/>    action       = "dst-nat"<br/>    protocol     = "tcp"<br/>    dst\_port     = "443"<br/>    to\_addresses = "192.168.1.10"<br/>    to\_ports     = "443"<br/>    order        = 200<br/>  }<br/>} | <pre>map(object({<br/>    chain              = string<br/>    action             = string<br/>    order              = number<br/>    comment            = optional(string)<br/>    connection_rate    = optional(string)<br/>    src_address        = optional(string)<br/>    dst_address        = optional(string)<br/>    src_address_list   = optional(string)<br/>    dst_address_list   = optional(string)<br/>    src_port           = optional(string)<br/>    dst_port           = optional(string)<br/>    protocol           = optional(string)<br/>    in_interface       = optional(string)<br/>    out_interface      = optional(string)<br/>    in_interface_list  = optional(string)<br/>    out_interface_list = optional(string)<br/>    to_addresses       = optional(string)<br/>    to_ports           = optional(string)<br/>    log                = optional(bool)<br/>    log_prefix         = optional(string)<br/>  }))</pre> | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_address_list_ids"></a> [address\_list\_ids](#output\_address\_list\_ids) | Map of address list entry keys (list/address) to their RouterOS resource IDs. |
| <a name="output_address_list_names"></a> [address\_list\_names](#output\_address\_list\_names) | Distinct address list names created by this module. |
| <a name="output_filter_rule_count"></a> [filter\_rule\_count](#output\_filter\_rule\_count) | Total number of filter rules managed by this module. |
| <a name="output_filter_rule_ids"></a> [filter\_rule\_ids](#output\_filter\_rule\_ids) | Map of filter rule sort keys to their RouterOS resource IDs. |
| <a name="output_interface_list_ids"></a> [interface\_list\_ids](#output\_interface\_list\_ids) | Map of interface list names to their RouterOS resource IDs. |
| <a name="output_interface_list_names"></a> [interface\_list\_names](#output\_interface\_list\_names) | List of interface list names created by this module. |
| <a name="output_nat_rule_count"></a> [nat\_rule\_count](#output\_nat\_rule\_count) | Total number of NAT rules managed by this module. |
| <a name="output_nat_rule_ids"></a> [nat\_rule\_ids](#output\_nat\_rule\_ids) | Map of NAT rule sort keys to their RouterOS resource IDs. |
<!-- END_TF_DOCS -->
