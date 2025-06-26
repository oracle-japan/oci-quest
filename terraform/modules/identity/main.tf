# すべてのコンパートメントを取得
data "oci_identity_compartments" "all_compartments" {
  compartment_id             = var.tenancy_ocid
  access_level               = "ANY"
  compartment_id_in_subtree = true
  depends_on = [null_resource.wait_for_compartments] # コンパートメント作成後に実行
}

resource "oci_identity_compartment" "teams" {
    for_each = local.team_map

    name           = each.key
    description    = each.value.description
    compartment_id = var.tenancy_ocid 
    enable_delete  = true              
}

# resource "oci_identity_compartment" "admin_dev" {
#     name = "admin_dev"
#     description = "運営用のコンパートメントです。"
#     compartment_id = var.tenancy_ocid
#     enable_delete = true
# }

resource "oci_identity_user" "users" {
  for_each = local.member_map

  name           = each.key
  email          = each.value.email
  description    = "${each.value.team_name} - ${each.key}"
  compartment_id = var.tenancy_ocid
}

resource "oci_identity_group" "teams" {
  for_each = local.team_map

  name        = each.key
  description = "Group for ${each.key}"
  compartment_id = var.tenancy_ocid
}

# # resource "oci_identity_group" "admin_dev" {
# #   name = "admin_dev"
# #   description = "運営用"
# #   compartment_id = var.tenancy_ocid
# # }

resource "oci_identity_user_group_membership" "test_user_group_membership" {
  for_each = local.member_map
  user_id = oci_identity_user.users[each.key].id
  group_id = oci_identity_group.teams[each.value.team_name].id
}

# # resource "oci_identity_user_group_membership" "admin_dev_membership" {
# #   for_each = { for id in var.admin_user_ocids : id => id }

# #   user_id  = each.key
# #   group_id = oci_identity_group.admin_dev.id
# # }


resource "oci_identity_policy" "team_access" {
  for_each = local.team_map

  name           = "policy_${each.key}" 
  description    = "Allow ${each.key} group to manage all-resources in compartment ${each.key}"
  compartment_id = var.tenancy_ocid  

  statements = [
    "Allow group ${each.key} to manage all-resources in compartment ${each.key}",
    "Allow group ${each.key} to manage loganalytics-features-family in tenancy",
    "Allow group ${each.key} to manage loganalytics-resources-family in tenancy",
    "Allow group ${each.key} to use cloud-shell in tenancy",
    "Allow group ${each.key} to use secret-family in tenancy"
  ]

  depends_on = [null_resource.wait_for_compartments]
}

# # resource "oci_identity_policy" "admin_dev_access" {
# #   name           = "admin_dev_access_policy"
# #   description    = "devグループにdevコンパートメントの管理権限を付与"
# #   compartment_id = var.tenancy_ocid

# #   statements = [
# #     "Allow group admin_dev to manage all-resources in compartment admin_dev",
# #     "Allow service dpd to manage objects in compartment admin_dev",
# #     "Allow service dpd to read secret-family in compartment admin_dev",
# #     "Allow service dpd to use vaults in compartment admin_dev",
# #     "Allow service dpd to use keys in compartment admin_dev",
# #     "Allow group admin_dev to manage loganalytics-features-family in tenancy",
# #     "Allow group admin_dev to manage loganalytics-resources-family in tenancy",
# #     "Allow group admin_dev to use cloud-shell in tenancy"
# #   ]

# #   depends_on = [null_resource.wait_for_compartments]
# # }

resource "oci_identity_policy" "common_policy" {
  name           = "common_policy"
  compartment_id = var.tenancy_ocid
  description = "共通のポリシー"
  statements = [
    "Allow service dpd to manage objects in compartment id ${var.tenancy_ocid}",
    "Allow service dpd to read secret-family in compartment id ${var.tenancy_ocid}",
    "Allow service dpd to use vaults in compartment id ${var.tenancy_ocid}",
    "Allow service dpd to use keys in compartment id ${var.tenancy_ocid}",
    "Allow service loganalytics to read loganalytics-features-family in tenancy",
    "Allow service loganalytics to {LOG_ANALYTICS_LIFECYCLE_INSPECT, LOG_ANALYTICS_LIFECYCLE_READ} in tenancy",
    "Allow service loganalytics to MANAGE cloud-events-rule in tenancy",
    "Allow service loganalytics to READ compartments in tenancy"
  ]

  depends_on = [null_resource.wait_for_compartments]
}


# コンパートメント作成直後にはポリシーを作成できないので、待つ必要がある
resource "null_resource" "wait_for_compartments" {
  triggers = {
    always_run = timestamp()
  }

  provisioner "local-exec" {
    command = "sleep 60"  # 60秒待機
  }

  depends_on = [
    oci_identity_compartment.teams,
    #oci_identity_compartment.admin_dev
  ]
}