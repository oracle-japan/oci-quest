provider "oci" {
  region           = "ap-tokyo-1" #var.region
  tenancy_ocid     = "ocid1.tenancy.oc1..aaaaaaaaataul433yuanhzular62opj6y4kc7b4mvoro5wcvoys5mkjvyu5q"#var.tenancy_ocid
  user_ocid        = "ocid1.user.oc1..aaaaaaaavzebl4r5pyfudbmkf5yswcr2tpiifg4oifw4o2x6xy24djhw3aka"#var.current_user_ocid
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
