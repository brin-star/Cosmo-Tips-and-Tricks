#!/bin/bash

############################################################
# ROCKY LINUX SSH USER HARDENING SCRIPT
#
# - Creates users if missing
# - Forces correct shell
# - Removes ANY existing authorized_keys
# - Installs trusted scoring key ONLY
# - Fixes permissions
# - Fixes SELinux context
############################################################

KEY_SOURCE="/home/blueteam/scoringkey.pub"
DEFAULT_SHELL="/bin/bash"
HOME_BASE="/home"

#FILL USERS HERE ~~~~~~~~~~~~~~~~~~~~~~~~~~~``
USERS=(

)

if [ ! -f "$KEY_SOURCE" ]; then
    echo "ERROR: Public key not found at $KEY_SOURCE"
    exit 1
fi

for USER in "${USERS[@]}"; do
    echo "--------------------------------------"
    echo "Processing user: $USER"

    HOME_DIR="$HOME_BASE/$USER"
    SSH_DIR="$HOME_DIR/.ssh"
    AUTH_KEYS="$SSH_DIR/authorized_keys"

    ####################################
    # Create user if missing
    ####################################
    if ! id "$USER" &>/dev/null; then
        echo "Creating user $USER"
        useradd -m -s "$DEFAULT_SHELL" "$USER"
    else
        echo "User exists — enforcing shell"
        usermod -s "$DEFAULT_SHELL" "$USER"
    fi

    ####################################
    # Ensure home exists
    ####################################
    if [ ! -d "$HOME_DIR" ]; then
        echo "Creating missing home directory"
        mkdir -p "$HOME_DIR"
    fi

    ####################################
    # Enforce proper home ownership
    ####################################
    chown "$USER:$USER" "$HOME_DIR"
    chmod 755 "$HOME_DIR"

    ####################################
    # Rebuild .ssh directory from scratch
    ####################################
    echo "Rebuilding .ssh directory"

    rm -rf "$SSH_DIR"
    mkdir -p "$SSH_DIR"

    ####################################
    # Install ONLY trusted key
    ####################################
    cp "$KEY_SOURCE" "$AUTH_KEYS"

    ####################################
    # Fix permissions
    ####################################
    chown -R "$USER:$USER" "$SSH_DIR"
    chmod 700 "$SSH_DIR"
    chmod 600 "$AUTH_KEYS"

    ####################################
    # Fix SELinux context (CRITICAL on Rocky)
    ####################################
    restorecon -Rv "$HOME_DIR"

    echo "SSH hardened for $USER"
done

####################################
# Restart SSH
####################################
echo "Restarting sshd..."
systemctl restart sshd

echo "--------------------------------------"
echo "All users hardened successfully."
echo "--------------------------------------"