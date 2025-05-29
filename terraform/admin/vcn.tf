data "oci_core_services" "all_services" {
  filter {
    name   = "name"
    values = ["All.*"]
    regex  = true
  }
}


resource "oci_core_vcn" "mushop_vcn" {
  for_each = local.team_compartment_ocids

  compartment_id = each.value
  cidr_block     = "10.0.0.0/16"
  display_name   = format("%s-mushop-vcn", each.key)
  dns_label      = "mushop"
}

resource "oci_core_internet_gateway" "mushop_internet_gateway" {
  for_each = local.team_compartment_ocids

  compartment_id = each.value
  vcn_id         = oci_core_vcn.mushop_vcn[each.key].id
  display_name   = format("%s-mushop-internet-gateway", each.key)
}

resource "oci_core_nat_gateway" "mushop_nat_gateway" {
  for_each = local.team_compartment_ocids

  compartment_id = each.value
  vcn_id         = oci_core_vcn.mushop_vcn[each.key].id
  display_name   = format("%s-mushop-nat-gateway", each.key)
}

resource "oci_core_service_gateway" "mushop_service_gateway" {
  for_each = local.team_compartment_ocids

  compartment_id = each.value
  vcn_id         = oci_core_vcn.mushop_vcn[each.key].id
  display_name   = format("%s-mushop-service-gateway", each.key)
  services {
    service_id = local.all_services.id
  }
}

resource "oci_core_route_table" "mushop_public_route_table" {
  for_each = local.team_compartment_ocids

  compartment_id = each.value
  vcn_id         = oci_core_vcn.mushop_vcn[each.key].id
  display_name   = format("%s-mushop-public-route-table", each.key)
  route_rules {
    destination       = "0.0.0.0/0"
    destination_type  = "CIDR_BLOCK"
    network_entity_id = oci_core_internet_gateway.mushop_internet_gateway[each.key].id
  }
}

resource "oci_core_route_table" "mushop_private_route_table" {
  for_each = local.team_compartment_ocids

  compartment_id = each.value
  vcn_id         = oci_core_vcn.mushop_vcn[each.key].id
  display_name   = format("%s-mushop-private-route-table", each.key)
  # OCI Quest 設問 : コンピュート・インスタンスのメトリック情報が確認できない のために意図的にコメントアウト
  # route_rules {
  #   destination       = local.all_services.cidr_block
  #   destination_type  = "SERVICE_CIDR_BLOCK"
  #   network_entity_id = oci_core_service_gateway.mushop_service_gateway.id
  # }
  route_rules {
    destination       = "0.0.0.0/0"
    destination_type  = "CIDR_BLOCK"
    network_entity_id = oci_core_nat_gateway.mushop_nat_gateway[each.key].id
  }
}

resource "oci_core_network_security_group" "mushop_bastion_network_security_group" {
  for_each = local.team_compartment_ocids

  compartment_id = each.value
  vcn_id         = oci_core_vcn.mushop_vcn[each.key].id
  display_name   = format("%s-mushop-bastion-network-security-group", each.key)
}

resource "oci_core_network_security_group_security_rule" "mushop_bastion_network_security_group_ingress_ssh" {
  for_each = local.team_compartment_ocids

  network_security_group_id = oci_core_network_security_group.mushop_bastion_network_security_group[each.key].id
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
  for_each = local.team_compartment_ocids

  network_security_group_id = oci_core_network_security_group.mushop_bastion_network_security_group[each.key].id
  description               = "Allow all egress"
  direction                 = "EGRESS"
  protocol                  = local.protocol.all
  destination_type          = "CIDR_BLOCK"
  destination               = "0.0.0.0/0"
  depends_on                = [oci_core_network_security_group.mushop_bastion_network_security_group]
}

resource "oci_core_network_security_group" "mushop_lb_network_security_group" {
  for_each = local.team_compartment_ocids

  compartment_id = each.value
  vcn_id         = oci_core_vcn.mushop_vcn[each.key].id
  display_name   = format("%s-mushop-lb-network-security-group", each.key)
}

