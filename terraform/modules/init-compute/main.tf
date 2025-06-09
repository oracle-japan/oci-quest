resource "oci_core_instance" "mushop_init_instance" {
  availability_domain = local.ad
  compartment_id      = var.compartment_ocid
  display_name        = format("%s-mushop-db-init", var.team_name)
  shape               = local.shape
  shape_config {
    ocpus         = 1
    memory_in_gbs = 16
  }
  source_details {
    source_type = "image"
    source_id   = local.image
  }
  create_vnic_details {
    subnet_id        = var.subnet_ocid
    display_name     = "primaryvnic"
    assign_public_ip = false
    hostname_label   = format("%s-mushop-db-init", var.team_name)
    /* ↓↓↓　SLからNSGの変更に伴い追加 by Masataka Marukawa ↓↓↓ */
    nsg_ids = [
      var.nsg_ocid
    ]
    /* ↑↑↑ SLからNSGの変更に伴い追加 by Masataka Marukawa　↑↑↑ */
  }
  metadata = {
    user_data           = data.cloudinit_config.mushop.rendered
  }
  /* ↓↓↓　OCI Quest 設問 : コンピュート・インスタンスのメトリック情報が確認できない のためにOracle Cloud Agentのモニタリング・プラグインを無効化 by mmarukaw ↓↓↓ */
  agent_config {
    are_all_plugins_disabled = false
    is_monitoring_disabled = false
    plugins_config {
      desired_state = "DISABLED"
      name = "Compute Instance Monitoring"
    }
  }
}