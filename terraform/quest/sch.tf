data "oci_logging_log_groups" "audit_log_group" {
    compartment_id = var.compartment_ocid
    display_name = "_Audit"
    is_compartment_id_in_subtree = true
}

locals {
  audit_log_group_id = data.oci_logging_log_groups.audit_log_group.log_groups[0].id
}

resource oci_sch_service_connector "audit_to_la" {
  compartment_id = var.compartment_ocid
  display_name = format("%s-mushop-sch", var.team_name)
  source {
    kind = "logging"
    log_sources {
      compartment_id = var.compartment_ocid
      log_group_id   = local.audit_log_group_id
    }
  }
  state = "ACTIVE"
  target {
    kind         = "loggingAnalytics"
    log_group_id = oci_log_analytics_log_analytics_log_group.la_group.id
  }
}
