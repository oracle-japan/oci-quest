provider "oci" {
  region           = var.region
  tenancy_ocid     = var.tenancy_ocid
  user_ocid        = var.current_user_ocid
  fingerprint      = "07:22:57:3b:b3:f7:b3:0b:09:97:2c:6a:71:14:4e:68"
  private_key_path = "C:\\Users\\yusogawa\\.oci\\ociquestkddi2.pem"
}

# provider "oci" {
#   #tenancy_ocid = var.tenancy_ocid
#   config_file_profile= "OCIQUEST"
  
# }

provider "cloudinit" {
}

provider "http" {
}

provider "null" {
}

provider "external" {
}
