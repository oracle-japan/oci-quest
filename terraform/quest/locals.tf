locals {
  namespace = data.oci_objectstorage_namespace.mushop_namespace.namespace
  mushop_media_pars = join(",", [
  for media in oci_objectstorage_preauthrequest.mushop_media_pars_preauth :
  format("https://objectstorage.%s.oraclecloud.com%s", var.region, media.access_uri)
  ])

  mushop_media_pars_list = templatefile("${path.module}/scripts/mushop_media_pars_list.txt",
    {
      content = local.mushop_media_pars
  })
}

locals {
  compartment_name = data.oci_identity_compartment.team_compartment.name
  mushop_bucket_name = format("%s-mushop", local.compartment_name)

  matched_mushop_bucket = one([
    for b in data.oci_objectstorage_bucket_summaries.mushop_buckets.bucket_summaries : b
    if b.name == local.mushop_bucket_name
  ])
}

locals {
  mushop_media_bucket_name = format("%s-mushop-media", local.compartment_name)

  matched_mushop_media_bucket = one([
    for b in data.oci_objectstorage_bucket_summaries.mushop_buckets.bucket_summaries : b
    if b.name == local.mushop_media_bucket_name
  ])
}

locals {
  mushop_wallet_pars_filtered = [
    for par in data.oci_objectstorage_preauthrequests.mushop_preauthenticated_requests.preauthenticated_requests :
    par if par.object_name == "mushop_atp_wallet"
  ]

  mushop_wallet_par = length(local.mushop_wallet_pars_filtered) == 1 ? local.mushop_wallet_pars_filtered[0] : null
}



locals {
  vcn_id = data.oci_core_vcns.all_vcns.virtual_networks[0].id
}

locals {
  lb_subnet = one([
    for s in data.oci_core_subnets.all_subnets.subnets : s
    if s.display_name == format("%s-mushop-lb-subnet", local.compartment_name)
  ])
}

locals {
  app_subnet = one([
    for s in data.oci_core_subnets.all_subnets.subnets : s
    if s.display_name == format("%s-mushop-app-subnet", local.compartment_name)
  ])
}

locals {
  bastion_nsg = one([
    for n in data.oci_core_network_security_groups.all_nsgs.network_security_groups : n
    if n.display_name == format("%s-mushop-bastion-network-security-group", local.compartment_name)
  ])
}

locals {
  lb_nsg = one([
    for n in data.oci_core_network_security_groups.all_nsgs.network_security_groups : n
    if n.display_name == format("%s-mushop-lb-network-security-group", local.compartment_name)
  ])
}

locals {
  app_nsg = one([
    for n in data.oci_core_network_security_groups.all_nsgs.network_security_groups : n
    if n.display_name == format("%s-mushop-app-network-security-group", local.compartment_name)
  ])
}

locals {
  image_files = fileset("./images", "**")

  # compartment_ocidが単一の文字列の場合の修正
  team_image_pairs = {
    for image in local.image_files :
    image => {
      team  = "default"  # または適切なチーム名
      image = image
    }
  }
}