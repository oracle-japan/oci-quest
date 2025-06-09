output "mushop_db_subnet_ocid" {
  description = "DB subnet OCIDs"
  value = oci_core_subnet.mushop_db_subnet.id
}

output "mushop_app_subnet_ocid" {
  description = "App subnet OCIDs"
  value = oci_core_subnet.mushop_app_subnet.id
}

output "mushop_lb_subnet_ocid" {
  description = "LB subnet OCIDs"
  value = oci_core_subnet.mushop_lb_subnet.id
}

output "mushop_db_nsg_ocid" {
  description = "DB NSG OCIDs"
  value = oci_core_network_security_group.mushop_db_network_security_group.id
}

output "mushop_app_nsg_ocid" {
  description = "App NSG OCIDs"
  value = oci_core_network_security_group.mushop_app_network_security_group.id
}
