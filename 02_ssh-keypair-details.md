# SSH Keypair for Terraform + Ansible — Detailed Guide

> Create an SSH keypair on WSL/Ubuntu that Terraform will upload to an Azure VM and Ansible will use to SSH into that VM.

---

## 1 — Where to run

Run *all* commands in your **WSL Ubuntu shell** (not Windows PowerShell). The keys will be created under your WSL user's home directory: `~/.ssh/`.

Open the Ubuntu app from Start or run `wsl` in PowerShell to enter the Linux shell.

---

## 2 — Exact commands

```bash
# 1) ensure .ssh directory exists
mkdir -p ~/.ssh

# 2) create SSH keypair (RSA 4096-bit) without passphrase (for automation)
ssh-keygen -t rsa -b 4096 -f ~/.ssh/id_rsa_azure -C "azure-terraform-ansible" -N ""

# 3) set secure permissions on private key
chmod 600 ~/.ssh/id_rsa_azure

# 4) list created files
ls -l ~/.ssh/id_rsa_azure*
```

### Quick explanation of the flags used
- `ssh-keygen` — command to generate an SSH keypair.
- `-t rsa` — selects RSA algorithm (widely supported). Alternatives: `ed25519` (modern, shorter keys).
- `-b 4096` — key size in bits (4096 is stronger than the default 2048).
- `-f ~/.ssh/id_rsa_azure` — output filename for the private key (private key) and `~/.ssh/id_rsa_azure.pub` (public key).
- `-C "azure-terraform-ansible"` — comment embedded inside the key (useful to identify the key later).
- `-N ""` — empty passphrase (automated use). If you want a passphrase, remove `-N ""` and you'll be prompted to enter one.

---

## 3 — What gets created and where

