data "oci_log_analytics_namespaces" "default" {
  compartment_id = var.tenancy_ocid
}

locals {
  log_analytics_namespace = data.oci_log_analytics_namespaces.default.namespaces[0].name
}

resource "oci_log_analytics_namespace" "test_namespace" {
    #Required
    compartment_id = var.tenancy_ocid
    is_onboarded = true
    namespace = local.log_analytics_namespace
}

resource "oci_log_analytics_log_analytics_log_group" "la_group" {
  compartment_id = var.compartment_ocid
  display_name   = "example-log-group"
  namespace = local.log_analytics_namespace
  description    = "Log group for application logs"
}
