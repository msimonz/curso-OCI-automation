# Public Load Balancer
resource "oci_load_balancer" "msimonzLoadBalancer" {
  shape = var.lb_shape

  dynamic "shape_details" {
    for_each = local.is_flexible_lb_shape ? [1] : []
    content {
      minimum_bandwidth_in_mbps = var.flex_lb_min_shape
      maximum_bandwidth_in_mbps = var.flex_lb_max_shape
    }
  }

  compartment_id = var.compartment_ocid
  subnet_ids = [
    oci_core_subnet.msimonzLBSubnet.id
  ]
  display_name = "msimonzPublicLoadBalancer"
  network_security_group_ids = [oci_core_network_security_group.msimonzLBSecurityGroup.id]
}

# LoadBalancer Listener
resource "oci_load_balancer_listener" "msimonzLoadBalancerListener" {
  load_balancer_id         = oci_load_balancer.msimonzLoadBalancer.id
  name                     = "msimonzLoadBalancerListener"
  default_backend_set_name = oci_load_balancer_backendset.msimonzLoadBalancerBackendset.name
  port                     = 80
  protocol                 = "HTTP"
}

# LoadBalancer Backendset
resource "oci_load_balancer_backendset" "msimonzLoadBalancerBackendset" {
  name             = "msimonzLBBackendset"
  load_balancer_id = oci_load_balancer.msimonzLoadBalancer.id
  policy           = "ROUND_ROBIN"

  health_checker {
    port                = "80"
    protocol            = "HTTP"
    response_body_regex = ".*"
    url_path            = "/shared/"
  }
}

# LoadBalanacer Backend for WebServer1 Instance
resource "oci_load_balancer_backend" "msimonzLoadBalancerBackend" {
  count            = var.ComputeCount
  load_balancer_id = oci_load_balancer.msimonzLoadBalancer.id
  backendset_name  = oci_load_balancer_backendset.msimonzLoadBalancerBackendset.name
  ip_address       = oci_core_instance.msimonzWebserver[count.index].private_ip
  port             = 80
  backup           = false
  drain            = false
  offline          = false
  weight           = 1
}

