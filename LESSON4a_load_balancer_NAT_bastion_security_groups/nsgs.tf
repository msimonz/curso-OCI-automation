# Webservers NSG
resource "oci_core_network_security_group" "msimonzWebserverSecurityGroup" {
  compartment_id = var.compartment_ocid
  display_name   = "msimonzWebSecurityGroup"
  vcn_id         = oci_core_virtual_network.msimonzvcn.id
}

# Webserver NSG Egress Rules
resource "oci_core_network_security_group_security_rule" "msimonzWebserverSecurityEgressGroupRule" {
  network_security_group_id = oci_core_network_security_group.msimonzWebserverSecurityGroup.id
  direction                 = "EGRESS"
  protocol                  = "6"
  destination               = "0.0.0.0/0"
  destination_type          = "CIDR_BLOCK"
}

# Webserver NSG Ingress Rules
resource "oci_core_network_security_group_security_rule" "msimonzWebserverSecurityIngressGroupRules" {
  for_each = toset(var.webservice_ports)

  network_security_group_id = oci_core_network_security_group.msimonzWebserverSecurityGroup.id
  direction                 = "INGRESS"
  protocol                  = "6"
  source                    = var.LBSubnet-CIDR # Allow traffic only from the Load Balancer Subnet
  source_type               = "CIDR_BLOCK"
  tcp_options {
    destination_port_range {
      max = each.value
      min = each.value
    }
  }
}

# LoadBalancer NSG
resource "oci_core_network_security_group" "msimonzLBSecurityGroup" {
  compartment_id = var.compartment_ocid
  display_name   = "msimonzLBSecurityGroup"
  vcn_id         = oci_core_virtual_network.msimonzvcn.id
}

# LoadBalancer NSG Egress Rules
resource "oci_core_network_security_group_security_rule" "msimonzLBSecurityEgressGroupRule" {
  network_security_group_id = oci_core_network_security_group.msimonzLBSecurityGroup.id
  direction                 = "EGRESS"
  protocol                  = "6"
  destination               = "0.0.0.0/0"
  destination_type          = "CIDR_BLOCK"
}

# LoadBalancer NSG Ingress Rules
resource "oci_core_network_security_group_security_rule" "msimonzLBSecurityIngressGroupRules" {
  for_each = toset(var.webservice_ports)

  network_security_group_id = oci_core_network_security_group.msimonzLBSecurityGroup.id
  direction                 = "INGRESS"
  protocol                  = "6"
  source                    =  "0.0.0.0/0" # Allow traffic from the internet
  source_type               = "CIDR_BLOCK"
  tcp_options {
    destination_port_range {
      max = each.value
      min = each.value
    }
  }
}

# Bastion NSG
resource "oci_core_network_security_group" "msimonzBastionSecurityGroup" {
  compartment_id = var.compartment_ocid
  display_name   = "msimonzBastionSecurityGroup"
  vcn_id         = oci_core_virtual_network.msimonzvcn.id
}

# Bastion NSG Egress Rules
resource "oci_core_network_security_group_security_rule" "msimonzBastionSecurityEgressGroupRule" {
  network_security_group_id = oci_core_network_security_group.msimonzBastionSecurityGroup.id
  direction                 = "EGRESS"
  protocol                  = "6"
  destination               = "0.0.0.0/0"
  destination_type          = "CIDR_BLOCK"
}

# Bastion NSG Ingress Rules
resource "oci_core_network_security_group_security_rule" "msimonzBastionSecurityIngressGroupRules" {
  for_each = toset(var.ssh_ports)

  network_security_group_id = oci_core_network_security_group.msimonzBastionSecurityGroup.id
  direction                 = "INGRESS"
  protocol                  = "6"
  source                    = var.bastion_allowed_ip # Restrict to trusted IPs
  source_type               = "CIDR_BLOCK"
  tcp_options {
    destination_port_range {
      max = each.value
      min = each.value
    }
  }
}

