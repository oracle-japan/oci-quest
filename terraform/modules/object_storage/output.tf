output "wallet_par_uri" {
  description = "Pre-authenticated request for the wallet"
  value = oci_objectstorage_preauthrequest.mushop_wallet_preauth.access_uri
}