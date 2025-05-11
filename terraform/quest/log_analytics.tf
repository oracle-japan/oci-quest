resource "oci_log_analytics_namespace" "la_namespace" {
  compartment_id = var.tenancy_ocid
  is_onboarded = true
  namespace = "nrubtr8vonph"
}

resource "oci_log_analytics_log_analytics_log_group" "la_group" {
  compartment_id = var.tenancy_ocid
  display_name   = "la-log-group"
  namespace = "nrubtr8vonph"
  description    = "Log group for la logs"
}
