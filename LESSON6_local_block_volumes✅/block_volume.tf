# Block Volume
resource "oci_core_volume" "msimonzWebserverBlockVolume" {
  count               = var.ComputeCount
  availability_domain = var.availability_domain_name == "" ? local.default_availability_domain : var.availability_domain_name
  compartment_id      = var.compartment_ocid
  display_name        = "msimonzWebserver${count.index + 1} BlockVolume"
  size_in_gbs         = var.volume_size_in_gbs
  vpus_per_gb         = var.vpus_per_gb
}

# Attachment of Block Volume to Webserver
resource "oci_core_volume_attachment" "msimonzWebserverBlockVolume_attach" {
  count           = var.ComputeCount
  attachment_type = "iscsi"
  instance_id     = oci_core_instance.msimonzWebserver[count.index].id
  volume_id       = oci_core_volume.msimonzWebserverBlockVolume[count.index].id
}

