#!/bin/bash
# shellcheck disable=SC2154,SC2086

# ssh-init.sh - Initialization script to configure SSH to other VM

# Set up SSH private key for the user
mkdir -p /home/${admin_username}/.ssh
chmod 700 /home/${admin_username}/.ssh

# Create the private key file
cat >/home/${admin_username}/.ssh/id_rsa <<'EOF'
${private_key}
EOF

chmod 600 /home/${admin_username}/.ssh/id_rsa
chown -R "${admin_username}":"${admin_username}" /home/${admin_username}/.ssh

# Configure SSH client for easier connections
cat >/home/${admin_username}/.ssh/config <<'EOF'
Host *
    StrictHostKeyChecking no
    UserKnownHostsFile=/dev/null
    LogLevel ERROR
EOF

chmod 600 /home/${admin_username}/.ssh/config
chown "${admin_username}":"${admin_username}" /home/${admin_username}/.ssh/config
