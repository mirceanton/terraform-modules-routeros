# --- Filter Rules --------------------------------------------------------------
# Manages RouterOS IP firewall filter rules with deterministic ordering.
#
# Rule ordering mechanism:
#   1. Each rule has a numeric `order` field (lower = higher priority).
#   2. A sort key is generated as "NNNN-name" (zero-padded order + rule key)
#      so that lexicographic sorting produces the desired evaluation order.
#   3. After all rules are created, a `routeros_move_items` resource reorders
#      them on the router to match the sorted sequence.

locals {
  filter_rules_ordered = [
    for k, v in var.filter_rules : merge(v, {
      key      = k
      sort_key = format("%04d-%s", v.order, k)
    })
  ]

  filter_rules_map = {
    for rule in local.filter_rules_ordered :
    rule.sort_key => rule
  }
}

resource "routeros_ip_firewall_filter" "this" {
  for_each = local.filter_rules_map

  comment = coalesce(each.value.comment, "Managed by Terraform - ${each.value.key}")
  chain   = each.value.chain
  action  = each.value.action

  connection_state   = each.value.connection_state
  in_interface       = each.value.in_interface
  out_interface      = each.value.out_interface
  in_interface_list  = each.value.in_interface_list
  out_interface_list = each.value.out_interface_list
  protocol           = each.value.protocol
  dst_port           = each.value.dst_port
  src_port           = each.value.src_port
  src_address        = each.value.src_address
  dst_address        = each.value.dst_address
  src_address_list   = each.value.src_address_list
  dst_address_list   = each.value.dst_address_list
  jump_target        = each.value.jump_target
  hw_offload         = each.value.hw_offload
  log                = each.value.log
  log_prefix         = each.value.log_prefix

  depends_on = [routeros_interface_list.this, routeros_ip_firewall_addr_list.this]

  lifecycle {
    create_before_destroy = true
  }
}

# Reorder filter rules on the router to match the sorted sequence.
resource "routeros_move_items" "filter_rules" {
  count = length(var.filter_rules) > 0 ? 1 : 0

  resource_path = "/ip/firewall/filter"
  sequence      = [for idx in sort(keys(local.filter_rules_map)) : routeros_ip_firewall_filter.this[idx].id]

  depends_on = [routeros_ip_firewall_filter.this]
}
