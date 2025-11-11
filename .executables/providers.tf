terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0"
    }
  }
  required_version = ">= 1.0"
}

provider "azurerm" {
  features {}
  # Authentication:
  # - If you've done `az login` in this shell, provider will use Azure CLI authentication.
  # - If you exported ARM_* env vars (service principal), azurerm will use them instead.
}
