output "storage_account_id" {
  value = azurerm_storage_account.adls.id
}

output "storage_account_name" {
  value = azurerm_storage_account.adls.name
}

output "primary_dfs_endpoint" {
  value = azurerm_storage_account.adls.primary_dfs_endpoint
}

output "containers" {
  value = {
    for k, v in azurerm_storage_container.containers : k => v.id
  }
}