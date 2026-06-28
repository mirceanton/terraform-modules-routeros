resource "routeros_ip_route" "this" {
  for_each = var.static_routes

  gateway       = each.value.gateway
  dst_address   = each.value.dst_address
  distance      = each.value.distance
  disabled      = each.value.disabled
  blackhole     = each.value.blackhole
  check_gateway = each.value.check_gateway
  routing_table = each.value.routing_table
  pref_src      = each.value.pref_src
  comment       = coalesce(each.value.comment, "Managed by Terraform - ${each.key}")
}
