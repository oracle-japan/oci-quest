data "oci_objectstorage_namespace" "mushop_namespace" {
  compartment_id = var.compartment_ocid
}


resource "oci_objectstorage_bucket" "mushop" {
  for_each = local.team_compartment_ocids

  compartment_id = each.value
  name           = format("%s-mushop", each.key)
  namespace      = local.namespace
}

# resource "oci_objectstorage_object" "mushop_wallet" {
#   for_each = local.team_compartment_ocids

#   bucket    = oci_objectstorage_bucket.mushop[each.key].name
#   content   = oci_database_autonomous_database_wallet.mushop_wallet[each.key].content
#   namespace = local.namespace
#   object    = "mushop_atp_wallet"
# }
# resource "oci_objectstorage_preauthrequest" "mushop_wallet_preauth" {
#   for_each = local.team_compartment_ocids

#   access_type  = "ObjectRead"
#   bucket       = oci_objectstorage_bucket.mushop[each.key].name
#   name         = format("%s-mushop-wallet-preauth", each.key)
#   namespace    = local.namespace
#   time_expires = timeadd(timestamp(), "72h")
#   object_name  = oci_objectstorage_object.mushop_wallet[each.key].object
# }


# resource "oci_objectstorage_object" "mushop_media_pars_list" {
#   for_each = local.team_compartment_ocids

#   bucket    = oci_objectstorage_bucket.mushop[each.key].name
#   content   = local.mushop_media_pars_list
#   namespace = local.namespace
#   object    = "mushop_media_pars_list.txt"
# }
# resource "oci_objectstorage_preauthrequest" "mushop_media_pars_list_preauth" {
#   for_each = local.team_compartment_ocids

#   access_type  = "ObjectRead"
#   bucket       = oci_objectstorage_bucket.mushop[each.key].name
#   name         = format("%s-mushop_media_pars_list_preauth", each.key)
#   namespace    = local.namespace
#   time_expires = timeadd(timestamp(), "72h")
#   object_name  = oci_objectstorage_object.mushop_media_pars_list[each.key].object
# }

# Static assets bucket
resource "oci_objectstorage_bucket" "mushop_media" {
  for_each = local.team_compartment_ocids

  compartment_id = each.value
  name           = format("%s-mushop-media", each.key)
  namespace      = local.namespace
  access_type    = "ObjectReadWithoutList"
}

# Static product media
# resource "oci_objectstorage_object" "mushop_media" {
#   for_each = local.team_image_pairs

#   bucket    = oci_objectstorage_bucket.mushop_media[each.value.team].name
#   namespace = local.namespace
#   object    = each.value.image
#   source    = "./images/${each.value.image}"
#   content_type  = "image/png"
#   cache_control = "max-age=604800, public, no-transform"
# }


# # Static product media pars for Private (Load to catalogue service)
# resource "oci_objectstorage_preauthrequest" "mushop_media_pars_preauth" {
#   for_each = local.team_image_pairs

#   bucket       = oci_objectstorage_bucket.mushop_media[each.value.team].name
#   namespace    = local.namespace
#   object_name  = each.value.image
#   name         = "mushop_media_pars_par-${each.value.team}-${replace(each.value.image, "/", "_")}"
#   access_type  = "ObjectRead"
#   time_expires = timeadd(timestamp(), "72h")
# }


