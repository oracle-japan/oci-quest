data "oci_logging_log_groups" "test_log_groups" {
    #Required
    compartment_id = var.compartment_ocid

    #Optional
    display_name = "_Audit"
    # is_compartment_id_in_subtree = var.log_group_is_compartment_id_in_subtree
}



resource oci_sch_service_connector export_Audit-Connector {
  compartment_id = var.compartment_ocid
  defined_tags = {
  }
  #description = <<Optional value not found in discovery>>
  display_name = format("%s-mushop-sch", var.team_name)
  freeform_tags = {
  }
  source {
    #config_map = <<Optional value not found in discovery>>
    #cursor = <<Optional value not found in discovery>>
    kind = "logging"
    log_sources {
      compartment_id = var.compartment_ocid
      log_group_id   = "_Audit"
      #log_id = <<Optional value not found in discovery>>
    }
    #monitoring_sources = <<Optional value not found in discovery>>
    #plugin_name = <<Optional value not found in discovery>>
    #stream_id = <<Optional value not found in discovery>>
  }
  state = "ACTIVE"
  target {
    #batch_rollover_size_in_mbs = <<Optional value not found in discovery>>
    #batch_rollover_time_in_ms = <<Optional value not found in discovery>>
    #batch_size_in_kbs = <<Optional value not found in discovery>>
    #batch_size_in_num = <<Optional value not found in discovery>>
    #batch_time_in_sec = <<Optional value not found in discovery>>
    #bucket = <<Optional value not found in discovery>>
    #compartment_id = <<Optional value not found in discovery>>
    #dimensions = <<Optional value not found in discovery>>
    #enable_formatted_messaging = <<Optional value not found in discovery>>
    #function_id = <<Optional value not found in discovery>>
    kind         = "loggingAnalytics"
    log_group_id = "ocid1.loganalyticsloggroup.oc1.ap-sydney-1.amaaaaaassl65iqa2afplwnzbwhfissectgftlqfr5l65523aamc5le4bkmq"
    #log_source_identifier = <<Optional value not found in discovery>>
    #metric = <<Optional value not found in discovery>>
    #metric_namespace = <<Optional value not found in discovery>>
    #namespace = <<Optional value not found in discovery>>
    #object_name_prefix = <<Optional value not found in discovery>>
    #stream_id = <<Optional value not found in discovery>>
    #topic_id = <<Optional value not found in discovery>>
  }
}
