data "oci_objectstorage_namespace" "ns" {

    #Optional
    compartment_id = var.compartment_ocid
}

# 一回有効化したら以降こいつがいるとエラーになるので、コメントアウトしておく
# resource "oci_log_analytics_namespace" "la_namespace" {
#   compartment_id = var.compartment_ocid
#   is_onboarded = true
#   namespace = data.oci_objectstorage_namespace.ns.namespace
# }

resource "oci_log_analytics_log_analytics_log_group" "la_group" {
  for_each = local.team_compartment_ocids

  compartment_id = each.value
  display_name   = format("%s-la-log-group", each.key)
  namespace = data.oci_objectstorage_namespace.ns.namespace
  description    = "Log group for la logs"
}
