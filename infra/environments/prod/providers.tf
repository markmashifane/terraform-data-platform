terraform {
  required_version = ">= 1.5.0"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0"
    }
  }
  # Uncomment once remote backend SA is created:
  # backend "azurerm" {
  #   resource_group_name  = "rg-terraform-tfstate"
  #   storage_account_name = "sttfstateprod001"
  #   container_name       = "tfstate"
  #   key                  = "prod.terraform.tfstate"
  # }
}

provider "azurerm" {
  features {}
}
