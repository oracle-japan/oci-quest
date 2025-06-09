variable "team_name" {
  description = "The name of the team"
  type        = string
}

variable "compartment_ocid" {
  description = "The OCID of the compartment where resources will be created."
  type        = string
}

variable "database_password" {
  description = "Password for the Autonomous Database"
  type        = string
}

variable "tenancy_ocid" {
  description = "The OCID of the tenancy."
  type        = string
}

variable "region" {
  description = "The region where the resources will be created."
  type        = string
}

variable "subnet_ocid" {
  description = "value of subnet OCID"
  type        = string
}

variable "nsg_ocid" {
  description = "value of Network Security Group OCID"
  type        = string
}

variable "db_name" {
  description = "Name of the Autonomous Database"
  type        = string
}

variable "wallet_par_uri" {
  description = "Parameter URI for the wallet"
  type        = string
}

variable "public_key" {
  description = "Public key for SSH access"
  type        = string
}