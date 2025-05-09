data "oci_core_services" "all_services" {
  filter {
    name   = "name"
    values = ["All.*"]
    regex  = true
  }
}

locals {
  all_services = data.oci_core_services.all_services.services.0
  protocol = {
    all  = "all"
    icmp = "1"
    tcp  = "6"
  }
}

resource "oci_core_vcn" "mushop_vcn" {
  compartment_id = var.compartment_ocid
  cidr_block     = "10.0.0.0/16"
  display_name   = format("%s-mushop-vcn", var.team_name)
  dns_label      = "mushop"
}

resource "oci_core_internet_gateway" "mushop_internet_gateway" {
  compartment_id = var.compartment_ocid
  vcn_id         = oci_core_vcn.mushop_vcn.id
  display_name   = format("%s-mushop-internet-gateway", var.team_name)
  depends_on     = [oci_core_vcn.mushop_vcn]
}

resource "oci_core_nat_gateway" "mushop_nat_gateway" {
  compartment_id = var.compartment_ocid
  vcn_id         = oci_core_vcn.mushop_vcn.id
  display_name   = format("%s-mushop-nat-gateway", var.team_name)
  depends_on     = [oci_core_vcn.mushop_vcn]
}

resource "oci_core_service_gateway" "mushop_service_gateway" {
  compartment_id = var.compartment_ocid
  vcn_id         = oci_core_vcn.mushop_vcn.id
  display_name   = format("%s-mushop-service-gateway", var.team_name)
  services {
    service_id = local.all_services.id
  }
  depends_on = [oci_core_vcn.mushop_vcn]
}

resource "oci_core_route_table" "mushop_public_route_table" {
  compartment_id = var.compartment_ocid
  vcn_id         = oci_core_vcn.mushop_vcn.id
  display_name   = format("%s-mushop-public-route-table", var.team_name)
  route_rules {
    destination       = "0.0.0.0/0"
    destination_type  = "CIDR_BLOCK"
    network_entity_id = oci_core_internet_gateway.mushop_internet_gateway.id
  }
  depends_on = [oci_core_vcn.mushop_vcn]
}

resource "oci_core_route_table" "mushop_private_route_table" {
  compartment_id = var.compartment_ocid
  vcn_id         = oci_core_vcn.mushop_vcn.id
  display_name   = format("%s-mushop-private-route-table", var.team_name)
  # OCI Quest 設問 : コンピュート・インスタンスのメトリック情報が確認できない : サービス・ゲートウェイへのルート・ルールを削除 by Masataka Marukawa
  /*
  route_rules {
    destination       = local.all_services.cidr_block
    destination_type  = "SERVICE_CIDR_BLOCK"
    network_entity_id = oci_core_service_gateway.mushop_service_gateway.id
  }
  route_rules {
    destination       = "0.0.0.0/0"
    destination_type  = "CIDR_BLOCK"
    network_entity_id = oci_core_nat_gateway.mushop_nat_gateway.id
  }
  */
  depends_on = [oci_core_vcn.mushop_vcn]
}

/* ↓↓↓ bastionのNSG (SLからNSGの変更に伴い追加) by Masataka Marukawa ↓↓↓ */
resource "oci_core_network_security_group" "mushop_bastion_network_security_group" {
  compartment_id = var.compartment_ocid
  vcn_id         = oci_core_vcn.mushop_vcn.id
  display_name   = format("%s-mushop-bastion-network-security-group", var.team_name)
  depends_on = [oci_core_vcn.mushop_vcn]
}

resource "oci_core_network_security_group_security_rule" "mushop_bastion_network_security_group_ingress_ssh" {
  network_security_group_id = oci_core_network_security_group.mushop_bastion_network_security_group.id
  description               = "Allow SSH ingress"
  direction                 = "INGRESS"
  protocol                  = local.protocol.tcp
  source_type               = "CIDR_BLOCK"
  source                    = "0.0.0.0/0"
  tcp_options {
    destination_port_range {
      min = 22
      max = 22
    }
  }
  depends_on = [oci_core_network_security_group.mushop_lb_network_security_group]
}

resource "oci_core_network_security_group_security_rule" "mushop_bastion_network_security_group_egress_all" {
  network_security_group_id = oci_core_network_security_group.mushop_bastion_network_security_group.id
  description               = "Allow all egress"
  direction                 = "EGRESS"
  protocol                  = local.protocol.all
  destination_type          = "CIDR_BLOCK"
  destination               = "0.0.0.0/0"
  depends_on = [oci_core_network_security_group.mushop_bastion_network_security_group]
}
/* ↑↑↑ bastionのNSG (SLからNSGの変更に伴い追加) by Masataka Marukawa ↑↑↑ */

