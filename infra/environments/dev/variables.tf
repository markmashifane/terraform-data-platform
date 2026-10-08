variable "resource_group_name" {
  type = string
}

variable "location" {
  type    = string
  default = "northeurope"
}

variable "storage_account_name" {
  type = string
}

variable "key_vault_name" {
  type = string
}

variable "tags" {
  type    = map(string)
  default = {}
}

variable "environment" {
  type        = string
  description = "The deployment environment (e.g., dev, prod)"
  default     = "dev"
}