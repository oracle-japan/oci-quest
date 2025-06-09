variable "tenancy_ocid" {
  type        = string
  description = "OCID of the compartment where resources will be created"
}

variable "compartment_ocid" {
  type        = string
  description = "The OCID of the compartment where resources will be created."  
}

variable "team_name" {
  type        = string
  description = "The name of the team"
}

variable "image_file_path" {
  type = string
}

variable "mushop_wallet" {
  type        = string
  description = "The content of the Mushop wallet"
}

variable "region" {
  type        = string
  description = "The OCI region where resources will be created"
}