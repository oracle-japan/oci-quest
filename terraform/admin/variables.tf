### Terraform OCI Provider
variable "region" {
}

variable "tenancy_ocid" {
}

variable "members_file" {
  type = string
  description = "Base64 encoded JSON string"
}

variable "compartment_ocid" {
}

variable "admin_user_ocids" {
  description = "開発メンバーのOCID"
  type = list(string)
}

variable "database_password" {
}

variable "database_password_secret_id" {
}

