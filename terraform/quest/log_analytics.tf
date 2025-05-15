data "oci_objectstorage_namespace" "ns" {

    #Optional
    compartment_id = var.compartment_ocid
}

# 一回有効化したら以降こいつがいるとエラーになるので、コメントアウトしておく
resource "oci_log_analytics_namespace" "la_namespace" {
  compartment_id = var.compartment_ocid
  is_onboarded = false
  namespace = data.oci_objectstorage_namespace.ns.namespace
}

resource "oci_log_analytics_log_analytics_log_group" "la_group" {
  compartment_id = var.compartment_ocid
  display_name   = format("%s-la-log-group", var.team_name)
  namespace = data.oci_objectstorage_namespace.ns.namespace
  description    = "Log group for la logs"
}
