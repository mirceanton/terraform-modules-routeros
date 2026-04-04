output "dns_server_id" {
  description = "The ID of the DNS server resource."
  value       = routeros_ip_dns.server.id
}

output "allow_remote_requests" {
  description = "Whether remote DNS requests are allowed."
  value       = routeros_ip_dns.server.allow_remote_requests
}

output "upstream_servers" {
  description = "The list of upstream DNS servers configured."
  value       = routeros_ip_dns.server.servers
}

output "cache_size" {
  description = "The configured DNS cache size in KiB."
  value       = routeros_ip_dns.server.cache_size
}

output "static_record_count" {
  description = "The number of static DNS records managed by this module."
  value       = length(routeros_ip_dns_record.static)
}

output "adlist_enabled" {
  description = "Whether DNS-based ad blocking is enabled."
  value       = length(routeros_ip_dns_adlist.adlist) > 0
}

output "static_records" {
  description = "Map of all managed static DNS records with their IDs."
  value = {
    for name, record in routeros_ip_dns_record.static :
    name => {
      id   = record.id
      type = record.type
    }
  }
}
