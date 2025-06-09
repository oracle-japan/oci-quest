
# 一回有効化したら以降こいつがいるとエラーになるので、コメントアウトしておく
# resource "oci_log_analytics_namespace" "la_namespace" {
#   compartment_id = var.compartment_ocid # tenancy_ocidだった気がする
#   is_onboarded = true
#   namespace = local.namespace
# }

resource "oci_log_analytics_log_analytics_log_group" "la_group" {
  compartment_id = var.compartment_ocid
  display_name   = format("%s-la-log-group", var.team_name)
  namespace = local.namespace
  description    = "Log group for la logs"
}



resource oci_sch_service_connector "audit_to_la" {
  compartment_id = var.compartment_ocid
  display_name = format("%s-mushop-sch", var.team_name)
  source {
    kind = "logging"
    log_sources {
      compartment_id = var.tenancy_ocid
      log_group_id   = "_Audit"
    }
  }
  state = "ACTIVE"
  target {
    kind         = "loggingAnalytics"
    log_group_id = oci_log_analytics_log_analytics_log_group.la_group.id
  }

  depends_on = [oci_log_analytics_log_analytics_log_group.la_group]

}

resource "oci_identity_policy" "sch_policy" {
  name           = format("%s_sch_policy", var.team_name)
  compartment_id = var.tenancy_ocid
  description = "コネクタハブのポリシー"
  statements = [
    "allow any-user to {LOG_ANALYTICS_LOG_GROUP_UPLOAD_LOGS} in compartment id ${oci_log_analytics_log_analytics_log_group.la_group.compartment_id} where all {request.principal.type = 'serviceconnector', target.loganalytics-log-group.id = '${oci_log_analytics_log_analytics_log_group.la_group.id}', request.principal.compartment.id = '${oci_sch_service_connector.audit_to_la.compartment_id}'}"
  ]

}