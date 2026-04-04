# =================================================================================================
# IP Services Configuration
# https://registry.terraform.io/providers/terraform-routeros/routeros/latest/docs/resources/ip_service
# =================================================================================================

locals {
  # Services that require TLS certificates
  tls_services = toset(["api-ssl", "www-ssl"])

  # Separate services into TLS and non-TLS groups
  non_tls_services = {
    for name, svc in var.ip_services : name => svc
    if !contains(local.tls_services, name)
  }
  tls_service_configs = {
    for name, svc in var.ip_services : name => svc
    if contains(local.tls_services, name)
  }
}


# =================================================================================================
# Non-TLS Services (api, ftp, ssh, telnet, winbox, www)
# =================================================================================================
resource "routeros_ip_service" "services" {
  for_each = local.non_tls_services

  numbers  = each.key
  port     = each.value.port
  disabled = !each.value.enabled
}


# =================================================================================================
# TLS Services (api-ssl, www-ssl)
# =================================================================================================
resource "routeros_ip_service" "tls_services" {
  for_each = local.tls_service_configs

  numbers     = each.key
  port        = each.value.port
  disabled    = !each.value.enabled
  tls_version = var.tls_version
  certificate = routeros_system_certificate.webfig.name
}
