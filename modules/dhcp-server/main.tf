locals {
  # Naming defaults: fall back to interface name if not explicitly set
  server_name = coalesce(var.server_name, var.interface)
  pool_name   = coalesce(var.pool_name, "${var.interface}-dhcp-pool")
  comment     = coalesce(var.comment, var.interface)

  # If no gateway is specified, derive the first usable IP from the network CIDR
  gateway = coalesce(var.gateway, cidrhost(var.network, 1))

  # Determine which static leases should get DNS records.
  # Per-lease override takes precedence, otherwise fall back to global flag.
  leases_with_dns = {
    for ip, lease in var.static_leases : ip => lease
    if coalesce(lease.create_dns_record, var.create_dns_records)
  }
}

# --- IP Address ---

resource "routeros_ip_address" "this" {
  address   = var.address
  interface = var.interface
  network   = split("/", var.network)[0]
}

# --- DHCP Pool ---

resource "routeros_ip_pool" "this" {
  name    = local.pool_name
  comment = "${local.comment} DHCP Pool"
  ranges  = var.dhcp_pool
}

# --- DHCP Network ---

resource "routeros_ip_dhcp_server_network" "this" {
  comment    = "${local.comment} DHCP Network"
  domain     = var.domain
  address    = var.network
  gateway    = local.gateway
  dns_server = var.dns_servers
}

# --- DHCP Server ---

resource "routeros_ip_dhcp_server" "this" {
  name                      = local.server_name
  comment                   = "${local.comment} DHCP Server"
  address_pool              = routeros_ip_pool.this.name
  interface                 = var.interface
  authoritative             = var.authoritative
  lease_time                = var.lease_time
  client_mac_limit          = var.client_mac_limit
  conflict_detection        = var.conflict_detection
  dynamic_lease_identifiers = var.dynamic_lease_identifiers
}

# --- Static Leases ---

resource "routeros_ip_dhcp_server_lease" "this" {
  for_each    = var.static_leases
  server      = routeros_ip_dhcp_server.this.name
  address     = each.key
  mac_address = each.value.mac
  comment     = each.value.name
}

# --- DNS Records for Static Leases ---

resource "routeros_ip_dns_record" "this" {
  for_each = local.leases_with_dns

  name            = "${each.value.name}.${var.domain}"
  address         = each.key
  type            = "A"
  comment         = "[Auto] DHCP static lease for ${each.value.name}"
  match_subdomain = each.value.match_subdomain
}
