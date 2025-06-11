# WebServer Compute

resource "oci_core_instance" "msimonzWebserver" {
  count               = var.ComputeCount
  availability_domain = var.availability_domain_name == "" ? local.default_availability_domain : var.availability_domain_name
  compartment_id      = var.compartment_ocid
  display_name        = "msimonzWebServer${count.index + 1}"
  fault_domain        = "FAULT-DOMAIN-${(count.index % 3)+ 1}"
  shape               = var.WebserverShape
  dynamic "shape_config" {
    for_each = local.is_flexible_webserver_shape ? [1] : []
    content {
      memory_in_gbs = var.WebserverFlexShapeMemory
      ocpus         = var.WebserverFlexShapeOCPUS
    }
  }

  source_details {
    source_type = "image"
    source_id   = lookup(data.oci_core_images.WebserverImage.images[0], "id")
  }
  metadata = {
    ssh_authorized_keys = tls_private_key.public_private_key_pair.public_key_openssh
  }
  create_vnic_details {
    subnet_id        = oci_core_subnet.msimonzWebSubnet.id
    assign_public_ip = false
  }
}


# Bastion Compute

resource "oci_core_instance" "msimonzBastionServer" {
  availability_domain = var.availability_domain_name == "" ? local.default_availability_domain : var.availability_domain_name
  compartment_id      = var.compartment_ocid
  display_name        = "msimonzBastionServer"
  shape               = var.BastionShape
  dynamic "shape_config" {
    for_each = local.is_flexible_bastion_shape ? [1] : []
    content {
      memory_in_gbs = var.BastionFlexShapeMemory
      ocpus         = var.BastionFlexShapeOCPUS
    }
  }
  fault_domain = "FAULT-DOMAIN-1"
  source_details {
    source_type = "image"
    source_id   = lookup(data.oci_core_images.BastionImage.images[0], "id")
  }
  metadata = {
    ssh_authorized_keys = tls_private_key.public_private_key_pair.public_key_openssh
  }
  create_vnic_details {
    subnet_id        = oci_core_subnet.msimonzBastionSubnet.id
    assign_public_ip = true
  }
}
