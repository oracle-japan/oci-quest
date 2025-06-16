resource "oci_database_autonomous_database" "mushop_atp" {
  compartment_id          = var.compartment_ocid
  display_name            = format("%s-mushop-db", "aaa")
  db_name                 = format("%spdb", "aaa")
  db_version              = "19c"
  db_workload             = "OLTP"
  compute_count           = 2
  compute_model           = "ECPU"
  data_storage_size_in_gb = 150
  admin_password          = var.database_password
  private_endpoint_label = ""
  whitelisted_ips = [
    "0.0.0.0/0",
  ]
}
