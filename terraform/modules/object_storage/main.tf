resource "oci_objectstorage_bucket" "mushop" {
  compartment_id = var.compartment_ocid
  name           = format("%s-mushop", var.team_name)
  namespace      = local.namespace
}

resource "oci_objectstorage_bucket" "mushop_media" {
  compartment_id = var.compartment_ocid
  name           = format("%s-mushop-media", var.team_name)
  namespace      = local.namespace
  access_type    = "ObjectReadWithoutList"
}

resource "oci_objectstorage_object" "mushop_media" {
  for_each = fileset(var.image_file_path, "**")

  bucket        = oci_objectstorage_bucket.mushop_media.name
  namespace     = oci_objectstorage_bucket.mushop_media.namespace
  object        = each.value
  source        = "${var.image_file_path}/${each.value}"
  content_type  = "image/png"
  cache_control = "max-age=604800, public, no-transform"
}

resource "oci_objectstorage_object" "mushop_wallet" {
  bucket    = oci_objectstorage_bucket.mushop.name
  content   = var.mushop_wallet
  namespace = local.namespace
  object    = "mushop_atp_wallet"
}

resource "oci_objectstorage_object" "mushop_media_pars_list" {
  bucket    = oci_objectstorage_bucket.mushop.name
  content   = local.mushop_media_pars_list
  namespace = local.namespace
  object    = "mushop_media_pars_list.txt"
}

resource "oci_objectstorage_preauthrequest" "mushop_wallet_preauth" {
  access_type  = "ObjectRead"
  bucket       = oci_objectstorage_bucket.mushop.name
  name         = format("%s-mushop-wallet-preauth", var.team_name)
  namespace    = local.namespace
  time_expires = timeadd(timestamp(), "72h")
  object_name  = oci_objectstorage_object.mushop_wallet.object
}


resource "oci_objectstorage_preauthrequest" "mushop_media_pars_preauth" {
  for_each = oci_objectstorage_object.mushop_media

  bucket       = oci_objectstorage_bucket.mushop_media.name
  namespace    = oci_objectstorage_bucket.mushop_media.namespace
  object_name  = each.value.object
  name         = "mushop_media_pars_par"
  access_type  = "ObjectRead"
  time_expires = timeadd(timestamp(), "30m")
}