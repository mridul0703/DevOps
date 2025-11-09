# Setup Guide — WSL2 + Ubuntu on Windows 11, then install Azure CLI, Terraform, Ansible, Git & jq

> A GitHub-friendly step‑by‑step markdown guide to prepare a Windows 11 machine (via WSL2/Ubuntu) for provisioning Azure VMs with Terraform and configuring them with Ansible.

---

## Summary
This guide walks a complete beginner through:

1. Installing **WSL2** and **Ubuntu** on Windows 11 (where you will run most commands).
2. Installing required tools inside the WSL Ubuntu shell:
   - `az` (Azure CLI)
   - `terraform`
   - `ansible`
   - `git` (recommended)
   - `jq` (optional helper for scripts)
3. Verifying installations and basic troubleshooting pointers.

Each step includes: *where to run the commands*, the exact commands to run, and *what each command does and why*.

---

## Prerequisites
- Windows 11 with administrator access (to enable WSL).
- Internet connection (to download packages).
- An Azure account (for later provisioning; not required for this setup phase).

---

## Folder & environment conventions used in this guide
- All Linux commands must be run **inside WSL/Ubuntu** unless the step explicitly says to run in Windows PowerShell (Admin).
- Files you create in WSL will be under your Linux home directory, e.g. `/home/<your-linux-username>/`.

---

## 1 — Install WSL2 and Ubuntu (on Windows 11)
**Where to run:** Windows **PowerShell as Administrator**

### Steps
1. Open **Start → type PowerShell → right-click → Run as administrator**.
2. Run the command below to install WSL2 and a default distro (Ubuntu):

```powershell
wsl --install
```

### What this command does and why
- `wsl --install` enables the Windows Subsystem for Linux feature, installs a Linux kernel, sets the default WSL version to **WSL2**, and installs a default Linux distribution (usually Ubuntu).
- This creates a proper Linux environment inside Windows where Linux tools (Terraform, Ansible, Azure CLI) run reliably.
- **After the command finishes you will likely be prompted to reboot**. Reboot to complete installation.

### What to do after reboot
- Open **Ubuntu** from the Start menu. The first run will ask you to create a Linux username and password. That creates your WSL home folder (e.g. `/home/<your-linux-username>/`).

---

## 2 — Install required tools in WSL/Ubuntu
**Where to run:** inside the **Ubuntu WSL shell** (open the Ubuntu app from Start)

We will install:
- `azure-cli` (Azure authentication & management)
- `terraform` (infrastructure provisioning)
- `ansible` (configuration management)
- `git` (optional, recommended)
- `jq` (optional helper for JSON parsing in shell scripts)

> **Tip:** Copy/paste blocks below into your WSL terminal. Run them step-by-step and read the explanations.

### 2.1 Update apt and install common utilities
**Commands**

```bash
# update package lists
sudo apt update

# install essential utilities
sudo apt install -y curl unzip git jq software-properties-common
```

**What this does & why**
- `sudo apt update` refreshes the package index so you get the latest package metadata.
- `sudo apt install -y ...` installs required utilities:
  - `curl` — download files from the web in scripts.
  - `unzip` — extract zipped archives.
  - `git` — clone repositories and track files (recommended when using GitHub).
  - `jq` — lightweight JSON processor (handy for CLI scripts).
  - `software-properties-common` — provides `add-apt-repository` used for PPAs.

These tools are foundational for later installation steps and automation.

---

### 2.2 Install Azure CLI (recommended via Microsoft script)
**Commands**

```bash
# Official Microsoft install script for Azure CLI (Debian/Ubuntu)
curl -sL https://aka.ms/InstallAzureCLIDeb | sudo bash

# verify install
az --version
```

**Where to run:** WSL Ubuntu shell

**What this does & why**
- The `curl | sudo bash` pattern downloads and runs Microsoft’s install script which:
  - Adds Microsoft’s apt repository to your system.
  - Installs the `az` package (Azure CLI) and its dependencies.
- `az` is used to authenticate to Azure (interactive `az login`) and to create service principals (automation-friendly credentials).
- `az --version` verifies the install and shows the installed version.

**Security note:** Running remote install scripts is convenient but carries risk; only run scripts from trusted publishers (this URL is Microsoft’s official install shortcut).

---

### 2.3 Install Terraform (official HashiCorp apt repository)
**Commands**

```bash
# add HashiCorp GPG key and repository
curl -fsSL https://apt.releases.hashicorp.com/gpg | sudo gpg --dearmor -o /usr/share/keyrings/hashicorp-archive-keyring.gpg
sudo apt-add-repository "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main"

# update apt and install terraform
sudo apt update
sudo apt install -y terraform

# verify
terraform -version
```

**Where to run:** WSL Ubuntu shell

