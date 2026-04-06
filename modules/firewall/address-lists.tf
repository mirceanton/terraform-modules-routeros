# --- Address Lists -------------------------------------------------------------
# Manages RouterOS IP firewall address lists and their entries. Address lists
# group IP addresses or subnets so they can be referenced collectively in
# firewall rules (e.g., "trusted-hosts", "wireguard-clients").

resource "routeros_ip_firewall_addr_list" "this" {
  for_each = local.address_list_entries

  list    = each.value.list
  address = each.value.address
  comment = coalesce(each.value.comment, "Managed by Terraform - ${each.value.list}")
}

# --- Address List Entries ------------------------------------------------------
# Flattens the nested address_lists variable into a map keyed by
# "list_name/address" so that each entry can be managed independently
# via for_each.

locals {
  address_list_entries = merge([
    for list_name, list_config in var.address_lists : {
      for address in list_config.addresses :
      "${list_name}/${address}" => {
        list    = list_name
        address = address
        comment = list_config.comment
      }
    }
  ]...)
}
