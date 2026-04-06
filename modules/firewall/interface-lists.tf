# --- Interface Lists -----------------------------------------------------------
# Manages RouterOS interface lists and their members. Interface lists group
# physical or virtual interfaces so they can be referenced collectively in
# firewall rules (e.g., "WAN", "LAN").

resource "routeros_interface_list" "this" {
  for_each = var.interface_lists

  name    = each.key
  comment = each.value.comment
}

# --- Interface List Members ---------------------------------------------------
# Flattens the nested interface_lists variable into a map keyed by
# "list_name/interface_name" so that each membership can be managed
# independently via for_each.

locals {
  interface_list_members = merge([
    for list_name, list_config in var.interface_lists : {
      for interface in list_config.interfaces :
      "${list_name}/${interface}" => {
        list      = list_name
        interface = interface
      }
    }
  ]...)
}

resource "routeros_interface_list_member" "this" {
  for_each = local.interface_list_members

  list      = routeros_interface_list.this[each.value.list].name
  interface = each.value.interface
}
