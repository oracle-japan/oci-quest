
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
