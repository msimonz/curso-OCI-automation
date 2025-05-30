# VCN
resource "oci_core_virtual_network" "msimonz-vcn" {
  cidr_block     = var.VCN-CIDR
  dns_label      = "msimonzvcn"
  compartment_id = var.compartment_ocid
  display_name   = "msimonzvcn"
}

# DHCP Options
resource "oci_core_dhcp_options" "msimonz-DhcpOptions1" {
  compartment_id = var.compartment_ocid
  vcn_id         = oci_core_virtual_network.msimonz-vcn.id
  display_name   = "msimonz-DHCPOptions1"

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
resource "oci_core_internet_gateway" "msimonz-InternetGateway" {
  compartment_id = var.compartment_ocid
  display_name   = "msimonz-InternetGateway"
  vcn_id         = oci_core_virtual_network.msimonz-vcn.id
}

# Route Table
resource "oci_core_route_table" "msimonz-RouteTableViaIGW" {
  compartment_id = var.compartment_ocid
  vcn_id         = oci_core_virtual_network.msimonz-vcn.id
  display_name   = "msimonz-RouteTableViaIGW"
  route_rules {
    destination       = "0.0.0.0/0"
    destination_type  = "CIDR_BLOCK"
    network_entity_id = oci_core_internet_gateway.msimonz-InternetGateway.id
  }
}

# Security List
resource "oci_core_security_list" "msimonz-SecurityList" {
  compartment_id = var.compartment_ocid
  display_name   = "msimonz-SecurityList"
  vcn_id         = oci_core_virtual_network.msimonz-vcn.id

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
resource "oci_core_subnet" "msimonz-WebSubnet" {
  cidr_block        = var.Subnet-CIDR
  display_name      = "msimonz-WebSubnet"
  dns_label         = "msimonzn1"
  compartment_id    = var.compartment_ocid
  vcn_id            = oci_core_virtual_network.msimonz-vcn.id
  route_table_id    = oci_core_route_table.msimonz-RouteTableViaIGW.id
  dhcp_options_id   = oci_core_dhcp_options.msimonz-DhcpOptions1.id
  security_list_ids = [oci_core_security_list.msimonz-SecurityList.id]
}
