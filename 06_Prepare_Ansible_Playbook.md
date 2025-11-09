# 6 — Create a simple Ansible playbook (example: install Nginx)

- Create playbook.yml:

```yaml
---
- name: Configure web server on Azure VM
  hosts: web
  become: yes
  tasks:
    - name: Update apt cache
      apt:
        update_cache: yes
        cache_valid_time: 3600

    - name: Install nginx
      apt:
        name: nginx
        state: present

    - name: Ensure nginx is running and enabled
      service:
        name: nginx
        state: started
        enabled: yes

    - name: Create /var/www/html/index.html
      copy:
        dest: /var/www/html/index.html
        content: "<h1>Hello from Terraform + Ansible on Azure</h1>"
        owner: www-data
        group: www-data
        mode: '0644'
```

What this does: updates apt, installs nginx, ensures service is running, and writes a simple index page.

- Run the playbook:

```bash
ansible-playbook -i hosts playbook.yml --private-key ~/.ssh/id_rsa_azure
```

What this does: Ansible connects to the VM via SSH (private key) and executes the tasks using the apt and service modules. You’ll see per-task output (changed/ok/failure).

- To verify, open http://<VM_IP>/ in your browser — you should see the index page.
