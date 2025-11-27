# Module 3: Authenticate to Azure (Developer vs CI/CD)

## Overview

This module teaches how to authenticate with Azure in two modes: -
**Developer Mode** (Interactive login using Azure CLI) - **CI/CD Mode**
(Using Service Principal + Environment Variables)

Both approaches are essential for Terraform, Ansible, and automation
workflows.

------------------------------------------------------------------------

## 🔑 Authentication Modes

## 1️⃣ Developer Mode --- Interactive Login

For local development, testing, and manual provisioning.

### **Login to Azure**

``` bash
az login
```

A browser window will open for authentication.

### **Select Subscription (if multiple exist)**

``` bash
az account list --output table
az account set --subscription "<SUBSCRIPTION_ID>"
```

### **Verify Active Subscription**

``` bash
az account show
```

------------------------------------------------------------------------

## 2️⃣ CI/CD Mode --- Service Principal Authentication

Used for automation, pipelines, and non-interactive Terraform runs.

### **Create Service Principal**

``` bash
az ad sp create-for-rbac   --name "terraform-ansible-sp"   --role Contributor   --scopes /subscriptions/<SUBSCRIPTION_ID>   --sdk-auth
```

This returns: - `clientId` - `clientSecret` - `tenantId` -
`subscriptionId`

### **Export Required Environment Variables**

Terraform expects the following:

``` bash
export ARM_CLIENT_ID="<clientId>"
export ARM_CLIENT_SECRET="<clientSecret>"
export ARM_TENANT_ID="<tenantId>"
export ARM_SUBSCRIPTION_ID="<subscriptionId>"
```

To persist these values:

``` bash
echo 'export ARM_CLIENT_ID="<clientId>"' >> ~/.bashrc
echo 'export ARM_CLIENT_SECRET="<clientSecret>"' >> ~/.bashrc
echo 'export ARM_TENANT_ID="<tenantId>"' >> ~/.bashrc
echo 'export ARM_SUBSCRIPTION_ID="<subscriptionId>"' >> ~/.bashrc
source ~/.bashrc
```

------------------------------------------------------------------------

## 🧪 Verification

### **Check Azure Login / Subscription**

``` bash
az account show
```

### **Check Service Principal Environment Variables**

``` bash
env | grep ARM_
```

You should see:

    ARM_CLIENT_ID=xxxx
    ARM_CLIENT_SECRET=xxxx
    ARM_TENANT_ID=xxxx
    ARM_SUBSCRIPTION_ID=xxxx

------------------------------------------------------------------------

## 🎯 Hands-on Module Work

### ✔ Perform interactive `az login`

### ✔ Create and configure a Service Principal

### ✔ Export `ARM_*` variables

### ✔ Validate both authentication modes

------------------------------------------------------------------------

