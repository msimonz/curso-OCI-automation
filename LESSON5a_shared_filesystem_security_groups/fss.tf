# Mount Target

resource "oci_file_storage_mount_target" "FoggyKitchenMountTarget" {
  availability_domain = lookup(data.oci_identity_availability_domains.ADs.availability_domains[0], "name") 
  compartment_id      = oci_identity_compartment.FoggyKitchenCompartment.id
  subnet_id           = oci_core_subnet.FoggyKitchenFSSSubnet.id
  ip_address          = var.MountTargetIPAddress
  display_name        = "FoggyKitchenMountTarget"
  nsg_ids             = [oci_core_network_security_group.FoggyKitchenFSSSecurityGroup.id]
}

# Export Set

resource "oci_file_storage_export_set" "FoggyKitchenExportset" {
  mount_target_id = oci_file_storage_mount_target.FoggyKitchenMountTarget.id
  display_name    = "FoggyKitchenExportset"
}

# FileSystem

resource "oci_file_storage_file_system" "FoggyKitchenFilesystem" {
  availability_domain = lookup(data.oci_identity_availability_domains.ADs.availability_domains[0], "name") 
  compartment_id      = oci_identity_compartment.FoggyKitchenCompartment.id
  display_name        = "FoggyKitchenFilesystem"
}

# Export

resource "oci_file_storage_export" "FoggyKitchenExport" {
  export_set_id  = oci_file_storage_mount_target.FoggyKitchenMountTarget.export_set_id
  file_system_id = oci_file_storage_file_system.FoggyKitchenFilesystem.id
  path           = "/sharedfs"

  export_options {
    source                         = var.VCN-CIDR
    access                         = "READ_WRITE"
    identity_squash                = "NONE"
  }

}


