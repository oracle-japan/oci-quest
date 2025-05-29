provider "oci" {
  region           = var.region
  tenancy_ocid     = var.tenancy_ocid
  user_ocid        = var.current_user_ocid
  fingerprint      = "bc:f7:ee:a4:a2:bc:a5:6b:c7:71:8d:05:c8:d2:c7:83"
  private_key_path = "C:\\Users\\yusogawa\\.oci\\ociquestkddi.pem"
}

provider "cloudinit" {
}

provider "http" {
}

provider "null" {
}

provider "external" {
}
