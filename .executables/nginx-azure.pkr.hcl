packer {
  required_plugins {
    azure = {
      version = ">= 1.0.0"
      source  = "github.com/hashicorp/azure"
    }
  }
}

variable "client_id" {
  default = "<>"
  type = string
}

variable "client_secret" {
  default = "<>"
  type = string
  sensitive = true
}

variable "subscription_id" {
  default = "<>"
  type = string
}

variable "tenant_id" {
  default = "<>"
  type = string
}

variable "resource_group" {
  type    = string
  default = "packer-images-rg"
}

variable "location" {
  type    = string
  default = "eastasia"
}

source "azure-arm" "nginx" {
  # Image output details
  managed_image_name                = "nginx-vm-image-me"
  managed_image_resource_group_name = var.resource_group
  location                          = var.location

  # Base image (Ubuntu 20.04 LTS)
  os_type          = "Linux"
  image_publisher  = "Canonical"
  image_offer      = "0001-com-ubuntu-server-focal"
  image_sku        = "20_04-lts"

  # Azure Authentication (Service Principal)
  client_id       = var.client_id
  client_secret   = var.client_secret
  subscription_id = var.subscription_id
  tenant_id       = var.tenant_id

  # VM Setup
  ssh_username = "azureuser"
  vm_size      = "Standard_B1s"

  azure_tags = {
    environment = "dev"
    purpose     = "nginx-image"
  }
}

build {
  name    = "nginx-image-build"
  sources = ["source.azure-arm.nginx"]

  provisioner "shell" {
  inline = [
    "sleep 15", # wait for cloud-init / apt locks
    "sudo apt-get update -y",
    "sudo apt-get install -y nginx",
    "sudo systemctl enable nginx",
    "sudo systemctl start nginx"
    ]
  }
}