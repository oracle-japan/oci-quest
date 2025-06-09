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

locals {
  ad              = data.oci_identity_availability_domain.ad.name
  shape           = "VM.Standard.E5.Flex"
  image           = data.oci_core_images.mushop_images.images[0].id
  setup_preflight = file("${path.module}/scripts/setup.preflight.sh")
  setup_template = templatefile("${path.module}/scripts/setup.template.sh",
    {
      oracle_client_version = "19.10"
  })
  deploy_template = templatefile("${path.module}/scripts/deploy.template.sh",
    {
      oracle_client_version   = "19.10"
      db_name                 = data.oci_database_autonomous_database.mushop_atp.db_name
      atp_pw                  = var.database_password
      mushop_media_visibility = true
      wallet_par              = "https://objectstorage.${var.region}.oraclecloud.com${oci_objectstorage_preauthrequest.mushop_wallet_preauth.access_uri}"
      oda_enabled             = false
      oda_uri                 = ""
      oda_channel_id          = ""
      oda_secret              = ""
      oda_user_init_message   = ""
      version                 = replace(file("${path.module}/VERSION"), "\n", "")
  })
  httpd_conf = file("${path.module}/scripts/httpd.conf")
  cloud_init = templatefile("${path.module}/scripts/cloud-config.template.yaml",
    {
      setup_preflight_sh_content     = base64gzip(local.setup_preflight)
      setup_template_sh_content      = base64gzip(local.setup_template)
      deploy_template_content        = base64gzip(local.deploy_template)
      httpd_conf_content             = base64gzip(local.httpd_conf)
      mushop_media_pars_list_content = base64gzip(local.mushop_media_pars_list)
      catalogue_password             = var.database_password
      catalogue_port                 = 3005
      catalogue_architecture         = "amd64"
      mock_mode                      = "carts,orders,users"
      db_name                        = data.oci_database_autonomous_database.mushop_atp.db_name
      assets_url                     = "https://objectstorage.${var.region}.oraclecloud.com/n/${data.oci_objectstorage_bucket.mushop_media_bucket.namespace}/b/${data.oci_objectstorage_bucket.mushop_media_bucket.name}/o/"
      public_key = tls_private_key.bastion_ssh_key.public_key_openssh
  })
}