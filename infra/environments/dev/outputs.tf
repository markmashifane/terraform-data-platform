# Resource Group Output
output "resource_group_name" {
  description = "The name of the deployed resource group"
  value       = azurerm_resource_group.rg.name
}

# Networking Outputs
output "vnet_id" {
  description = "The ID of the dev VNet"
  value       = module.networking.vnet_id
}

output "data_subnet_id" {
  description = "The ID of the dev Data Subnet"
  value       = module.networking.data_subnet_id
}

# Security Outputs
output "key_vault_uri" {
  description = "The URI of the Key Vault"
  value       = module.security.key_vault_uri
}

# Storage Outputs
output "storage_account_name" {
  description = "The name of the ADLS Gen2 Storage Account"
  value       = module.storage.storage_account_name
}

output "primary_dfs_endpoint" {
  description = "The DFS endpoint for ADLS Gen2"
  value       = module.storage.primary_dfs_endpoint
}

output "datalake_containers" {
  description = "The created Data Lake containers"
  value       = module.storage.containers
}