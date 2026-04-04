# --- NAT Rules ----------------------------------------------------------------
# Manages RouterOS IP firewall NAT rules with deterministic ordering.
#
# Rule ordering mechanism:
#   1. Each rule has a numeric `order` field (lower = higher priority).
#   2. A sort key is generated as "NNNN-name" (zero-padded order + rule key)
#      so that lexicographic sorting produces the desired evaluation order.
#   3. After all rules are created, a `routeros_move_items` resource reorders
#      them on the router to match the sorted sequence.

locals {
  nat_rules_ordered = [
    for k, v in var.nat_rules : merge(v, {
      key      = k
      sort_key = format("%04d-%s", v.order, k)
    })
  ]

  nat_rules_map = {
    for rule in local.nat_rules_ordered :
    rule.sort_key => rule
  }
}

resource "routeros_ip_firewall_nat" "this" {
  for_each = local.nat_rules_map

  comment = coalesce(each.value.comment, "Managed by Terraform - ${each.value.key}")
  chain   = each.value.chain
  action  = each.value.action

  connection_rate    = each.value.connection_rate
  in_interface       = each.value.in_interface
  out_interface      = each.value.out_interface
  in_interface_list  = each.value.in_interface_list
  out_interface_list = each.value.out_interface_list
  protocol           = each.value.protocol
  dst_port           = each.value.dst_port
  src_port           = each.value.src_port
  src_address        = each.value.src_address
  dst_address        = each.value.dst_address
  to_addresses       = each.value.to_addresses
  to_ports           = each.value.to_ports
  log                = each.value.log
  log_prefix         = each.value.log_prefix

  depends_on = [routeros_interface_list.this]

  lifecycle {
    create_before_destroy = true
  }
}

# Reorder NAT rules on the router to match the sorted sequence.
resource "routeros_move_items" "nat_rules" {
  count = length(var.nat_rules) > 0 ? 1 : 0

  resource_path = "/ip/firewall/nat"
  sequence      = [for idx in sort(keys(local.nat_rules_map)) : routeros_ip_firewall_nat.this[idx].id]

  depends_on = [routeros_ip_firewall_nat.this]
}
