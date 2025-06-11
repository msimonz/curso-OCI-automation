# DBSystem
resource "oci_database_db_system" "msimonzDBSystem" {
  availability_domain = var.availability_domain_name == "" ? local.default_availability_domain : var.availability_domain_name
  compartment_id      = var.compartment_ocid
  cpu_core_count      = var.CPUCoreCount
  database_edition    = var.DBEdition
  db_home {
    database {
      admin_password = var.DBAdminPassword
      db_name        = var.DBName
      character_set  = var.CharacterSet
      ncharacter_set = var.NCharacterSet
      db_workload    = var.DBWorkload
      pdb_name       = var.PDBName
    }
    db_version   = var.DBVersion
    display_name = var.DBDisplayName
  }
  disk_redundancy         = var.DBDiskRedundancy
  shape                   = var.DBNodeShape
  subnet_id               = oci_core_subnet.msimonzDBSubnet.id
  ssh_public_keys         = [tls_private_key.public_private_key_pair.public_key_openssh]
  display_name            = var.DBSystemDisplayName
  domain                  = var.DBNodeDomainName
  hostname                = var.DBNodeHostName
  data_storage_percentage = "40"
  data_storage_size_in_gb = var.DBDataStorageSizeInGB
  license_model           = var.DBLicenseModel
  node_count              = var.DBNodeCount
}
