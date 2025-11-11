# 5 — Prepare Ansible Inventory Using Terraform Output

> Create a minimal Ansible inventory from the Terraform output so Ansible can connect to your newly created VM.

## Where to run
- Inside your Terraform project directory in the WSL Ubuntu shell (after you have applied the Terraform configuration).

## Prerequisites
- `terraform apply` has finished successfully.
- Terraform exposes a raw output named `vm_public_ip`.
- Your SSH private key exists at `~/.ssh/id_rsa_azure` with permissions `chmod 600`.

## 1) Capture the VM public IP
```bash
VM_IP=$(terraform output -raw vm_public_ip)
echo "VM IP: $VM_IP"
```

## 2) Generate the Ansible inventory
Create an `hosts` inventory file in the same folder:

```bash
cat > hosts <<EOF
[web]
${VM_IP} ansible_user=azureuser ansible_private_key_file=~/.ssh/id_rsa_azure ansible_host=${VM_IP}
EOF
```

What this does: creates a simple inventory group `[web]` with the VM's public IP and instructs Ansible to connect as `azureuser` using the specified private key.

## 3) Verify SSH connectivity
```bash
ssh -i ~/.ssh/id_rsa_azure azureuser@${VM_IP} 'uname -a && lsb_release -a'
```

What this does: tests SSH connectivity to the VM. If SSH fails, check the NSG rules for port 22, confirm the public IP, and ensure the private key permissions are correct (`chmod 600 ~/.ssh/id_rsa_azure`).
