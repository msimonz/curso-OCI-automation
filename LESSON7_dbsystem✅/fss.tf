# Mount Target

resource "oci_file_storage_mount_target" "msimonzMountTarget" {
  availability_domain = var.availability_domain_name == "" ? local.default_availability_domain : var.availability_domain_name
  compartment_id      = var.compartment_ocid
  subnet_id           = oci_core_subnet.msimonzWebSubnet.id
  ip_address          = var.MountTargetIPAddress
  display_name        = "msimonzMountTarget"
}

# Export Set

resource "oci_file_storage_export_set" "msimonzExportset" {
  mount_target_id = oci_file_storage_mount_target.msimonzMountTarget.id
  display_name    = "msimonzExportset"
}

# FileSystem

resource "oci_file_storage_file_system" "msimonzFilesystem" {
  availability_domain = var.availability_domain_name == "" ? local.default_availability_domain : var.availability_domain_name
  compartment_id      = var.compartment_ocid
  display_name        = "msimonzFilesystem"
}

# Export

resource "oci_file_storage_export" "msimonzExport" {
  export_set_id  = oci_file_storage_mount_target.msimonzMountTarget.export_set_id
  file_system_id = oci_file_storage_file_system.msimonzFilesystem.id
  path           = "/sharedfs"

  export_options {
    source                         = var.VCN-CIDR
    access                         = "READ_WRITE"
    identity_squash                = "NONE"
  }

}

