locals {
  common_tags = {
    Environment = var.environment
    Project     = "DataPlatform"
    ManagedBy   = "Terraform"
  }
}

# 1. Resource Group
resource "azurerm_resource_group" "rg" {
  name     = var.resource_group_name
  location = var.location
  tags     = local.common_tags
}

# 2. Networking Module
module "networking" {
  source                = "../../modules/networking"
  resource_group_name   = azurerm_resource_group.rg.name
  location              = var.location
  vnet_name             = var.vnet_name
  vnet_address_space    = var.vnet_address_space
  subnet_address_prefix = var.subnet_address_prefix
  tags                  = local.common_tags
}

# 3. Security Module
module "security" {
  source              = "../../modules/security"
  resource_group_name = azurerm_resource_group.rg.name
  location            = var.location
  key_vault_name      = var.key_vault_name
  tenant_id           = data.azurerm_client_config.current.tenant_id
  tags                = local.common_tags
}

# 4. Storage Module
module "storage" {
  source               = "../../modules/storage"
  resource_group_name  = azurerm_resource_group.rg.name
  location             = var.location
  storage_account_name = var.storage_account_name
  tags                 = local.common_tags
}

# 5. Private Endpoints Module
module "private_endpoints" {
  source              = "../../modules/private_endpoints"
  resource_group_name = azurerm_resource_group.rg.name
  location            = var.location
  subnet_id           = module.networking.data_subnet_id
  vnet_id             = module.networking.vnet_id
  key_vault_id        = module.security.key_vault_id
  storage_account_id  = module.storage.storage_account_id
  tags                = local.common_tags
}

# Data source for tenant ID
data "azurerm_client_config" "current" {}