# OCI Quest 設問 : MuShop のトップページにアクセスできません のために意図的にコメントアウト
# resource "oci_core_network_security_group_security_rule" "mushop_lb_network_security_group_ingress_http" {
#   network_security_group_id = oci_core_network_security_group.mushop_lb_network_security_group.id
#   description               = "Allow HTTP ingress"
#   direction                 = "INGRESS"
#   protocol                  = local.protocol.tcp
#   source_type               = "CIDR_BLOCK"
#   source                    = "0.0.0.0/0"
#   tcp_options {
#     destination_port_range {
#       min = 80
#       max = 80
#     }
#   }
#   depends_on = [oci_core_network_security_group.mushop_lb_network_security_group]
# }

# resource "oci_core_network_security_group_security_rule" "mushop_lb_network_security_group_ingress_https" {
#   network_security_group_id = oci_core_network_security_group.mushop_lb_network_security_group.id
#   description               = "Allow HTTPS ingress"
#   direction                 = "INGRESS"
#   protocol                  = local.protocol.tcp
#   source_type               = "CIDR_BLOCK"
#   source                    = "0.0.0.0/0"
#   tcp_options {
#     destination_port_range {
#       min = 443
#       max = 443
#     }
#   }
#   depends_on = [oci_core_network_security_group.mushop_lb_network_security_group]
# }

resource "oci_core_network_security_group_security_rule" "mushop_lb_network_security_group_egress_all" {
  for_each = local.team_compartment_ocids

  network_security_group_id = oci_core_network_security_group.mushop_lb_network_security_group[each.key].id
  description               = "Allow all egress"
  direction                 = "EGRESS"
  protocol                  = local.protocol.all
  destination_type          = "CIDR_BLOCK"
  destination               = "0.0.0.0/0"
  depends_on                = [oci_core_network_security_group.mushop_lb_network_security_group]
}

resource "oci_core_network_security_group" "mushop_app_network_security_group" {
  for_each = local.team_compartment_ocids

  compartment_id = each.value
  vcn_id         = oci_core_vcn.mushop_vcn[each.key].id
  display_name   = format("%s-mushop-app-network-security-group", each.key)
}