**What this does & why**
- The first line downloads the HashiCorp GPG key and stores a keyring so apt can verify packages from the HashiCorp repository.
- `apt-add-repository` registers the HashiCorp apt repository for your Ubuntu release (so `terraform` packages are available).
- `sudo apt update` refreshes apt metadata now that the new repo is added.
- `sudo apt install -y terraform` installs Terraform CLI from HashiCorp’s repository.
- `terraform -version` confirms the installed Terraform binary.

Why Terraform? Terraform lets you declare cloud resources (VMs, networks) as code and apply those changes reliably.

---

### 2.4 Install Ansible (via Ansible PPA)
**Commands**

```bash
sudo apt update
sudo apt install -y software-properties-common
sudo add-apt-repository --yes --update ppa:ansible/ansible
sudo apt install -y ansible

# verify
ansible --version
```

**Where to run:** WSL Ubuntu shell

**What this does & why**
- Adds the official Ansible PPA to get a recent Ansible release for Ubuntu.
- Installs the `ansible` control utility. Ansible is used to connect (over SSH) to the VM and run tasks (install packages, start services).
- `ansible --version` verifies the installation.

Why Ansible? It’s an agentless configuration management tool that uses SSH to run idempotent tasks on remote machines.

---

## 3 — Post-install verification and quick tests
**Where to run:** WSL Ubuntu shell

### Verify installed tools
```bash
az --version         # Azure CLI
terraform -version   # Terraform
ansible --version    # Ansible
git --version        # Git
jq --version         # jq (optional)
```

**What this does:** Confirms all tools are installed and on your PATH. If any command fails, re-run the corresponding install step and inspect error messages.

### Quick SSH key suggestion (for later use with Terraform & Ansible)
Create an SSH keypair (you will use this to allow Ansible to SSH into provisioned VMs):

```bash
mkdir -p ~/.ssh
ssh-keygen -t rsa -b 4096 -f ~/.ssh/id_rsa_azure -C "azure-terraform-ansible" -N ""

# ensure correct permissions on the private key
chmod 600 ~/.ssh/id_rsa_azure
ls -l ~/.ssh/id_rsa_azure*  # check files
```

**What this does & why**
- `ssh-keygen` creates `~/.ssh/id_rsa_azure` (private) and `~/.ssh/id_rsa_azure.pub` (public). The public key is uploaded to VMs by Terraform so Ansible can SSH in.
- `chmod 600` ensures SSH will accept the private key’s permissions.

---

## 4 — Notes, safety & troubleshooting
- **Don’t commit** private keys or `terraform.tfstate` files to public GitHub repos. Add `~/.ssh/id_rsa_azure` and `terraform.tfstate` to `.gitignore` in projects.
- If `az` installation fails due to missing dependencies, re-run `sudo apt update` and inspect the error. The install script generally handles required packages.
- If `terraform` cannot be found after install, close and reopen the WSL terminal to refresh PATH, or run `hash -r`.
- If Ansible SSH tasks fail later: check VM's NSG (security group) allows SSH (port 22), ensure public IP is correct, ensure the private key matches the VM’s authorized key.

---

## 5 — What next (after this setup)
1. Authenticate to Azure from WSL:
   - Interactive: `az login` (opens browser flow).
   - CI/automation: create service principal and export `ARM_CLIENT_ID`, `ARM_CLIENT_SECRET`, `ARM_TENANT_ID`, `ARM_SUBSCRIPTION_ID` as environment variables.
2. Create a Terraform project folder (e.g. `~/azure-terraform-ansible`) and add `providers.tf`, `main.tf`, `variables.tf`, `outputs.tf`.
3. `terraform init`, `terraform plan`, `terraform apply` to create resources in Azure.
4. Use Terraform outputs (public IP) to build an Ansible `hosts` inventory and run `ansible-playbook` with your private key.

---

## 6 — Quick reference: commands & meanings
- `wsl --install` — installs WSL and a default Linux distro (Windows PowerShell Admin).
- `sudo apt update` — refresh package lists.
- `sudo apt install -y <packages>` — install packages non-interactively.
- `curl -sL <url> | sudo bash` — download and run an install script (use only for trusted sources).
- `ssh-keygen -t rsa -b 4096 -f ~/.ssh/id_rsa_azure` — create SSH keypair for remote auth.
- `terraform -version`, `ansible --version`, `az --version` — verify installations.

---

## 7 — License & attribution
This guide is provided as-is for instructional purposes. Commands reference official distributions and repos (Microsoft, HashiCorp, Ansible). Please follow your organization’s policies for secrets and production usage.

---

If you want, I can:
- Convert this into a ready-to-commit `README.md` for a GitHub repo (with `.gitignore` template), or
- Produce a single bash script to automate the WSL-side installs (I recommend running the script interactively and reviewing it first).

Which would you like next?

