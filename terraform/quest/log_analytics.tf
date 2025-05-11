resource "oci_log_analytics_namespace" "test_namespace" {
    #Required
    compartment_id = var.tenancy_ocid
    is_onboarded = true
    namespace = "ociquestkddi"
}

resource "oci_log_analytics_log_analytics_log_group" "la_group" {
  compartment_id = var.compartment_ocid
  display_name   = "example-log-group"
  namespace = "ociquestkddi"  # 例: "frankfurtnamespace"
  description    = "Log group for application logs"
}
