# 5 — Prepare Ansible inventory using Terraform output

- After apply, get VM public IP:
bash
```
VM_IP=$(terraform output -raw vm_public_ip)
echo "VM IP: $VM_IP"
```

- Create an Ansible inventory file named hosts in the same folder:

```bash
cat > hosts <<EOF
[web]
${VM_IP} ansible_user=azureuser ansible_private_key_file=~/.ssh/id_rsa_azure ansible_host=${VM_IP}
EOF
```


What this does: creates a simple inventory group [web] with the VM's public IP and instructs Ansible to connect as azureuser using the private key we generated earlier.

- Confirm you can SSH (test):
```bash
ssh -i ~/.ssh/id_rsa_azure azureuser@${VM_IP} 'uname -a && lsb_release -a'
```

What this does: tests SSH connectivity to the VM. If SSH fails, check NSG rules, public IP, or correct private key permissions (chmod 600 ~/.ssh/id_rsa_azure).
