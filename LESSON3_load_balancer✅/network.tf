# VCN
resource "oci_core_virtual_network" "msimonzvcn" {
  cidr_block     = var.VCN-CIDR
  dns_label      = "msimonzdns"
  compartment_id = var.compartment_ocid
  display_name   = "msimonzvcn"
}

# DHCP Options
resource "oci_core_dhcp_options" "msimonzDhcpOptions1" {
  compartment_id = var.compartment_ocid
  vcn_id         = oci_core_virtual_network.msimonzvcn.id
  display_name   = "msimonzDHCPOptions1"

  options {
    type        = "DomainNameServer"
    server_type = "VcnLocalPlusInternet"
  }

  options {
    type                = "SearchDomain"
    search_domain_names = ["msimonz.com"]
  }
}

# Internet Gateway
resource "oci_core_internet_gateway" "msimonzInternetGateway" {
  compartment_id = var.compartment_ocid
  display_name   = "msimonzInternetGateway"
  vcn_id         = oci_core_virtual_network.msimonzvcn.id
}

# Route Table
resource "oci_core_route_table" "msimonzRouteTableViaIGW" {
  compartment_id = var.compartment_ocid
  vcn_id         = oci_core_virtual_network.msimonzvcn.id
  display_name   = "msimonzRouteTableViaIGW"
  route_rules {
    destination       = "0.0.0.0/0"
    destination_type  = "CIDR_BLOCK"
    network_entity_id = oci_core_internet_gateway.msimonzInternetGateway.id
  }
}

# Security List
resource "oci_core_security_list" "msimonzSecurityList" {
  compartment_id = var.compartment_ocid
  display_name   = "msimonSecurityList"
  vcn_id         = oci_core_virtual_network.msimonzvcn.id

  egress_security_rules {
    protocol    = "6"
    destination = "0.0.0.0/0"
  }

  dynamic "ingress_security_rules" {
    for_each = var.service_ports
    content {
      protocol = "6"
      source   = "0.0.0.0/0"
      tcp_options {
        max = ingress_security_rules.value
        min = ingress_security_rules.value
      }
    }
  }

  ingress_security_rules {
    protocol = "6"
    source   = var.VCN-CIDR
  }
}

# Subnet
resource "oci_core_subnet" "msimonzWebSubnet" {
  cidr_block        = var.Subnet-CIDR
  display_name      = "msimonzWebSubnet"
  dns_label         = "msimonznN1"
  compartment_id    = var.compartment_ocid
  vcn_id            = oci_core_virtual_network.msimonzvcn.id
  route_table_id    = oci_core_route_table.msimonzRouteTableViaIGW.id
  dhcp_options_id   = oci_core_dhcp_options.msimonzDhcpOptions1.id
  security_list_ids = [oci_core_security_list.msimonzSecurityList.id]
  lifecycle {
    prevent_destroy = false  # Para permitir la destrucción de la subnet
  }
}
