#!/bin/bash

if [[ $EUID -ne 0 ]]; then
   exit 1
fi

GROUP_NAME="smbgroup"
SHARE_PATH=""
USER_LIST=("")

if ! getent group "$GROUP_NAME" >/dev/null; then
    groupadd "$GROUP_NAME"
fi

if [ ! -d "$SHARE_PATH" ]; then
    mkdir -p "$SHARE_PATH"
fi

chown :"$GROUP_NAME" "$SHARE_PATH"
chmod 2775 "$SHARE_PATH"

read -sp "Enter the SMB password: " PASS_VAR
echo

for username in "${USER_LIST[@]}"
do
    if id "$username" &>/dev/null; then
        printf "%s\n%s\n" "$PASS_VAR" "$PASS_VAR" | smbpasswd -s -a "$username"
        smbpasswd -e "$username" &>/dev/null
        
        if ! id -nG "$username" | grep -qw "$GROUP_NAME"; then
            usermod -aG "$GROUP_NAME" "$username"
            echo "Updated, Enabled, and Added to $GROUP_NAME: $username"
        else
            echo "Updated and Enabled: $username"
        fi
    else
        echo "Skip: $username (System user not found)"
    fi
done

unset PASS_VAR
history -c
