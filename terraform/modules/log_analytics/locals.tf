data "oci_objectstorage_namespace" "ns" {

    #Optional
    compartment_id = var.tenancy_ocid
}

locals {
  namespace = data.oci_objectstorage_namespace.ns.namespace
}