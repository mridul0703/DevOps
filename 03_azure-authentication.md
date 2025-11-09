# Authenticate to Azure from WSL — Developer vs CI

**File:** `azure-authentication.md`  
**Purpose:** Authenticate to Azure from WSL for use with Terraform and Ansible.

---

## 1 — Where to run

All commands in this section are executed **inside WSL Ubuntu shell** (not PowerShell).  
You must have already installed the [Azure CLI](https://learn.microsoft.com/en-us/cli/azure/install-azure-cli) as covered in the earlier setup guide.

---

## 2 — Why authentication is needed

Terraform’s Azure provider and Ansible modules both need valid Azure credentials to:
- Create and manage cloud resources (VMs, networks, disks, etc.)
- Query existing resources during automation
- Avoid interactive sign-ins during CI/CD or automated deployments

Azure CLI handles the authentication and caches tokens locally for Terraform to reuse.

---

## 3 — Two authentication methods

You can authenticate in **two ways**, depending on your environment:

| Mode | Suitable for | Auth Type | Description |
|------|---------------|-----------|--------------|
| **Developer mode** | Local development | Interactive user login | Quick and easy via `az login`, uses your user account |
| **Service Principal (CI/CD)** | Automation pipelines | App registration credentials | Scriptable and secure for Terraform and Ansible automation |

---

## 4 — Option A: Developer Mode (Interactive)

### Command

```bash
az login
```

### What happens
- Azure CLI launches a browser window or gives you a **device login code**.
- You sign in with your Azure credentials (e.g., your Microsoft or work account).
- Once successful, a **refresh token** is stored in:
  ```
  ~/.azure/
  ```
  under files like `accessTokens.json`.
- This token allows Terraform (via the Azure provider) and Ansible modules to authenticate transparently without needing credentials in environment variables.

### Why use this
- Ideal for **local testing or exploration**.
- No need to handle sensitive credentials.
- Automatically expires and refreshes through your CLI session.

### Verify login
```bash
az account show
```

**Expected output:** your current subscription details.

### Select a specific subscription (if you have multiple)
```bash
az account set --subscription "<SUBSCRIPTION_ID>"
```

---

## 5 — Option B: Service Principal (for CI/CD automation)

When automating infrastructure creation (Terraform runs in pipelines), we avoid interactive logins. Instead, we create a **Service Principal (SP)** — an identity with a defined role (e.g., Contributor) within your Azure AD tenant.

### Command to create SP

```bash
az ad sp create-for-rbac --name "tf-ansible-sp-$(date +%s)" --role Contributor --scopes /subscriptions/<SUBSCRIPTION_ID>
```

Replace `<SUBSCRIPTION_ID>` with your real Azure Subscription ID.

### What this does
- Creates an **App Registration** in Azure AD.
- Generates a **Service Principal** (a non-human identity).
- Assigns the **Contributor** role at the specified scope (your subscription).
- Outputs credentials in JSON format containing:

```json
{
  "appId": "xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx",
  "displayName": "tf-ansible-sp-<timestamp>",
  "password": "xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx",
  "tenant": "xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx"
}
```

### Important fields
| Field | Meaning |
|--------|----------|
| `appId` | The client ID (used by Terraform as `ARM_CLIENT_ID`) |
| `password` | The client secret (used as `ARM_CLIENT_SECRET`) |
| `tenant` | Your Azure AD tenant ID (used as `ARM_TENANT_ID`) |
| `subscription` | The subscription you’ll deploy into (used as `ARM_SUBSCRIPTION_ID`) |

---

## 6 — Export environment variables for Terraform

After creating the SP, export these variables in your WSL session:

```bash
export ARM_CLIENT_ID="<appId>"
export ARM_CLIENT_SECRET="<password>"
export ARM_TENANT_ID="<tenant>"
export ARM_SUBSCRIPTION_ID="<SUBSCRIPTION_ID>"
```

**What happens here:**
- Terraform uses these environment variables automatically for Azure authentication.
- When you run `terraform plan` or `terraform apply`, the provider plugin reads them to create an authenticated session.

You can confirm by running:
```bash
env | grep ARM_
```

If everything is set correctly, you should see the exported environment variables.

---

## 7 — Security best practices

- **Never commit SP credentials** to source control.  
  Add them to your `.gitignore` or manage via CI/CD secrets.
- **Use limited-scope SPs:** only assign permissions needed for the job (e.g., `Contributor` or `Virtual Machine Contributor`).
- **Rotate secrets regularly:** SP passwords can be rotated using:
  ```bash
  az ad app credential reset --id <appId>
  ```
- **Store securely:** In CI/CD tools (e.g., GitHub Actions, Azure DevOps), store these secrets as encrypted variables.

---

## 8 — Verifying your Service Principal login

Test authentication:

```bash
az login --service-principal -u $ARM_CLIENT_ID -p $ARM_CLIENT_SECRET --tenant $ARM_TENANT_ID
```

Then verify the active subscription:

```bash
az account show
```

Expected output: subscription details confirming access with your SP identity.

---

## 9 — Example Terraform provider block (for context)

```hcl
provider "azurerm" {
  features {}

  client_id       = var.client_id
  client_secret   = var.client_secret
  tenant_id       = var.tenant_id
  subscription_id = var.subscription_id
}
```

Or rely directly on the exported environment variables (preferred for CI/CD).

---

## 10 — Developer vs CI comparison summary

| Feature | Developer Login (`az login`) | Service Principal (`az ad sp create-for-rbac`) |
|----------|------------------------------|------------------------------------------------|
| Interaction | Browser-based | Script-based |
| Suitable for | Manual/local work | Automation (Terraform, Ansible, pipelines) |
| Token storage | Cached in `~/.azure` | Stored in env vars or CI secrets |
| Expiration | Refresh token auto-renewed | Password/secret expiry (default 1 year) |
| Security | Uses user identity | Uses dedicated app identity |

---

## 11 — Quick commands recap

**For developers:**
```bash
az login
az account show
```

**For CI/CD automation:**
```bash
az ad sp create-for-rbac --name "tf-ansible-sp-$(date +%s)" --role Contributor --scopes /subscriptions/<SUBSCRIPTION_ID>
export ARM_CLIENT_ID="<appId>"
export ARM_CLIENT_SECRET="<password>"
export ARM_TENANT_ID="<tenant>"
export ARM_SUBSCRIPTION_ID="<SUBSCRIPTION_ID>"
```

---

## 12 — Troubleshooting

- **Error:** “Insufficient privileges to complete the operation”  
  → You need Azure AD admin permissions to create SPs, or request one from your admin.

- **Error:** “No subscriptions found”  
  → Verify your account/subscription using `az account list`.

- **Terraform error:** “InvalidClientSecret”  
  → Check that your exported secrets match exactly what was output by the SP creation command.

---

## 13 — References

- [Azure CLI authentication methods](https://learn.microsoft.com/en-us/cli/azure/authenticate-azure-cli)
- [Terraform Azure Provider Authentication Docs](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/guides/service_principal_client_secret)
- [Azure AD Service Principals](https://learn.microsoft.com/en-us/azure/active-directory/develop/app-objects-and-service-principals)

---
