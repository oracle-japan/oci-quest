
# module "identity" {
#   source = "../modules/identity"

#   tenancy_ocid = var.tenancy_ocid
#   members_file = var.members_file

# }

module "vcn" {
  source = "../modules/vcn"

  for_each = module.identity.teamname_to_compartment_ocid_map

  tenancy_ocid = var.tenancy_ocid
  compartment_ocid = each.value
  team_name = each.key
}

module "atp" {
  source = "../modules/atp"

  for_each = module.identity.teamname_to_compartment_ocid_map

  database_password = var.database_password
  subnet_ocid = module.vcn[each.key].mushop_db_subnet_ocid
  nsg_ocid = module.vcn[each.key].mushop_db_nsg_ocid
  database_password_secret_id = var.database_password_secret_id
  compartment_ocid = each.value
  team_name = each.key

  depends_on = [module.identity, module.vcn]

}

module "log_analytics" {
  source = "../modules/log_analytics"

  for_each = module.identity.teamname_to_compartment_ocid_map

  tenancy_ocid = var.tenancy_ocid
  team_name = each.key
  compartment_ocid = each.value

  depends_on = [module.identity]
}

module "object_storage" {
  source = "../modules/object_storage"

  for_each = module.identity.teamname_to_compartment_ocid_map

  region = var.region
  tenancy_ocid = var.tenancy_ocid
  compartment_ocid = each.value
  team_name = each.key
  image_file_path = "./images"
  mushop_wallet = module.atp[each.key].mushop_wallet

  depends_on = [module.identity]
}

module "init-compute" {
  source = "../modules/init-compute"

  for_each = module.identity.teamname_to_compartment_ocid_map

  team_name = each.key
  compartment_ocid = each.value
  database_password = var.database_password
  tenancy_ocid = var.tenancy_ocid
  region = var.region
  subnet_ocid = module.vcn[each.key].mushop_app_subnet_ocid
  nsg_ocid = module.vcn[each.key].mushop_app_nsg_ocid
  db_name = module.atp[each.key].db_name
  wallet_par_uri = module.object_storage[each.key].wallet_par_uri 
  public_key = var.public_key
}