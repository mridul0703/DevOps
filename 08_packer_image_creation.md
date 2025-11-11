# Creating Custom Azure Image using Packer

**Purpose:** Build a reusable Azure Managed Image with Nginx pre-installed using Packer, and use it later in Terraform deployments.

---

## 1 — Goal Overview

You’ll use:
- **Packer** → to create a custom Azure managed image (Ubuntu + Nginx)
- **Terraform** → to launch VMs using that custom image

**End Result:**  
A ready-to-use Azure Managed Image that can be referenced in Terraform to deploy pre-configured VMs with Nginx already installed and running.

---

## 2 — Prerequisites

Ensure these tools are installed locally on your machine (inside WSL if using Windows):

```bash
az version         # Azure CLI
packer --version   # Packer
terraform version  # Terraform
```

Login to Azure:

```bash
az login
```

If you use a **Service Principal** (recommended for automation), export the environment variables as below:

```bash
export ARM_CLIENT_ID="<appId>"
export ARM_CLIENT_SECRET="<password>"
export ARM_SUBSCRIPTION_ID="<subscriptionId>"
export ARM_TENANT_ID="<tenantId>"
```

These variables allow Packer and Terraform to authenticate non-interactively.

---

## 3 — Create the Packer Template

Create a file named **`nginx-azure.pkr.hcl`** in your project directory.

This file defines how Packer will create the image — which base OS to use, what software to install, and how to authenticate with Azure.

### File: `nginx-azure.pkr.hcl`

```hcl
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
      "sleep 15",
      "sudo apt-get update -y",
      "sudo apt-get install -y nginx",
      "sudo systemctl enable nginx",
      "sudo systemctl start nginx"
    ]
  }
}
```

---

## 4 — Initialize and Validate the Template

Before building, initialize Packer plugins and validate the template.

```bash
packer init .
packer validate nginx-azure.pkr.hcl
```

If successful, Packer confirms that your configuration is valid.

---

## 5 — Build the Image

Run the build command:

```bash
packer build nginx-azure.pkr.hcl
```

**What happens:**
1. Packer authenticates to Azure using your Service Principal or CLI session.
2. It creates a temporary resource group, storage, and VM.
3. Installs **Nginx** during provisioning.
4. Captures the VM as a **Managed Image**.
5. Cleans up temporary build resources.

After completion, your Azure resource group (`packer-images-rg`) will contain a managed image named **`nginx-vm-image-me`**.

---

## 6 — Verify the Managed Image

Check your resource group to confirm image creation:

```bash
az image list --resource-group packer-images-rg -o table
```

Expected output:
```
Name                ResourceGroup        Location    ProvisioningState
------------------  -------------------  ----------  -------------------
nginx-vm-image-me   packer-images-rg     eastasia    Succeeded
```

---

## 7 — Using the Image in Terraform

In your Terraform VM resource, reference the created image:

```hcl
resource "azurerm_linux_virtual_machine" "nginx_vm" {
  name                = "my-nginx-vm"
  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location
  size                = "Standard_B1s"
  admin_username      = "azureuser"

  network_interface_ids = [azurerm_network_interface.main.id]

  source_image_id = "/subscriptions/<SUBSCRIPTION_ID>/resourceGroups/packer-images-rg/providers/Microsoft.Compute/images/nginx-vm-image-me"

  admin_ssh_key {
    username   = "azureuser"
    public_key = file("~/.ssh/id_rsa.pub")
  }
}
```

---

## 8 — Customizing the Image Page (Optional)

You can edit the **default Nginx homepage** during image creation to include personal branding or project info.

For example, add this inside the Packer `provisioner "shell"` section:

```bash
echo '<!DOCTYPE html>
<html>
<head><title>Custom Image</title></head>
<body style="text-align:center; font-family:Arial; background:#f4f4f4; padding:40px;">
<h1>This image was built by Mridul M Kumar</h1>
<p><a href="https://github.com/mridul0703">GitHub</a> | 
<a href="https://github.com/mridul0703/DevOps">Project Repo</a></p>
<p>This image provisions a VM using Terraform, configures it via Ansible, and packages it into a reusable Azure image using Packer.</p>
<p>Thank you for visiting!</p>
</body>
</html>' | sudo tee /var/www/html/index.nginx-debian.html
```

This replaces the default Nginx homepage with a custom, professional message.

---

## 9 — Clean Up (Optional)

After testing, you can remove temporary or unused resources to save costs:

```bash
az image delete --name nginx-vm-image-me --resource-group packer-images-rg
```

---

## 10 — Troubleshooting

| Issue | Possible Cause | Fix |
|--------|----------------|-----|
| **Packer fails to authenticate** | Missing or incorrect environment variables | Recheck exported ARM credentials |
| **Build stuck at provisioning** | Apt locks or slow network | Add a small sleep delay before apt commands |
| **Image not found in Terraform** | Wrong image name or resource group | Verify via `az image list` |
| **Nginx not running** | Provisioning skipped or failed | Check `sudo systemctl status nginx` |

---

## 11 — References

- [Packer Azure Plugin Docs](https://developer.hashicorp.com/packer/plugins/builders/azure/arm)
- [Azure CLI Documentation](https://learn.microsoft.com/en-us/cli/azure/)
- [Terraform Azure Provider](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs)
- [Nginx Official Docs](https://nginx.org/en/docs/)

---