/* ↓↓↓ LBのNSG (SLからNSGの変更に伴い追加) by Masataka Marukawa ↓↓↓ */
resource "oci_core_network_security_group" "mushop_lb_network_security_group" {
  compartment_id = var.compartment_ocid
  vcn_id         = oci_core_vcn.mushop_vcn.id
  display_name   = format("%s-mushop-lb-network-security-group", var.team_name)
  depends_on = [oci_core_vcn.mushop_vcn]
}

/*　↓↓↓ OCI Quest 設問 : MuShop のトップページにアクセスできません のために、LBへのhttp/httpsのイングレスルールをコメントアウト by Masataka Marukawa　↓↓↓
resource "oci_core_network_security_group_security_rule" "mushop_lb_network_security_group_ingress_http" {
  network_security_group_id = oci_core_network_security_group.mushop_lb_network_security_group.id
  description               = "Allow HTTP ingress"
  direction                 = "INGRESS"
  protocol                  = local.protocol.tcp
  source_type               = "CIDR_BLOCK"
  source                    = "0.0.0.0/0"
  tcp_options {
    destination_port_range {
      min = 80
      max = 80
    }
  }
  depends_on = [oci_core_network_security_group.mushop_lb_network_security_group]
}

resource "oci_core_network_security_group_security_rule" "mushop_lb_network_security_group_ingress_https" {
  network_security_group_id = oci_core_network_security_group.mushop_lb_network_security_group.id
  description               = "Allow HTTPS ingress"
  direction                 = "INGRESS"
  protocol                  = local.protocol.tcp
  source_type               = "CIDR_BLOCK"
  source                    = "0.0.0.0/0"
  tcp_options {
    destination_port_range {
      min = 443
      max = 443
    }
  }
  depends_on = [oci_core_network_security_group.mushop_lb_network_security_group]
}
↑↑↑ OCI Quest 設問 : MuShop のトップページにアクセスできません のために、LBへのhttp/httpsのイングレスルールをコメントアウト by Masataka Marukawa　↑↑↑　*/

resource "oci_core_network_security_group_security_rule" "mushop_lb_network_security_group_egress_all" {
  network_security_group_id = oci_core_network_security_group.mushop_lb_network_security_group.id
  description               = "Allow all egress"
  direction                 = "EGRESS"
  protocol                  = local.protocol.all
  destination_type          = "CIDR_BLOCK"
  destination               = "0.0.0.0/0"
  depends_on = [oci_core_network_security_group.mushop_lb_network_security_group]
}
/* ↑↑↑ LBのNSG (SLからNSGの変更に伴い追加) by Masataka Marukawa ↑↑↑ */

/* ↓↓↓ AppのNSG (SLからNSGの変更に伴い追加) by Masataka Marukawa ↓↓↓ */
resource "oci_core_network_security_group" "mushop_app_network_security_group" {
  compartment_id = var.compartment_ocid
  vcn_id         = oci_core_vcn.mushop_vcn.id
  display_name   = format("%s-mushop-app-network-security-group", var.team_name)
  depends_on = [oci_core_vcn.mushop_vcn]
}

resource "oci_core_network_security_group_security_rule" "mushop_app_network_security_group_ingress_ssh_from_lb" {
  network_security_group_id = oci_core_network_security_group.mushop_app_network_security_group.id
  description               = "Allow SSH ingress from LB"
  direction                 = "INGRESS"
  protocol                  = local.protocol.tcp
  source_type               = "CIDR_BLOCK"
  source                    = "10.0.10.0/24"
  tcp_options {
    destination_port_range {
      min = 22
      max = 22
    }
  }
  depends_on = [oci_core_network_security_group.mushop_app_network_security_group]
}

resource "oci_core_network_security_group_security_rule" "mushop_app_network_security_group_ingress_http_from_lb" {
  network_security_group_id = oci_core_network_security_group.mushop_app_network_security_group.id
  description               = "Allow SSH ingress from LB"
  direction                 = "INGRESS"
  protocol                  = local.protocol.tcp
  source_type               = "CIDR_BLOCK"
  source                    = "10.0.10.0/24"
  tcp_options {
    destination_port_range {
      min = 80
      max = 80
    }
  }
  depends_on = [oci_core_network_security_group.mushop_app_network_security_group]
}

