variable "location" {
  type    = string
  default = "eastus"
}

variable "prefix" {
  type    = string
  default = "assess"
}

variable "admin_username" {
  type    = string
  default = "azureadmin"
}

variable "admin_password" {
  type      = string
  sensitive = true
}

variable "web_vm_count" {
  type    = number
  default = 2
}

variable "web_vm_size" {
  type    = string
  default = "Standard_D2s_v3"
}

variable "db_vm_size" {
  type    = string
  default = "Standard_D4s_v3"
}

variable "tenant_id" {
  type        = string
  description = "Azure tenant ID for Key Vault access policy"
}

variable "sql_admin_username" {
  description = "Administrator username for the SQL Server"
  type        = string
}

variable "sql_admin_password" {
  description = "Administrator password for the SQL Server"
  type        = string
  sensitive   = true
}

variable "subscription_id" {
  description = "Azure subscription ID to deploy resources into"
  type        = string
}
