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

# Security List for HTTP/HTTPS/SSH access for Webservers 
resource "oci_core_security_list" "msimonzWebserversSecurityList" {
  compartment_id = var.compartment_ocid
  display_name   = "msimonzWebserversSecurityList"
  vcn_id         = oci_core_virtual_network.msimonzvcn.id

  egress_security_rules {
    protocol    = "6"
    destination = "0.0.0.0/0"
  }

  dynamic "ingress_security_rules" {
    for_each = var.ssh_ports
    content {
      protocol = "6"
      source   = var.BastionSubnet-CIDR # Allow traffic only from Bastion Subnet
      tcp_options {
        max = ingress_security_rules.value
        min = ingress_security_rules.value
      }
    }
  }

  dynamic "ingress_security_rules" {
    for_each = var.webservice_ports
    content {
      protocol = "6"
      source   = var.LBSubnet-CIDR # Allow traffic only from the Load Balancer Subnet
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


# Security List for SQLNet for DBSystem
resource "oci_core_security_list" "msimonzSQLNetSecurityList" {
  compartment_id = var.compartment_ocid
  display_name   = "msimonzSQLNetSecurityList"
  vcn_id         = oci_core_virtual_network.msimonzvcn.id

  egress_security_rules {
    protocol    = "6"
    destination = "0.0.0.0/0"
  }

  dynamic "ingress_security_rules" {
    for_each = var.sqlnet_ports
    content {
      protocol = "6"
      source   = var.PrivateSubnet-CIDR # Allow SQLNet traffic only from Webservers Subnet
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

# Security List for HTTP/HTTPS access for Load Balancer 
resource "oci_core_security_list" "msimonzLoadBalancerSecurityList" {
  compartment_id = var.compartment_ocid
  display_name   = "msimonzLoadBalancerSecurityList"
  vcn_id         = oci_core_virtual_network.msimonzvcn.id

  egress_security_rules {
    protocol    = "6"
    destination = "0.0.0.0/0"
  }

  dynamic "ingress_security_rules" {
    for_each = var.webservice_ports
    content {
      protocol = "6"
      source   = "0.0.0.0/0" # Allow traffic from the internet
      tcp_options {
        max = ingress_security_rules.value
        min = ingress_security_rules.value
      }
    }
  }
}


# Security List for SSH to Bastion
resource "oci_core_security_list" "msimonzBastionSecurityList" {
  compartment_id = var.compartment_ocid
  display_name   = "msimonzBastionSecurityList"
  vcn_id         = oci_core_virtual_network.msimonzvcn.id

  egress_security_rules {
    protocol    = "6"
    destination = "0.0.0.0/0"
  }

  dynamic "ingress_security_rules" {
    for_each = var.ssh_ports
    content {
      protocol = "6"
      source   = var.bastion_allowed_ip # Restrict to trusted IPs
      tcp_options {
        max = ingress_security_rules.value
        min = ingress_security_rules.value
      }
    }
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
  security_list_ids          = [oci_core_security_list.msimonzWebserversSecurityList.id]
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
  security_list_ids = [oci_core_security_list.msimonzLoadBalancerSecurityList.id]
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
  security_list_ids = [oci_core_security_list.msimonzBastionSecurityList.id]
}

# DBSystem Subnet (private)
resource "oci_core_subnet" "msimonzDBSubnet" {
  cidr_block                 = var.DBSystemSubnet-CIDR
  display_name               = "msimonzDBSubnet"
  dns_label                  = "msimonzN4"
  compartment_id             = var.compartment_ocid
  vcn_id                     = oci_core_virtual_network.msimonzvcn.id
  route_table_id             = oci_core_route_table.msimonzRouteTableViaNAT.id
  dhcp_options_id            = oci_core_dhcp_options.msimonzDhcpOptions1.id
  security_list_ids          = [oci_core_security_list.msimonzSQLNetSecurityList.id]
  prohibit_public_ip_on_vnic = true
}



