resource "oci_load_balancer_load_balancer" "mushop_lb" {
  compartment_id = var.compartment_ocid
  display_name   = format("%s-mushop-load-balancer", data.oci_identity_compartment.team_compartment.name)
  shape          = "flexible"
  subnet_ids     = [local.lb_subnet.id]
  is_private     = false
  shape_details {
    minimum_bandwidth_in_mbps = 10
    maximum_bandwidth_in_mbps = 100
  }
  /* ↓↓↓　SLからNSGの変更に伴い追加 by Masataka Marukawa ↓↓↓ */
  network_security_group_ids = [
    local.lb_nsg.id
  ]
  /* ↑↑↑ SLからNSGの変更に伴い追加 by Masataka Marukawa　↑↑↑ */
}

resource "oci_load_balancer_backend_set" "mushop_backend_set" {
  name             = format("%s-mushop-backend-set", data.oci_identity_compartment.team_compartment.name)
  load_balancer_id = oci_load_balancer_load_balancer.mushop_lb.id
  policy           = "IP_HASH"
  health_checker {
    port                = "80"
    protocol            = "HTTP"
    response_body_regex = ".*"
    url_path            = "/api/health"
    return_code         = 200
    interval_ms         = 5000
    timeout_in_millis   = 2000
    retries             = 10
  }
}

resource "oci_load_balancer_backend" "mushop-backend" {
  load_balancer_id = oci_load_balancer_load_balancer.mushop_lb.id
  backendset_name  = oci_load_balancer_backend_set.mushop_backend_set.name
  ip_address       = oci_core_instance.mushop_app_instance.private_ip
  port             = 80
  backup           = false
  drain            = false
  offline          = false
  weight           = 1
}

resource "oci_load_balancer_listener" "mushop_listener_80" {
  load_balancer_id         = oci_load_balancer_load_balancer.mushop_lb.id
  default_backend_set_name = oci_load_balancer_backend_set.mushop_backend_set.name
  name                     = format("%s-mushop-80", data.oci_identity_compartment.team_compartment.name)
  port                     = 80
  protocol                 = "HTTP"

  connection_configuration {
    idle_timeout_in_seconds = "30"
  }
}

resource "oci_load_balancer_listener" "mushop_listener_443" {
  load_balancer_id         = oci_load_balancer_load_balancer.mushop_lb.id
  default_backend_set_name = oci_load_balancer_backend_set.mushop_backend_set.name
  name                     = format("%s-mushop-443", data.oci_identity_compartment.team_compartment.name)
  port                     = 443
  protocol                 = "HTTP"

  connection_configuration {
    idle_timeout_in_seconds = "30"
  }
}
