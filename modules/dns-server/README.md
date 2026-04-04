# MikroTik DNS Server

Terraform module for configuring the DNS server on a MikroTik RouterOS device. It manages the DNS server settings, upstream resolvers, static DNS records, and optional DNS-based ad blocking via adlists.

## Usage

```hcl
module "dns_server" {
  source = "./modules/mikrotik-dns-server"

  # Upstream resolvers
  upstream_dns = ["1.1.1.1", "1.0.0.1", "8.8.8.8"]

  # Cache settings
  cache_size    = 8192
  cache_max_ttl = "1d"

  # Allow LAN clients to query this DNS server
  allow_remote_requests = true

  # Optional: DNS-based ad blocking
  adlist_url        = "https://raw.githubusercontent.com/StevenBlack/hosts/master/hosts"
  adlist_ssl_verify = true

  # Static DNS records
  static_dns = {
    "router.lan" = {
      type    = "A"
      address = "192.168.1.1"
      comment = "Router"
    }
    "nas.lan" = {
      type    = "A"
      address = "192.168.1.10"
      comment = "NAS"
    }
    "www.example.lan" = {
      type  = "CNAME"
      cname = "server.example.lan"
    }
    "example.lan" = {
      type          = "MX"
      mx_exchange   = "mail.example.lan"
      mx_preference = 10
      comment       = "Mail server"
    }
    "*.apps.lan" = {
      type            = "A"
      address         = "192.168.1.50"
      match_subdomain = true
      comment         = "Wildcard for app server"
    }
  }
}
```

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
| [routeros_ip_dns.server](https://registry.terraform.io/providers/terraform-routeros/routeros/latest/docs/resources/ip_dns) | resource |
| [routeros_ip_dns_adlist.adlist](https://registry.terraform.io/providers/terraform-routeros/routeros/latest/docs/resources/ip_dns_adlist) | resource |
| [routeros_ip_dns_record.static](https://registry.terraform.io/providers/terraform-routeros/routeros/latest/docs/resources/ip_dns_record) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_adlist_ssl_verify"></a> [adlist\_ssl\_verify](#input\_adlist\_ssl\_verify) | Whether to verify SSL certificates when fetching the adblock list. Only relevant when adlist\_url is set. | `bool` | `false` | no |
| <a name="input_adlist_url"></a> [adlist\_url](#input\_adlist\_url) | URL to an adblock list for DNS-based ad blocking. Set to null to disable ad blocking. | `string` | `null` | no |
| <a name="input_allow_remote_requests"></a> [allow\_remote\_requests](#input\_allow\_remote\_requests) | Whether to allow DNS requests from remote hosts (clients on the network). Set to false to restrict DNS to the router itself. | `bool` | `true` | no |
| <a name="input_cache_max_ttl"></a> [cache\_max\_ttl](#input\_cache\_max\_ttl) | Maximum time-to-live for cached DNS entries. Accepts RouterOS duration format (e.g., '1d', '12h', '30m', '3600'). | `string` | `"1d"` | no |
| <a name="input_cache_size"></a> [cache\_size](#input\_cache\_size) | Size of the DNS cache in KiB. Higher values use more memory but can improve performance. | `number` | `8192` | no |
| <a name="input_static_dns"></a> [static\_dns](#input\_static\_dns) | Map of static DNS records. The map key is used as the record name (FQDN).<br/><br/>Supported record types and their required fields:<br/>- A/AAAA:  set 'address' to the target IP<br/>- CNAME:   set 'cname' to the canonical name<br/>- MX:      set 'mx\_exchange' and optionally 'mx\_preference'<br/>- SRV:     set 'srv\_target', 'srv\_port', and optionally 'srv\_priority' / 'srv\_weight'<br/>- TXT:     set 'text' to the TXT record content<br/>- FWD:     set 'address' to the forwarding server address<br/>- NXDOMAIN: no additional fields required (sinkhole record) | <pre>map(object({<br/>    type            = string<br/>    address         = optional(string)<br/>    cname           = optional(string)<br/>    mx_exchange     = optional(string)<br/>    mx_preference   = optional(number)<br/>    srv_port        = optional(number)<br/>    srv_target      = optional(string)<br/>    srv_priority    = optional(number)<br/>    srv_weight      = optional(number)<br/>    text            = optional(string)<br/>    ttl             = optional(string)<br/>    match_subdomain = optional(bool, false)<br/>    disabled        = optional(bool, false)<br/>    comment         = optional(string, "")<br/>  }))</pre> | `{}` | no |
| <a name="input_upstream_dns"></a> [upstream\_dns](#input\_upstream\_dns) | List of upstream DNS server addresses to forward queries to (e.g., ["1.1.1.1", "8.8.8.8"]). | `list(string)` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_adlist_enabled"></a> [adlist\_enabled](#output\_adlist\_enabled) | Whether DNS-based ad blocking is enabled. |
| <a name="output_allow_remote_requests"></a> [allow\_remote\_requests](#output\_allow\_remote\_requests) | Whether remote DNS requests are allowed. |
| <a name="output_cache_size"></a> [cache\_size](#output\_cache\_size) | The configured DNS cache size in KiB. |
| <a name="output_dns_server_id"></a> [dns\_server\_id](#output\_dns\_server\_id) | The ID of the DNS server resource. |
| <a name="output_static_record_count"></a> [static\_record\_count](#output\_static\_record\_count) | The number of static DNS records managed by this module. |
| <a name="output_static_records"></a> [static\_records](#output\_static\_records) | Map of all managed static DNS records with their IDs. |
| <a name="output_upstream_servers"></a> [upstream\_servers](#output\_upstream\_servers) | The list of upstream DNS servers configured. |
<!-- END_TF_DOCS -->