- `~/.ssh/id_rsa_azure` — **private key** (keep this secret!). Used by Ansible (or `ssh`) to authenticate to the VM.
- `~/.ssh/id_rsa_azure.pub` — **public key**. This is the key you give to remote servers (Terraform will embed this into the VM's `~/.ssh/authorized_keys` for the chosen admin user).
- `~/.ssh/known_hosts` — will be populated later when you first SSH into a host.

**Do NOT share the private key.** You may safely share the public key or paste it into cloud portals / Terraform configs.

---

## 4 — Why we do this (conceptually)

- SSH (Secure Shell) uses *public-key cryptography* for authentication:
  - The **private key** is kept secret by you (client).
  - The **public key** is placed on the server in the `~/.ssh/authorized_keys` file for the target user.
  - During SSH handshake the server verifies possession of the private key without the private key ever leaving the client machine.
- For Terraform + Azure:
  - Terraform can upload the public key to the VM when provisioning (so your key is the authorized method to SSH in).
- For Ansible:
  - Ansible is agentless and uses SSH to connect. The private key is used to authenticate automatically, enabling Ansible to run playbooks non-interactively.

---

## 5 — Internals: What happens when you run `ssh-keygen`

1. `ssh-keygen` chooses an RSA key pair generation routine (based on `-t` and `-b`) and uses your system's entropy source to generate a random private key.
2. It derives the corresponding public key from the private key.
3. It writes two files:
   - the private key file (PEM-like format) at the path you provided (`-f`).
   - the public key file (single-line `ssh-rsa AAAAB3... comment`) with a `.pub` suffix.
4. If a passphrase is provided, the private key file is encrypted with a symmetric cipher using that passphrase. If you used `-N ""`, the private key is stored unencrypted on disk (so anyone who gains the file can use it).
5. The public key file contains a single line suitable to paste into `~/.ssh/authorized_keys` on remote systems.

---

## 6 — Using the keys with Terraform

In Terraform you can reference the public key file when creating a VM. Example HCL snippet (Terraform `admin_ssh_key` block for Azure Linux VM):

```hcl
admin_ssh_key {
  username   = var.admin_username
  public_key = file("~/.ssh/id_rsa_azure.pub")
}
```

**What this does:** Terraform reads your local `id_rsa_azure.pub` file and embeds the public key into the VM's `~/<admin_username>/.ssh/authorized_keys` so that your private key can be used to SSH in.

---

## 7 — Using the keys with Ansible

Create a simple `hosts` file with the VM public IP, instructing Ansible to use the private key:

```
[web]
1.2.3.4 ansible_user=azureuser ansible_private_key_file=~/.ssh/id_rsa_azure
```

Run playbook:

```bash
ansible-playbook -i hosts playbook.yml --private-key ~/.ssh/id_rsa_azure
```

Ansible will use the private key to authenticate to the VM's sshd and run tasks.

---

## 8 — Security considerations & best practices

- **Private key protection:** Keep `~/.ssh/id_rsa_azure` private and never push it to GitHub. Add it to `~/.gitignore`.
- **Use a passphrase if possible:** If you can provide a passphrase (and unlock the key automatically via `ssh-agent`), this adds protection if the private key file is compromised.
  - To use `ssh-agent` in WSL:
    ```bash
    eval "$(ssh-agent -s)"
    ssh-add ~/.ssh/id_rsa_azure
    ```
- **Permissions:** SSH will refuse to use a private key file with world-readable permissions. Use `chmod 600 ~/.ssh/id_rsa_azure`.
- **Rotate keys regularly** and remove public keys from servers you no longer use.
- **Limit scope**: On cloud VMs, create separate keys per environment (dev/staging/prod) or per user to avoid blast radius.
- **Use stronger algorithms if supported**: `ed25519` is modern, smaller and faster; you can create with `ssh-keygen -t ed25519 -f ~/.ssh/id_ed25519_azure`.

---

## 9 — How to verify the keys

- Show the public key (safe to display):
  ```bash
  cat ~/.ssh/id_rsa_azure.pub
  ```
  You should see a single line starting with `ssh-rsa AAAAB3... azure-terraform-ansible`.

- Try SSH locally to a host (after Terraform creates the VM):
  ```bash
  ssh -i ~/.ssh/id_rsa_azure azureuser@<VM_IP> 'uname -a; whoami'
  ```

- Check file timestamps and permissions:
  ```bash
  ls -l ~/.ssh/id_rsa_azure*
  ```

Example `ls -l` output:

```
-rw------- 1 user user  3243 Nov  9 22:10 /home/user/.ssh/id_rsa_azure
-rw-r--r-- 1 user user   740 Nov  9 22:10 /home/user/.ssh/id_rsa_azure.pub
```

---

## 10 — Backup & revoke strategy

- **Backup:** Securely store a backup of the private key (if you rely on it) in an encrypted password manager or encrypted storage.
- **Revoke:** To revoke access, remove the corresponding public key line from `~/.ssh/authorized_keys` on the VM(s). For cloud-managed machines, update provisioning scripts (Terraform, cloud-init) and rotate keys across instances.

---

## 11 — Windows-specific notes (if you later SSH from Windows)

If you want to use the same key from Windows native tools (e.g., PuTTY or Windows OpenSSH), you may need to:
- Convert OpenSSH private key to PuTTY `.ppk` with PuTTYgen, or
- Use Windows' OpenSSH by copying the key into `%USERPROFILE%\.ssh\` or by referencing the WSL key via path conversion (WSL stores Linux files under `\\wsl$\Ubuntu\home\<user>\.ssh\`).

Prefer running Ansible/Terraform **from WSL**, because path and permission behavior is Linux-native and avoids confusion.

---

## 12 — Example `.gitignore` snippet

```
# SSH private keys
.ssh/id_rsa_azure
.ssh/id_ed25519_azure

# Terraform state
terraform.tfstate
terraform.tfstate.backup
```

---

## 13 — Final checklist

- [ ] Created `~/.ssh/id_rsa_azure` and `~/.ssh/id_rsa_azure.pub`
- [ ] Set `chmod 600` on private key
- [ ] Added private key to `ssh-agent` (optional)
- [ ] Added `id_rsa_azure` to `.gitignore` for repos
- [ ] Verified `cat ~/.ssh/id_rsa_azure.pub` and `ssh -i ...` connectivity after provisioning

---

## 14 — Paste-ready snippet (copy and run in WSL)

```bash
mkdir -p ~/.ssh
ssh-keygen -t rsa -b 4096 -f ~/.ssh/id_rsa_azure -C "azure-terraform-ansible" -N ""
chmod 600 ~/.ssh/id_rsa_azure
ls -l ~/.ssh/id_rsa_azure*
```

