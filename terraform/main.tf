terraform {
  required_version = ">= 1.5.0"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.0"
    }
  }
}

provider "azurerm" {
  features {}
}

# --- Random Suffix for Global Uniqueness ---
resource "random_string" "suffix" {
  length  = 6
  special = false
  upper   = false
}

# --- Resource Group ---
resource "azurerm_resource_group" "rg" {
  name     = "rg-data-platform-dev-01"
  location = var.location
}

# --- ADLS Gen2 Storage Account ---
resource "azurerm_storage_account" "adls" {
  name                     = "stmedallion${random_string.suffix.result}"
  resource_group_name      = azurerm_resource_group.rg.name
  location                 = azurerm_resource_group.rg.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
  account_kind             = "StorageV2"
  is_hns_enabled           = true

  tags = {
    Environment = var.environment
    Project     = "MedallionDataPlatform"
  }
}

# --- Medallion Architecture Storage Containers ---
resource "azurerm_storage_container" "containers" {
  for_each              = toset(["bronze", "silver", "gold"])
  name                  = each.key
  storage_account_name  = azurerm_storage_account.adls.name
  container_access_type = "private"
}