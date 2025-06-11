#resource "oci_identity_compartment" "msimonzCompartment" {
#  provider = oci.homeregion
#  name = "msimonzCompartment"
#  description = "msimonz Compartment"
#  compartment_id = var.compartment_ocid
#  
#  provisioner "local-exec" {
#    command = "sleep 60"
#  }
#}
