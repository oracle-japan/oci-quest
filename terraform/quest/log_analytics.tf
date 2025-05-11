# 一回有効化したら以降こいつがいるとエラーになるので、コメントアウトしておく
# resource "oci_log_analytics_namespace" "la_namespace" {
#   compartment_id = var.compartment_ocid
#   is_onboarded = true
#   namespace = "nrubtr8vonph"
# }

resource "oci_log_analytics_log_analytics_log_group" "la_group" {
  compartment_id = var.compartment_ocid
  display_name   = format("%s-la-log-group", var.team_name)
  namespace = "nrubtr8vonph"
  description    = "Log group for la logs"
}
