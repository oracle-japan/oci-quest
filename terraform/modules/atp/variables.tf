variable "database_password" {
  description = "Password for the Autonomous Database"
  type        = string
}

variable "subnet_ocid" {
  description = "The OCID of the subnet where the Autonomous Database will be created."
  type        = string
}

variable "nsg_ocid" {
  description = "The OCID of the Network Security Group for the Autonomous Database."
  type        = string
}

variable "database_password_secret_id" {
  description = "Secret ID for the database password"
  type        = string
}

variable "compartment_ocid" {
  description = "The OCID of the compartment."
  type        = string
}

variable "team_name" {
  description = "The name of the team"
  type        = string
}
