variable "members_file" {
  description = "Path to the file containing the members to be created in the identity module."
  type        = string
}

variable "tenancy_ocid" {
  description = "The OCID of the tenancy."
  type        = string
}


variable "region" {
}

variable "current_user_ocid" {
}

variable "database_password_secret_id" {
  description = "Secret ID for the database password"
  type        = string
}

variable "database_password" {
  description = "Password for the Autonomous Database"
  type        = string
}

variable "public_key" {
  description = "Public key for the OCI Quest"
  type        = string
}