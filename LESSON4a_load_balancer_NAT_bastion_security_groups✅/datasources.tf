# Home Region Subscription DataSource
data "oci_identity_region_subscriptions" "home_region_subscriptions" {
  tenancy_id = var.tenancy_ocid

  filter {
    name   = "is_home_region"
    values = [true]
  }
}

# ADs DataSource
data "oci_identity_availability_domains" "ADs" {
  compartment_id = var.tenancy_ocid
}

# Webserver Images DataSource
data "oci_core_images" "WebserverImage" {
  compartment_id           = var.compartment_ocid
  operating_system         = var.instance_os
  operating_system_version = var.linux_os_version
  shape                    = var.WebserverShape

  filter {
    name   = "display_name"
    values = ["^.*Oracle[^G]*$"]
    regex  = true
  }
}

# Bastion Images DataSource
data "oci_core_images" "BastionImage" {
  compartment_id           = var.compartment_ocid
  operating_system         = var.instance_os
  operating_system_version = var.linux_os_version
  shape                    = var.BastionShape

  filter {
    name   = "display_name"
    values = ["^.*Oracle[^G]*$"]
    regex  = true
  }
}

# Bastion Compute VNIC Attachment DataSource
data "oci_core_vnic_attachments" "msimonzBastionServer_VNIC1_attach" {
  availability_domain = var.availability_domain_name == "" ? local.default_availability_domain : var.availability_domain_name
  compartment_id      = var.compartment_ocid
  instance_id         = oci_core_instance.msimonzBastionServer.id
}

# Bastion Compute VNIC DataSource
data "oci_core_vnic" "msimonzBastionServer_VNIC1" {
  vnic_id = data.oci_core_vnic_attachments.msimonzBastionServer_VNIC1_attach.vnic_attachments.0.vnic_id
}

# WebServers Compute VNIC Attachment DataSource
data "oci_core_vnic_attachments" "msimonzWebserver_VNIC1_attach" {
  count               = var.ComputeCount
  availability_domain = var.availability_domain_name == "" ? local.default_availability_domain : var.availability_domain_name
  compartment_id      = var.compartment_ocid
  instance_id         = oci_core_instance.msimonzWebserver[count.index].id
}

# WebServers Compute VNIC DataSource
data "oci_core_vnic" "msimonzWebserver_VNIC1" {
  count   = var.ComputeCount
  vnic_id = data.oci_core_vnic_attachments.msimonzWebserver_VNIC1_attach[count.index].vnic_attachments.0.vnic_id
}
