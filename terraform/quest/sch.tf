
resource oci_sch_service_connector "audit_to_la" {
  compartment_id = var.compartment_ocid
  display_name = format("%s-mushop-sch", var.team_name)
  source {
    kind = "logging"
    log_sources {
      compartment_id = var.compartment_ocid
      log_group_id   = "_Audit"
    }
  }
  state = "ACTIVE"
  target {
    kind         = "loggingAnalytics"
    log_group_id = oci_log_analytics_log_analytics_log_group.la_group.id
  }
}

resource "oci_identity_policy" "sch_policy" {
  name           = "sch_policy"
  compartment_id = var.tenancy_ocid
  description = "コネクタハブのポリシー"
  statements = [
    "allow any-user to {LOG_ANALYTICS_LOG_GROUP_UPLOAD_LOGS} in compartment id ${oci_log_analytics_log_analytics_log_group.la_group.compartment_id} where all {request.principal.type = 'serviceconnector', target.loganalytics-log-group.id = '${oci_log_analytics_log_analytics_log_group.la_group.id}', request.principal.compartment.id = '${oci_sch_service_connector.audit_to_la.compartment_id}'}"
  ]

}