resource "oci_core_network_security_group_security_rule" "mushop_app_network_security_group_ingress_ssh_from_bastion" {
  for_each = local.team_compartment_ocids

  network_security_group_id = oci_core_network_security_group.mushop_app_network_security_group[each.key].id
  description               = "Allow SSH ingress from bastion"
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
  for_each = local.team_compartment_ocids

  network_security_group_id = oci_core_network_security_group.mushop_app_network_security_group[each.key].id
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

resource "oci_core_network_security_group_security_rule" "mushop_app_network_security_group_egress_all" {
  for_each = local.team_compartment_ocids

  network_security_group_id = oci_core_network_security_group.mushop_app_network_security_group[each.key].id
  description               = "Allow all egress"
  direction                 = "EGRESS"
  protocol                  = local.protocol.all
  destination_type          = "CIDR_BLOCK"
  destination               = "0.0.0.0/0"
  depends_on                = [oci_core_network_security_group.mushop_app_network_security_group]
}

resource "oci_core_network_security_group_security_rule" "mushop_app_network_security_group_egress_all_to_osn" {
  for_each = local.team_compartment_ocids

  network_security_group_id = oci_core_network_security_group.mushop_app_network_security_group[each.key].id
  description               = "Allow all egress to OSN"
  direction                 = "EGRESS"
  protocol                  = local.protocol.all
  destination_type          = "SERVICE_CIDR_BLOCK"
  destination               = local.all_services.cidr_block
  depends_on                = [oci_core_network_security_group.mushop_app_network_security_group]
}

resource "oci_core_network_security_group_security_rule" "mushop_app_network_security_group_egress_to_db" {
  for_each = local.team_compartment_ocids

  network_security_group_id = oci_core_network_security_group.mushop_app_network_security_group[each.key].id
  description               = "Allow Oracle*Net egress to DB"
  direction                 = "EGRESS"
  protocol                  = local.protocol.tcp
  destination_type          = "CIDR_BLOCK"
  destination               = "10.0.30.0/24"
  tcp_options {
    destination_port_range {
      min = 1522
      max = 1522
    }
  }
  depends_on = [oci_core_network_security_group.mushop_app_network_security_group]
}

resource "oci_core_network_security_group_security_rule" "mushop_db_network_security_group_egress_to_pe" {
  for_each = local.team_compartment_ocids

  network_security_group_id = oci_core_network_security_group.mushop_app_network_security_group[each.key].id
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

resource "oci_core_network_security_group" "mushop_db_network_security_group" {
  for_each = local.team_compartment_ocids

  compartment_id = each.value
  vcn_id         = oci_core_vcn.mushop_vcn[each.key].id
  display_name   = format("%s-mushop-db-network-security-group", each.key)
  depends_on     = [oci_core_vcn.mushop_vcn]
}

resource "oci_core_network_security_group_security_rule" "mushop_db_network_security_group_ingress_from_app" {
  for_each = local.team_compartment_ocids

  network_security_group_id = oci_core_network_security_group.mushop_db_network_security_group[each.key].id
  description               = "Allow Oracle*Net ingress from App"
  direction                 = "INGRESS"
  protocol                  = local.protocol.tcp
  source_type               = "CIDR_BLOCK"
  source                    = "10.0.20.0/24"
  tcp_options {
    destination_port_range {
      min = 1522
      max = 1522
    }
  }
  depends_on = [oci_core_network_security_group.mushop_db_network_security_group]
}

resource "oci_core_network_security_group_security_rule" "mushop_db_network_security_group_ingress_from_pe" {
  for_each = local.team_compartment_ocids

  network_security_group_id = oci_core_network_security_group.mushop_db_network_security_group[each.key].id
  description               = "Allow Oracle*Net ingress from App"
  direction                 = "INGRESS"
  protocol                  = local.protocol.tcp
  source_type               = "CIDR_BLOCK"
  source                    = "10.0.30.0/24"
  tcp_options {
    destination_port_range {
      min = 1521
      max = 1521
    }
  }
  depends_on = [oci_core_network_security_group.mushop_db_network_security_group]
}

resource "oci_core_subnet" "mushop_lb_subnet" {
  for_each = local.team_compartment_ocids

  cidr_block                 = "10.0.10.0/24"
  compartment_id             = each.value
  vcn_id                     = oci_core_vcn.mushop_vcn[each.key].id
  display_name               = format("%s-mushop-lb-subnet", each.key)
  route_table_id             = oci_core_route_table.mushop_public_route_table[each.key].id
  prohibit_public_ip_on_vnic = false
  dns_label                  = "lb"
  depends_on                 = [oci_core_vcn.mushop_vcn]
}

resource "oci_core_subnet" "mushop_app_subnet" {
  for_each = local.team_compartment_ocids

  cidr_block                 = "10.0.20.0/24"
  compartment_id             = each.value
  vcn_id                     = oci_core_vcn.mushop_vcn[each.key].id
  display_name               = format("%s-mushop-app-subnet", each.key)
  route_table_id             = oci_core_route_table.mushop_private_route_table[each.key].id
  prohibit_public_ip_on_vnic = true
  dns_label                  = "app"
  depends_on                 = [oci_core_vcn.mushop_vcn]
}

resource "oci_core_subnet" "mushop_db_subnet" {
  for_each = local.team_compartment_ocids

  cidr_block                 = "10.0.30.0/24"
  compartment_id             = each.value
  vcn_id                     = oci_core_vcn.mushop_vcn[each.key].id
  display_name               = format("%s-mushop-db-subnet", each.key)
  route_table_id             = oci_core_route_table.mushop_private_route_table[each.key].id
  prohibit_public_ip_on_vnic = true
  dns_label                  = "db"
  depends_on                 = [oci_core_vcn.mushop_vcn]
}
