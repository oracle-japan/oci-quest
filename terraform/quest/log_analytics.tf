resource "oci_log_analytics_namespace" "la_namespace" {
  compartment_id = var.tenancy_ocid
  is_onboarded = true
  namespace = format("%s-la", var.team_name)
}

resource "oci_log_analytics_log_analytics_log_group" "la_group" {
  compartment_id = var.compartment_ocid
  display_name   = "example-log-group"
  namespace = oci_log_analytics_namespace.la_namespace.namespace
  description    = "Log group for application logs"
}
