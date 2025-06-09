output "mushop_wallet" {
  description = "List of Autonomous Database wallet contents for each team"
  value = oci_database_autonomous_database_wallet.mushop_wallet.content
}

output "db_name" {
  description = "Map from compartment OCID to Autonomous Database name"
  value = oci_database_autonomous_database.mushop_atp.db_name
}