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

# Route Table for IGW
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

# NAT Gateway
resource "oci_core_nat_gateway" "msimonzNATGateway" {
  compartment_id = var.compartment_ocid
  display_name   = "msimonzNATGateway"
  vcn_id         = oci_core_virtual_network.msimonzvcn.id
}

# Route Table for NAT
resource "oci_core_route_table" "msimonzRouteTableViaNAT" {
  compartment_id = var.compartment_ocid
  vcn_id         = oci_core_virtual_network.msimonzvcn.id
  display_name   = "msimonzRouteTableViaNAT"
  route_rules {
    destination       = "0.0.0.0/0"
    destination_type  = "CIDR_BLOCK"
    network_entity_id = oci_core_nat_gateway.msimonzNATGateway.id
  }
}

# WebSubnet (private)
resource "oci_core_subnet" "msimonzWebSubnet" {
  cidr_block                 = var.PrivateSubnet-CIDR
  display_name               = "msimonzWebSubnet"
  dns_label                  = "msimonzN1"
  compartment_id             = var.compartment_ocid
  vcn_id                     = oci_core_virtual_network.msimonzvcn.id
  route_table_id             = oci_core_route_table.msimonzRouteTableViaNAT.id
  dhcp_options_id            = oci_core_dhcp_options.msimonzDhcpOptions1.id
  prohibit_public_ip_on_vnic = true
}

# LoadBalancer Subnet (public)
resource "oci_core_subnet" "msimonzLBSubnet" {
  cidr_block        = var.LBSubnet-CIDR
  display_name      = "msimonzLBSubnet"
  dns_label         = "msimonzN2"
  compartment_id    = var.compartment_ocid
  vcn_id            = oci_core_virtual_network.msimonzvcn.id
  route_table_id    = oci_core_route_table.msimonzRouteTableViaIGW.id
  dhcp_options_id   = oci_core_dhcp_options.msimonzDhcpOptions1.id
}

# Bastion Subnet (public)
resource "oci_core_subnet" "msimonzBastionSubnet" {
  cidr_block        = var.BastionSubnet-CIDR
  display_name      = "msimonzBastionSubnet"
  dns_label         = "msimonzN3"
  compartment_id    = var.compartment_ocid
  vcn_id            = oci_core_virtual_network.msimonzvcn.id
  route_table_id    = oci_core_route_table.msimonzRouteTableViaIGW.id
  dhcp_options_id   = oci_core_dhcp_options.msimonzDhcpOptions1.id
}




