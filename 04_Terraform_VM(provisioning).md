# Module 4: Terraform Project Files (Azure VM)

## Overview

This module covers how to structure a **Terraform project** to deploy a
complete Azure Virtual Machine environment.\
You will create all essential Terraform files, configure Azure
resources, and deploy an Ubuntu 22.04 VM using SSH authentication.

------------------------------------------------------------------------

## 📁 Files You Will Create

Your Terraform project folder will contain:

    providers.tf
    variables.tf
    main.tf
    outputs.tf
    terraform.tfvars   (optional)

------------------------------------------------------------------------

## 🧱 providers.tf

Defines the AzureRM provider and required version:

``` hcl
terraform {
  required_version = ">= 1.5.0"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0"
    }
  }
}

provider "azurerm" {
  features {}
}
```

------------------------------------------------------------------------

## 🧩 variables.tf

Parameterize all key inputs:

``` hcl
variable "location" {
  type    = string
  default = "eastus"
}

variable "vm_size" {
  type    = string
  default = "Standard_B1s"
}

variable "admin_username" {
  type    = string
  default = "azureuser"
}

variable "ssh_public_key" {
  type = string
}
```

------------------------------------------------------------------------

## 🏗️ main.tf

Create Azure resources: RG → VNet/Subnet → NSG → Public IP → NIC → VM.

``` hcl
resource "azurerm_resource_group" "rg" {
  name     = "tf-rg"
  location = var.location
}

resource "azurerm_virtual_network" "vnet" {
  name                = "tf-vnet"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  address_space       = ["10.0.0.0/16"]
}

resource "azurerm_subnet" "subnet" {
  name                 = "tf-subnet"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.0.1.0/24"]
}

resource "azurerm_network_security_group" "nsg" {
  name                = "tf-nsg"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
}

resource "azurerm_network_security_rule" "ssh" {
  name                        = "SSH"
  priority                    = 1001
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "22"
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
  network_security_group_name = azurerm_network_security_group.nsg.name
  resource_group_name         = azurerm_resource_group.rg.name
}

resource "azurerm_network_security_rule" "http" {
  name                        = "HTTP"
  priority                    = 1002
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "80"
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
  network_security_group_name = azurerm_network_security_group.nsg.name
  resource_group_name         = azurerm_resource_group.rg.name
}

resource "azurerm_network_security_rule" "https" {
  name                        = "HTTPS"
  priority                    = 1003
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "443"
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
  network_security_group_name = azurerm_network_security_group.nsg.name
  resource_group_name         = azurerm_resource_group.rg.name
}

resource "azurerm_public_ip" "public_ip" {
  name                = "tf-public-ip"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  allocation_method   = "Dynamic"
}

resource "azurerm_network_interface" "nic" {
  name                = "tf-nic"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  ip_configuration {
    name                          = "ipconfig"
    subnet_id                     = azurerm_subnet.subnet.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.public_ip.id
  }
}

resource "azurerm_linux_virtual_machine" "vm" {
  name                = "tf-ubuntu-vm"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  size                = var.vm_size
  admin_username      = var.admin_username
  network_interface_ids = [
    azurerm_network_interface.nic.id
  ]

  admin_ssh_key {
    username   = var.admin_username
    public_key = var.ssh_public_key
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts"
    version   = "latest"
  }

  tags = {
    module = "terraform-vm"
  }
}
```

------------------------------------------------------------------------

## 📤 outputs.tf

Expose the public IP for SSH and Ansible:

``` hcl
output "vm_public_ip" {
  value = azurerm_public_ip.public_ip.ip_address
}
```

------------------------------------------------------------------------

## 🧮 Optional: terraform.tfvars

``` hcl
location     = "eastus"
vm_size      = "Standard_B1s"
ssh_public_key = file("~/.ssh/id_rsa_azure.pub")
```

------------------------------------------------------------------------

## ⚙️ Workflow Commands

Run these inside your Terraform project directory:

``` bash
terraform init
terraform validate
terraform plan
terraform apply
```

After apply completes, view your VM IP:

``` bash
terraform output vm_public_ip
```

------------------------------------------------------------------------

## 🧪 Hands-on Practice

### ✔ Parameterize location

### ✔ Parameterize VM size

### ✔ Add resource tags

### ✔ Modify configuration and safely re-apply (`terraform apply`)

### ✔ Retrieve the VM public IP

------------------------------------------------------------------------

