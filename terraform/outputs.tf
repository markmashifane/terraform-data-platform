output "resource_group_name" {
  description = "The name of the provisioned Azure Resource Group."
  value       = azurerm_resource_group.rg.name
}

output "storage_account_name" {
  description = "The globally unique name of the ADLS Gen2 Storage Account."
  value       = azurerm_storage_account.adls.name
}

output "storage_account_id" {
  description = "The Azure Resource Manager ID of the Storage Account."
  value       = azurerm_storage_account.adls.id
}

output "primary_dfs_endpoint" {
  description = "The primary Data Lake Storage Gen2 DFS endpoint (abfss:// target)."
  value       = azurerm_storage_account.adls.primary_dfs_endpoint
}

output "primary_blob_endpoint" {
  description = "The primary Blob storage endpoint."
  value       = azurerm_storage_account.adls.primary_blob_endpoint
}

output "medallion_containers" {
  description = "List of created Medallion Architecture containers."
  value       = [for container in azurerm_storage_container.containers : container.name]
}

output "primary_access_key" {
  description = "The primary access key for the storage account (marked sensitive)."
  value       = azurerm_storage_account.adls.primary_access_key
  sensitive   = true
}

output "primary_connection_string" {
  description = "The primary connection string for PySpark or local client integration (marked sensitive)."
  value       = azurerm_storage_account.adls.primary_connection_string
  sensitive   = true
}