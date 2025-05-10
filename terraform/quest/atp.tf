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
  subnet_id               = oci_core_subnet.mushop_db_subnet.id
  /* ↓↓↓　SLからNSGの変更に伴い追加 by Masataka Marukawa ↓↓↓ */  
  nsg_ids = [
    oci_core_network_security_group.mushop_db_network_security_group.id
  ]
  /* ↑↑↑ SLからNSGの変更に伴い追加 by Masataka Marukawa　↑↑↑ */
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
        password_secret_id = oci_vault_secret.mushop_atp_admin_password.id
        role               = "NORMAL"
        #ssl_secret_id      = oci_vault_secret.test_secret.id
        user_name = "ADMIN"
      }
      connection_string {

        #Optional
        connection_type = "BASIC"
        port            = "1521"
        protocol        = "TCPS"
        service = "g67cd4bfb36ef53_adminpdb_high.adb.oraclecloud.com" #format("%s_high", oci_database_autonomous_database.mushop_atp.db_name)

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
  subnet_id      = oci_core_subnet.mushop_db_subnet.id
}



resource "oci_vault_secret" "mushop_atp_admin_password" {
  compartment_id = var.compartment_ocid
  secret_name    = "atp_admin_password"
  vault_id       = oci_kms_vault.mushop_vault.id
  key_id         = oci_kms_key.mushop_key.id

  secret_content {
    content_type = "BASE64"
    content      = base64encode(var.database_password)
  }

  description = "ATP用のADMINパスワード"
}
