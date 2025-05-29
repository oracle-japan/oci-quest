
resource oci_sch_service_connector "audit_to_la" {
  for_each = local.team_compartment_ocids

  compartment_id = each.value
  display_name = format("%s-mushop-sch", each.key)
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
    log_group_id = oci_log_analytics_log_analytics_log_group.la_group[each.key].id
  }

  depends_on = [oci_log_analytics_log_analytics_log_group.la_group]

}

resource "oci_identity_policy" "sch_policy" {
  for_each = local.team_compartment_ocids

  name           = format("%s_sch_policy", each.key)
  compartment_id = var.tenancy_ocid
  description = "コネクタハブのポリシー"
  statements = [
    "allow any-user to {LOG_ANALYTICS_LOG_GROUP_UPLOAD_LOGS} in compartment id ${oci_log_analytics_log_analytics_log_group.la_group[each.key].compartment_id} where all {request.principal.type = 'serviceconnector', target.loganalytics-log-group.id = '${oci_log_analytics_log_analytics_log_group.la_group[each.key].id}', request.principal.compartment.id = '${oci_sch_service_connector.audit_to_la[each.key].compartment_id}'}"
  ]

}