locals {
  all_services = data.oci_core_services.all_services.services.0
  protocol = {
    all  = "all"
    icmp = "1"
    tcp  = "6"
  }
}