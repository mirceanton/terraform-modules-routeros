# =================================================================================================
# Bond Interfaces
# https://registry.terraform.io/providers/terraform-routeros/routeros/latest/docs/resources/interface_bonding
# =================================================================================================
resource "routeros_interface_bonding" "bonds" {
  for_each = var.bond_interfaces

  name                 = each.key
  slaves               = each.value.slaves
  comment              = each.value.comment
  mode                 = each.value.mode
  transmit_hash_policy = each.value.transmit_hash_policy
  mtu                  = each.value.mtu

}

# =================================================================================================
# Bond Bridge Ports
# Adds bond interfaces as bridge members. PVID logic mirrors ethernet bridge ports above.
# https://registry.terraform.io/providers/terraform-routeros/routeros/latest/docs/resources/interface_bridge_port
# =================================================================================================
resource "routeros_interface_bridge_port" "bond_ports" {
  for_each = {
    for k, v in var.bond_interfaces : k => v
  }

  bridge    = routeros_interface_bridge.bridge.name
  interface = each.key
  comment   = each.value.comment != null ? each.value.comment : ""

  # Set the PVID to the untagged VLAN ID so ingress untagged frames are
  # assigned to the correct VLAN. Defaults to VLAN 1 if no untagged VLAN is set.
  pvid = (each.value.untagged != null && each.value.untagged != "") ? (
    [for k, v in var.vlans : v.vlan_id if v.name == each.value.untagged][0]
  ) : 1
}