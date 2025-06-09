locals {
  full_high_string = oci_database_autonomous_database.mushop_atp.connection_strings[0].high
  high_service_name = regex("/(.+)$", local.full_high_string)[0]
}



