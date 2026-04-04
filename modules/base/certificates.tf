# =================================================================================================
# Root CA Certificate
# https://registry.terraform.io/providers/terraform-routeros/routeros/latest/docs/resources/system_certificate
# =================================================================================================
resource "routeros_system_certificate" "local-root-ca-cert" {
  name        = "local-root-cert"
  common_name = "local-cert"
  key_size    = var.certificate_key_type
  key_usage   = ["key-cert-sign", "crl-sign"]
  trusted     = true
  sign {}

  lifecycle {
    ignore_changes = [sign]
  }
}


# =================================================================================================
# Device Certificate (signed by root CA)
# Used by TLS-enabled services (api-ssl, www-ssl)
# =================================================================================================
resource "routeros_system_certificate" "webfig" {
  name         = "webfig"
  common_name  = var.certificate_common_name
  country      = var.certificate_country
  locality     = var.certificate_locality
  organization = var.certificate_organization
  unit         = var.certificate_unit
  days_valid   = var.certificate_validity_days
  key_size     = var.certificate_key_type

  key_usage = ["key-cert-sign", "crl-sign", "digital-signature", "key-agreement", "tls-server"]

  trusted = true
  sign {
    ca = routeros_system_certificate.local-root-ca-cert.name
  }

  lifecycle {
    ignore_changes = [sign]
  }
}
