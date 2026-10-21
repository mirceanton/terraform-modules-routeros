mock_provider "routeros" {}

run "dynamic_pool_by_default" {
  command = plan

  variables {
    interface = "vlan-test"
    address   = "10.66.66.1/24"
    network   = "10.66.66.0/24"
    dhcp_pool = ["10.66.66.100-10.66.66.200"]
  }

  assert {
    condition     = length(routeros_ip_pool.this) == 1 && routeros_ip_dhcp_server.this.address_pool == "vlan-test-dhcp-pool"
    error_message = "Default mode must create and use the dynamic DHCP pool."
  }
}

run "static_only_without_pool" {
  command = plan

  variables {
    interface   = "vlan-dmz"
    address     = "10.66.66.1/24"
    network     = "10.66.66.0/24"
    static_only = true
    static_leases = {
      "10.66.66.11" = { name = "node-1", mac = "AA:BB:CC:DD:EE:01" }
    }
  }

  assert {
    condition     = length(routeros_ip_pool.this) == 0 && routeros_ip_dhcp_server.this.address_pool == "static-only" && output.pool_name == null
    error_message = "Static-only mode must skip the pool and configure static-only DHCP."
  }

  assert {
    condition     = length(routeros_ip_dhcp_server_lease.this) == 1
    error_message = "Static leases must still be created in static-only mode."
  }
}

run "dynamic_requires_pool" {
  command = plan

  variables {
    interface = "vlan-test"
    address   = "10.66.66.1/24"
    network   = "10.66.66.0/24"
  }

  expect_failures = [var.dhcp_pool]
}

run "static_only_rejects_dynamic_pool" {
  command = plan

  variables {
    interface   = "vlan-dmz"
    address     = "10.66.66.1/24"
    network     = "10.66.66.0/24"
    static_only = true
    dhcp_pool   = ["10.66.66.100-10.66.66.200"]
  }

  expect_failures = [var.dhcp_pool]
}
