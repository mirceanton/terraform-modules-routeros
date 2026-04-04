# =================================================================================================
# Bridge Interfaces
# https://registry.terraform.io/providers/terraform-routeros/routeros/latest/docs/resources/interface_bridge
# =================================================================================================
resource "routeros_interface_bridge" "bridge" {
  name           = var.bridge_name
  comment        = var.bridge_comment
  vlan_filtering = var.bridge_vlan_filtering
  mtu            = var.bridge_mtu
}


# =================================================================================================
# Bridge Ports
# Adds ethernet interfaces as bridge members. The PVID is set to the untagged VLAN's ID
# when specified, allowing incoming untagged frames to be classified into the correct VLAN.
# https://registry.terraform.io/providers/terraform-routeros/routeros/latest/docs/resources/interface_bridge_port
# =================================================================================================
resource "routeros_interface_bridge_port" "ethernet_ports" {
  for_each = {
    for k, v in var.ethernet_interfaces : k => v
    if v.bridge_port != false
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