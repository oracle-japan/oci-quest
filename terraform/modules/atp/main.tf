# resource "oci_database_autonomous_database" "mushop_atp" {
#   compartment_id          = var.compartment_ocid
#   display_name            = format("%s-mushop-db", var.team_name)
#   db_name                 = format("%spdb", var.team_name)
#   db_version              = "19c"
#   db_workload             = "OLTP"
#   compute_count           = 2
#   compute_model           = "ECPU"
#   data_storage_size_in_gb = 150
#   admin_password          = var.database_password
#   subnet_id               = var.subnet_ocid
#   nsg_ids = [
#     var.nsg_ocid
#   ]
# }

resource "oci_database_autonomous_database" "mushop_atp" {
  compartment_id          = var.compartment_ocid
  display_name            = format("%s-mushop-db", var.team_name)
  db_name                 = format("%spdb", var.team_name)
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
  # nsg_ids = [
  #   var.nsg_ocid
  # ]
}

resource "oci_database_autonomous_database_wallet" "mushop_wallet" {
  autonomous_database_id = oci_database_autonomous_database.mushop_atp.id
  password               = var.database_password
  generate_type          = "SINGLE"
  base64_encode_content  = true
}

resource "oci_database_management_autonomous_database_autonomous_database_dbm_features_management" "mushop_dbm" {
  #Required
  autonomous_database_id                 = oci_database_autonomous_database.mushop_atp.id
  enable_autonomous_database_dbm_feature = true

  #Optional
  feature_details {
    #Required
    feature = "DIAGNOSTICS_AND_MANAGEMENT"
    #Optional
    database_connection_details {

      #Optional
      connection_credentials {

        #Optional
        credential_name    = "mushop_atp_dbm_credential"
        credential_type    = "DETAILS"
        password_secret_id = var.database_password_secret_id
        role               = "NORMAL"
        #ssl_secret_id      = oci_vault_secret.test_secret.id
        user_name = "ADMIN"
      }
      connection_string {

        #Optional
        connection_type = "BASIC"
        port            = "1521"
        protocol        = "TCPS"
        service = local.high_service_name

      }
    }
    connector_details {

      #Optional
      connector_type       = "PE"
      private_end_point_id = oci_database_management_db_management_private_endpoint.mushop_dbm_private_endpoint.id
    }
  }
}

resource "oci_database_management_db_management_private_endpoint" "mushop_dbm_private_endpoint" {
  #Required
  compartment_id = var.compartment_ocid
  name           = "dbm_private_endpoint"
  subnet_id      = var.subnet_ocid
}