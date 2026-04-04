output "peers" {
  description = "A map of peer name to generated WireGuard key pairs (public and private keys)."
  sensitive   = true
  value = {
    for k, v in routeros_wireguard_keys.peers : k => {
      public_key  = v.keys[0].public
      private_key = v.keys[0].private
    }
  }
}

output "peer_count" {
  description = "The total number of WireGuard peers managed by this module."
  value       = length(var.peers)
}

output "peer_names" {
  description = "A list of all peer names managed by this module."
  value       = keys(var.peers)
}
