data "oci_objectstorage_namespace" "mushop_namespace" {
  compartment_id = var.compartment_ocid
}

data "oci_objectstorage_bucket_summaries" "mushop_buckets" {
    #Required
    compartment_id = var.compartment_ocid
    namespace = data.oci_objectstorage_namespace.mushop_namespace.namespace
}

data "oci_objectstorage_bucket" "mushop_bucket" {
  namespace = data.oci_objectstorage_namespace.mushop_namespace.namespace
  name      = local.matched_mushop_bucket.name
}

data "oci_objectstorage_bucket" "mushop_media_bucket" {
  namespace = data.oci_objectstorage_namespace.mushop_namespace.namespace
  name      = local.matched_mushop_media_bucket.name
}

resource "oci_database_autonomous_database_wallet" "mushop_wallet" {
  autonomous_database_id = data.oci_database_autonomous_database.mushop_atp.autonomous_database_id
  password               = var.database_password  # 取得時に必要
  generate_type          = "SINGLE"
  base64_encode_content = "true"
}

data "oci_objectstorage_preauthrequests" "mushop_preauthenticated_requests" {
    #Required
    bucket = data.oci_objectstorage_bucket.mushop_bucket.name
    namespace = data.oci_objectstorage_namespace.mushop_namespace.namespace
}

data "oci_objectstorage_preauthrequests" "mushop_media_preauthenticated_requests" {
    #Required
    bucket = data.oci_objectstorage_bucket.mushop_media_bucket.name
    namespace = data.oci_objectstorage_namespace.mushop_namespace.namespace
}

resource "oci_objectstorage_object" "mushop_wallet" {
  bucket    = data.oci_objectstorage_bucket.mushop_bucket.name
  content   = oci_database_autonomous_database_wallet.mushop_wallet.content
  namespace = local.namespace
  object    = "mushop_atp_wallet"
}

resource "oci_objectstorage_preauthrequest" "mushop_wallet_preauth" {
  access_type  = "ObjectRead"
  bucket       = data.oci_objectstorage_bucket.mushop_bucket.name
  name         = format("%s-mushop-wallet-preauth", local.compartment_name)
  namespace    = local.namespace
  time_expires = timeadd(timestamp(), "72h")
  object_name  = oci_objectstorage_object.mushop_wallet.object
}


resource "oci_objectstorage_preauthrequest" "mushop_media_pars_list_preauth" {
  access_type  = "ObjectRead"
  bucket       = data.oci_objectstorage_bucket.mushop_media_bucket.name
  name         = format("%s-mushop_media_pars_list_preauth", local.compartment_name)
  namespace    = local.namespace
  time_expires = timeadd(timestamp(), "72h")
  object_name  = oci_objectstorage_object.mushop_media_pars_list.object
}

resource "oci_objectstorage_preauthrequest" "mushop_media_pars_preauth" {
  for_each = local.team_image_pairs

  bucket       = data.oci_objectstorage_bucket.mushop_media_bucket.name
  namespace    = local.namespace
  object_name  = each.value.image
  name         = "mushop_media_pars_par-${local.compartment_name}-${replace(each.value.image, "/", "_")}"
  access_type  = "ObjectRead"
  time_expires = timeadd(timestamp(), "72h")
}
