# Ansible configurations

## Install on Ubuntu WLS

<https://docs.ansible.com/projects/ansible/latest/installation_guide/installation_distros.html#installing-ansible-on-ubuntu>

### Steps

1. Copy files and folders to `juronja/apps/ansible`
2. Restrict private key permissions

    ```shell
    chmod 600 ~/.ssh/id_proxmoxes
    chmod 600 ~/.ssh/id_hosting-prod
    chmod 600 ~/.ssh/id_ubuntu-homelab
    chmod 600 ~/.ssh/id_code-server
    ```

3. Run Ansible playbook with -K (for password input)

    ```shell
    ansible-playbook update-infrastructure.yaml -K
    ```
