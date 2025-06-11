# Dictionary Locals
locals {
  compute_flexible_shapes = [
    "VM.Standard.E3.Flex",
    "VM.Standard.E4.Flex",
    "VM.Standard.A1.Flex",
    "VM.Optimized3.Flex"
  ]
  is_flexible_shape = contains(local.compute_flexible_shapes, var.Shape)
  is_flexible_lb_shape = var.lb_shape == "flexible" ? true : false
  default_availability_domain = lookup(data.oci_identity_availability_domains.ADs.availability_domains[0], "name", "")
}
