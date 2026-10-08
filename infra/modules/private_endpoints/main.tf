# --- 1. Private DNS Zones ---
resource "azurerm_private_dns_zone" "dns_kv" {
  name                = "privatelink.vaultcore.azure.net"
  resource_group_name = var.resource_group_name
  tags                = var.tags
}

resource "azurerm_private_dns_zone" "dns_dfs" {
  name                = "privatelink.dfs.core.windows.net"
  resource_group_name = var.resource_group_name
  tags                = var.tags
}

resource "azurerm_private_dns_zone" "dns_blob" {
  name                = "privatelink.blob.core.windows.net"
  resource_group_name = var.resource_group_name
  tags                = var.tags
}

# --- 2. VNet Links ---
resource "azurerm_private_dns_zone_virtual_network_link" "link_kv" {
  name                  = "link-kv-vnet"
  resource_group_name   = var.resource_group_name
  private_dns_zone_name = azurerm_private_dns_zone.dns_kv.name
  virtual_network_id    = var.vnet_id
}

resource "azurerm_private_dns_zone_virtual_network_link" "link_dfs" {
  name                  = "link-dfs-vnet"
  resource_group_name   = var.resource_group_name
  private_dns_zone_name = azurerm_private_dns_zone.dns_dfs.name
  virtual_network_id    = var.vnet_id
}

resource "azurerm_private_dns_zone_virtual_network_link" "link_blob" {
  name                  = "link-blob-vnet"
  resource_group_name   = var.resource_group_name
  private_dns_zone_name = azurerm_private_dns_zone.dns_blob.name
  virtual_network_id    = var.vnet_id
}

# --- 3. Key Vault Private Endpoint ---
resource "azurerm_private_endpoint" "pe_kv" {
  name                = "pe-kv-dev"
  location            = var.location
  resource_group_name = var.resource_group_name
  subnet_id           = var.subnet_id

  private_service_connection {
    name                           = "psc-kv"
    private_connection_resource_id = var.key_vault_id
    subresource_names              = ["vault"]
    is_manual_connection           = false
  }

  private_dns_zone_group {
    name                 = "dns-group-kv"
    private_dns_zone_ids = [azurerm_private_dns_zone.dns_kv.id]
  }

  tags = var.tags
}

# --- 4. ADLS Gen2 DFS Private Endpoint ---
resource "azurerm_private_endpoint" "pe_dfs" {
  name                = "pe-adls-dfs-dev"
  location            = var.location
  resource_group_name = var.resource_group_name
  subnet_id           = var.subnet_id

  private_service_connection {
    name                           = "psc-adls-dfs"
    private_connection_resource_id = var.storage_account_id
    subresource_names              = ["dfs"]
    is_manual_connection           = false
  }

  private_dns_zone_group {
    name                 = "dns-group-dfs"
    private_dns_zone_ids = [azurerm_private_dns_zone.dns_dfs.id]
  }

  tags = var.tags
}

# --- 5. ADLS Gen2 Blob Private Endpoint ---
resource "azurerm_private_endpoint" "pe_blob" {
  name                = "pe-adls-blob-dev"
  location            = var.location
  resource_group_name = var.resource_group_name
  subnet_id           = var.subnet_id

  private_service_connection {
    name                           = "psc-adls-blob"
    private_connection_resource_id = var.storage_account_id
    subresource_names              = ["blob"]
    is_manual_connection           = false
  }

  private_dns_zone_group {
    name                 = "dns-group-blob"
    private_dns_zone_ids = [azurerm_private_dns_zone.dns_blob.id]
  }

  tags = var.tags
}