resource "routeros_ip_dns" "server" {
  allow_remote_requests = var.allow_remote_requests
  servers               = var.upstream_dns
  cache_size            = var.cache_size
  cache_max_ttl         = var.cache_max_ttl
}

resource "routeros_ip_dns_adlist" "adlist" {
  count = var.adlist_url != null && var.adlist_url != "" ? 1 : 0

  url        = var.adlist_url
  ssl_verify = var.adlist_ssl_verify
}

resource "routeros_ip_dns_record" "static" {
  for_each = var.static_dns

  name            = each.key
  type            = each.value.type
  address         = each.value.address
  cname           = each.value.cname
  mx_exchange     = each.value.mx_exchange
  mx_preference   = each.value.mx_preference
  srv_port        = each.value.srv_port
  srv_target      = each.value.srv_target
  srv_priority    = each.value.srv_priority
  srv_weight      = each.value.srv_weight
  text            = each.value.text
  ttl             = each.value.ttl
  match_subdomain = each.value.match_subdomain
  disabled        = each.value.disabled
  comment         = each.value.comment
}