resource "oci_core_network_security_group_security_rule" "mushop_app_network_security_group_egress_all_to_osn" {
  network_security_group_id = oci_core_network_security_group.mushop_app_network_security_group.id
  description               = "Allow all egress to OSN"
  direction                 = "EGRESS"
  protocol                  = local.protocol.all
  destination_type          = "SERVICE_CIDR_BLOCK"
  destination               = local.all_services.cidr_block
  depends_on = [oci_core_network_security_group.mushop_app_network_security_group]
}

resource "oci_core_network_security_group_security_rule" "mushop_app_network_security_group_egress_1521_to_db" {
  network_security_group_id = oci_core_network_security_group.mushop_app_network_security_group.id
  description               = "Allow Oracle*Net egress to DB"
  direction                 = "EGRESS"
  protocol                  = local.protocol.tcp
  destination_type          = "CIDR_BLOCK"
  destination               = "10.0.30.0/24"
  tcp_options {
    destination_port_range {
      min = 1521
      max = 1521
    }
  }
  depends_on = [oci_core_network_security_group.mushop_app_network_security_group]
}
/* ↑↑↑ AppのNSG (SLからNSGの変更に伴い追加) by Masataka Marukawa ↑↑↑ */

/* ↓↓↓ DBのNSG (SLからNSGの変更に伴い追加) by Masataka Marukawa ↓↓↓ */
resource "oci_core_network_security_group" "mushop_db_network_security_group" {
  compartment_id = var.compartment_ocid
  vcn_id         = oci_core_vcn.mushop_vcn.id
  display_name   = format("%s-mushop-db-network-security-group", var.team_name)
  depends_on = [oci_core_vcn.mushop_vcn]
}

resource "oci_core_network_security_group_security_rule" "mushop_db_network_security_group_ingress_1521_from_app" {
  network_security_group_id = oci_core_network_security_group.mushop_db_network_security_group.id
  description               = "Allow Oracle*Net ingress from App"
  direction                 = "INGRESS"
  protocol                  = local.protocol.tcp
  source_type               = "CIDR_BLOCK"
  source                    = "10.0.20.0/24"
  tcp_options {
    destination_port_range {
      min = 1521
      max = 1521
    }
  }
  depends_on = [oci_core_network_security_group.mushop_db_network_security_group]
}
/* ↑↑↑ DBのNSG (SLからNSGの変更に伴い追加) by Masataka Marukawa ↑↑↑ */

/* ↓↓↓ LBのセキュリティリスト (SLからNSGの変更に伴い削除) by Masataka Marukawa ↓↓↓
resource "oci_core_security_list" "mushop_lb_security_list" {
  compartment_id = var.compartment_ocid
  vcn_id         = oci_core_vcn.mushop_vcn.id
  display_name   = format("%s-mushop-lb-security-list", var.team_name)
  ingress_security_rules {
    protocol    = local.protocol.tcp
    source      = "0.0.0.0/0"
    source_type = "CIDR_BLOCK"
    tcp_options {
      max = "22"
      min = "22"
    }
  }
  ingress_security_rules {
    protocol    = local.protocol.all
    source      = "0.0.0.0/0"
    source_type = "CIDR_BLOCK"
  }
  ingress_security_rules {
    protocol    = local.protocol.tcp
    source      = "0.0.0.0/0"
    source_type = "CIDR_BLOCK"
    tcp_options {
      max = "80"
      min = "80"
    }
  }
  ingress_security_rules {
    protocol    = local.protocol.tcp
    source      = "0.0.0.0/0"
    source_type = "CIDR_BLOCK"
    tcp_options {
      max = "443"
      min = "443"
    }
  }
  egress_security_rules {
    protocol         = local.protocol.all
    destination      = "0.0.0.0/0"
    destination_type = "CIDR_BLOCK"
  }
  depends_on = [oci_core_vcn.mushop_vcn]
}
↑↑↑ LBのセキュリティリスト (SLからNSGの変更に伴い削除) by Masataka Marukawa ↑↑↑ */

