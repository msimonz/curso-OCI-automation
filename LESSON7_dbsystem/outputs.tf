# Bastion Instance Public IP
output "msimonzBastionServer_PublicIP" {
  value = [data.oci_core_vnic.msimonzBastionServer_VNIC1.public_ip_address]
}

# WebServer Instances Private IPs
output "msimonzWebserver_Private_IPs_Formatted" {
  value = {
    for i, ip in data.oci_core_vnic.msimonzWebserver_VNIC1[*].private_ip_address :
    oci_core_instance.msimonzWebserver[i].display_name => ip
  }
}

# Generated Private Key for WebServer Instance
output "generated_ssh_private_key" {
  value     = tls_private_key.public_private_key_pair.private_key_pem
  sensitive = true
}

# Load Balancer First Public IP
output "msimonzLoadBalancer_Public_IP" {
  value = oci_load_balancer.msimonzLoadBalancer.ip_address_details[0].ip_address
}

# DBServer Private IP
output "msimonzDBServer_PrivateIP" {
  value = [data.oci_core_vnic.msimonzDBSystem_VNIC1.private_ip_address]
}