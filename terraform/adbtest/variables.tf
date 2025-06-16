variable "tenancy_ocid" {
  description = "The OCID of the tenancy."
  type        = string
}


variable "compartment_ocid" {
  description = "The OCID of the compartment."
  type        = string
}


variable "database_password_secret_id" {
  description = "Secret ID for the database password"
  type        = string
}

variable "database_password" {
  description = "Password for the Autonomous Database"
  type        = string
}