/* ↓↓↓ Appのセキュリティリスト (SLからNSGの変更に伴い削除) by Masataka Marukawa ↓↓↓
resource "oci_core_security_list" "mushop_app_security_list" {
  compartment_id = var.compartment_ocid
  vcn_id         = oci_core_vcn.mushop_vcn.id
  display_name   = format("%s-mushop-app-security-list", var.team_name)
  ingress_security_rules {
    protocol    = local.protocol.all
    source      = "10.0.10.0/24"
    source_type = "CIDR_BLOCK"
  }
  ingress_security_rules {
    protocol    = local.protocol.tcp
    source      = "10.0.10.0/24"
    source_type = "CIDR_BLOCK"
    tcp_options {
      max = "22"
      min = "22"
    }
  }
  ingress_security_rules {
    protocol    = local.protocol.tcp
    source      = "10.0.10.0/24"
    source_type = "CIDR_BLOCK"
    tcp_options {
      max = "80"
      min = "80"
    }
  }
  egress_security_rules {
    protocol         = local.protocol.all
    destination      = "0.0.0.0/0"
    destination_type = "CIDR_BLOCK"
  }
  egress_security_rules {
    protocol         = local.protocol.all
    destination      = local.all_services.cidr_block
    destination_type = "SERVICE_CIDR_BLOCK"
  }
  egress_security_rules {
    protocol         = local.protocol.tcp
    destination      = "10.0.30.0/24"
    destination_type = "CIDR_BLOCK"
    tcp_options {
      max = "1522"
      min = "1522"
    }
  }
  depends_on = [oci_core_vcn.mushop_vcn]
}
↑↑↑ Appのセキュリティリスト (SLからNSGの変更に伴い削除) by Masataka Marukawa ↑↑↑ */

/* ↓↓↓ DBのセキュリティリスト (SLからNSGの変更に伴い削除) by Masataka Marukawa ↓↓↓
resource "oci_core_security_list" "mushop_db_security_list" {
  compartment_id = var.compartment_ocid
  vcn_id         = oci_core_vcn.mushop_vcn.id
  display_name   = format("%s-mushop-db-security-list", var.team_name)
  ingress_security_rules {
    protocol    = local.protocol.all
    source      = "10.0.10.0/24"
    source_type = "CIDR_BLOCK"
    stateless   = true
  }
  ingress_security_rules {
    protocol    = local.protocol.tcp
    source      = "10.0.20.0/24"
    source_type = "CIDR_BLOCK"
    tcp_options {
      max = "1522"
      min = "1522"
    }
  }
  depends_on = [oci_core_vcn.mushop_vcn]
}
↑↑↑ Appのセキュリティリスト (SLからNSGの変更に伴い削除) by Masataka Marukawa ↑↑↑ */

resource "oci_core_subnet" "mushop_lb_subnet" {
  cidr_block     = "10.0.10.0/24"
  compartment_id = var.compartment_ocid
  vcn_id         = oci_core_vcn.mushop_vcn.id
  /* SLからNSGの変更に伴い削除 by Masataka Marukawa
  security_list_ids = [
    oci_core_security_list.mushop_lb_security_list.id
  ]
  */
  display_name               = format("%s-mushop-lb-subnet", var.team_name)
  route_table_id             = oci_core_route_table.mushop_public_route_table.id
  prohibit_public_ip_on_vnic = false
  dns_label                  = "lb"
  depends_on                 = [oci_core_vcn.mushop_vcn]
}

resource "oci_core_subnet" "mushop_app_subnet" {
  cidr_block     = "10.0.20.0/24"
  compartment_id = var.compartment_ocid
  vcn_id         = oci_core_vcn.mushop_vcn.id
  /* SLからNSGの変更に伴い削除 by Masataka Marukawa
  security_list_ids = [
    oci_core_security_list.mushop_app_security_list.id
  ]
  */
  display_name               = format("%s-mushop-app-subnet", var.team_name)
  route_table_id             = oci_core_route_table.mushop_private_route_table.id
  prohibit_public_ip_on_vnic = true
  dns_label                  = "app"
  depends_on                 = [oci_core_vcn.mushop_vcn]
}

resource "oci_core_subnet" "mushop_db_subnet" {
  cidr_block     = "10.0.30.0/24"
  compartment_id = var.compartment_ocid
  vcn_id         = oci_core_vcn.mushop_vcn.id
  /* SLからNSGの変更に伴い削除 by Masataka Marukawa
  security_list_ids = [
    oci_core_security_list.mushop_db_security_list.id
  ]
  */
  display_name               = format("%s-mushop-db-subnet", var.team_name)
  route_table_id             = oci_core_route_table.mushop_private_route_table.id
  prohibit_public_ip_on_vnic = true
  dns_label                  = "db"
  depends_on                 = [oci_core_vcn.mushop_vcn]
}
