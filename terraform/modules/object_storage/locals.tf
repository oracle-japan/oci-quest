data "oci_objectstorage_namespace" "mushop_namespace" {
  compartment_id = var.tenancy_ocid
}

locals {
  namespace = data.oci_objectstorage_namespace.mushop_namespace.namespace
  mushop_media_pars = join(",", [for media in oci_objectstorage_preauthrequest.mushop_media_pars_preauth :
  format("https://objectstorage.%s.oraclecloud.com%s", var.region, media.access_uri)])
  mushop_media_pars_list = templatefile("${path.module}/scripts/mushop_media_pars_list.txt",
    {
      content = local.mushop_media_pars
  })
}