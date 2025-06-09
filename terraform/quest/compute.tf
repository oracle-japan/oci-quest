data "oci_database_autonomous_databases" "mushop_atps" {
  compartment_id = var.compartment_ocid
}

data "oci_database_autonomous_database" "mushop_atp" {
  autonomous_database_id = data.oci_database_autonomous_databases.mushop_atps.autonomous_databases[0].id
}

data "oci_core_vcns" "all_vcns" {
  compartment_id = var.compartment_ocid
}

data "oci_core_subnets" "all_subnets" {
  compartment_id = var.compartment_ocid
  vcn_id         = local.vcn_id
}

data "oci_core_network_security_groups" "all_nsgs" {
  compartment_id = var.compartment_ocid
  vcn_id         = local.vcn_id
}





data "oci_identity_availability_domain" "ad" {
  compartment_id = var.compartment_ocid
  ad_number      = 1
}

data "oci_core_images" "mushop_images" {
  compartment_id           = var.compartment_ocid
  operating_system         = "Oracle Linux"
  operating_system_version = "7.9"
  shape                    = local.shape
  sort_by                  = "TIMECREATED"
  sort_order               = "DESC"
}

data "cloudinit_config" "mushop" {
  gzip          = true
  base64_encode = true

  part {
    filename     = "cloud-config.yaml"
    content_type = "text/cloud-config"
    content      = local.cloud_init
  }
}

data "oci_identity_compartment" "team_compartment" {
  id = var.compartment_ocid
}

resource "oci_core_instance" "mushop_bastion" {
  availability_domain = local.ad
  compartment_id      = var.compartment_ocid
  display_name        = format("%s-mushop-bastion", data.oci_identity_compartment.team_compartment.name)
  shape               = local.shape
  shape_config {
    ocpus         = 1
    memory_in_gbs = 6
  }
  source_details {
    source_type = "image"
    source_id   = local.image
  }
  create_vnic_details {
    subnet_id        = local.lb_subnet.id
    display_name     = "primaryvnic"
    assign_public_ip = true
    hostname_label   = format("%s-mushop-bastion", data.oci_identity_compartment.team_compartment.name)
    /* ↓↓↓　SLからNSGの変更に伴い追加 by Masataka Marukawa ↓↓↓ */
    nsg_ids = [
      local.bastion_nsg.id
    ]
    /* ↑↑↑ SLからNSGの変更に伴い追加 by Masataka Marukawa　↑↑↑ */
  }
  metadata = {
    ssh_authorized_keys = var.public_key
    user_data           = data.cloudinit_config.bastion.rendered
  }
  /* ↓↓↓　OCI Quest 設問 : コンピュート・インスタンスのメトリック情報が確認できない のためにOracle Cloud Agentのモニタリング・プラグインを有効化 by mmarukaw ↓↓↓ */
  agent_config {
    are_all_plugins_disabled = false
    is_monitoring_disabled = false
    plugins_config {
      desired_state = "ENABLED"
      name = "Compute Instance Monitoring"
    }
  }
  /* ↑↑↑　OCI Quest 設問 : コンピュート・インスタンスのメトリック情報が確認できない のためにOracle Cloud Agentのモニタリング・プラグインを有効化 by mmarukaw ↑↑↑ */
}

resource "oci_core_instance" "mushop_app_instance" {
  availability_domain = local.ad
  compartment_id      = var.compartment_ocid
  display_name        = format("%s-mushop-app", data.oci_identity_compartment.team_compartment.name)
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
    subnet_id        = local.app_subnet.id
    display_name     = "primaryvnic"
    assign_public_ip = false
    hostname_label   = format("%s-mushop-app", data.oci_identity_compartment.team_compartment.name)
    /* ↓↓↓　SLからNSGの変更に伴い追加 by Masataka Marukawa ↓↓↓ */
    nsg_ids = [
      local.app_nsg.id
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

resource "tls_private_key" "bastion_ssh_key" {
  algorithm = "RSA"
  rsa_bits  = 2048
}

data "cloudinit_config" "bastion" {
  gzip          = true
  base64_encode = true

  part {
    filename     = "bastion-init.sh"
    content_type = "text/x-shellscript"
    content      = <<-EOF
      #!/bin/bash
      mkdir -p /home/opc/.ssh
      echo "${tls_private_key.bastion_ssh_key.private_key_pem}" > /home/opc/.ssh/id_rsa
      echo "${tls_private_key.bastion_ssh_key.public_key_openssh}" > /home/opc/.ssh/id_rsa.pub
      chown -R opc:opc /home/opc/.ssh
      chmod 700 /home/opc/.ssh
      chmod 600 /home/opc/.ssh/id_rsa
      chmod 644 /home/opc/.ssh/id_rsa.pub
    EOF
  }
}
