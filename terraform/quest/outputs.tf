output "lb_public_url" {
  value = format("http://%s", lookup(oci_load_balancer_load_balancer.mushop_lb.ip_address_details[0], "ip_address"))
}

output "bastion_ip" {
  value = oci_core_instance.mushop_bastion.public_ip
}

output "app_private_ip" {
  value = oci_core_instance.mushop_app_instance.private_ip
}

locals {
  # 全プロファイルの中から HIGH の最初の value を見つける
  high_value_string = one([
    for profile in oci_database_autonomous_database.mushop_atp.connection_strings[0].profiles :
    profile.value if profile.consumer_group == "HIGH"
  ])

  # high_value_string から host=... の部分だけを抽出する（正規表現）
  high_host = regex("host=([a-zA-Z0-9.-]+)", local.high_value_string)[0]
}

output "high_host" {
  value = local.high_host
}
