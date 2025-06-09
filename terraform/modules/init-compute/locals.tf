# data "oci_database_autonomous_databases" "mushop_atps" {
#   compartment_id = var.compartment_ocid
# }

# data "oci_database_autonomous_database" "mushop_atp" {
#   autonomous_database_id = data.oci_database_autonomous_databases.mushop_atps.autonomous_databases[0].id
# }

# data "oci_core_vcns" "all_vcns" {
#   compartment_id = var.compartment_ocid
# }

# data "oci_core_subnets" "all_subnets" {
#   compartment_id = var.compartment_ocid
#   vcn_id         = local.vcn_id
# }

# data "oci_core_network_security_groups" "all_nsgs" {
#   compartment_id = var.compartment_ocid
#   vcn_id         = local.vcn_id
# }

data "oci_identity_availability_domain" "ad" {
  compartment_id = var.compartment_ocid
  ad_number      = 1
}

data "oci_core_images" "mushop_images" {
  compartment_id           = var.compartment_ocid
  operating_system         = "Oracle Linux"
  operating_system_version = "7.9"
  shape                    = local.shape
  sort_by                  = "TIMECREATED"
  sort_order               = "DESC"
}

data "cloudinit_config" "mushop" {
  gzip          = true
  base64_encode = true

  part {
    filename     = "cloud-config.yaml"
    content_type = "text/cloud-config"
    content      = local.cloud_init
  }
}

locals {
  ad              = data.oci_identity_availability_domain.ad.name
  shape           = "VM.Standard.E5.Flex"
  image           = data.oci_core_images.mushop_images.images[0].id
  init_db_template = templatefile("${path.module}/scripts/init_db.template.sh",{
      oracle_client_version   = "19.10"
      db_name = var.db_name
      atp_pw                  = var.database_password
      mushop_media_visibility = true
      wallet_par              = "https://objectstorage.${var.region}.oraclecloud.com${var.wallet_par_uri}"
    })
  sql_performance = file("${path.module}/scripts/sql_performance.sql")
  catalogue_sql_template = templatefile("${path.module}/scripts/catalogue.template.sql", {
   catalogue_password = var.database_password
  })
  cloud_init = templatefile("${path.module}/scripts/cloud-config.template.yaml",
      {
        init_db_sh_content     = base64gzip(local.init_db_template)
        sql_performance_content = base64gzip(local.sql_performance)
        catalogue_sql_template_content = base64gzip(local.catalogue_sql_template)
        db_name                = var.db_name
        public_key             = var.public_key
      })
}