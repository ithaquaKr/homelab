#!/bin/bash

# Prompt the user to enter the encrypted value
echo "Enter the encrypted value (end with Ctrl+D when done):"
ENCRYPTED_VALUE=$(cat | sed 's/^[[:space:]]*//')

# Prompt for the vault password securely
read -r -s -p "Enter the vault password: " VAULT_PASS
echo

# Decrypt the value using ansible-vault
DECRYPTED_VALUE=$(ansible-vault decrypt --vault-password-file <(echo "$VAULT_PASS") <<<"$ENCRYPTED_VALUE" 2>/dev/null)

# Check if decryption was successful
if [[ $? -eq 0 ]]; then
	echo "Decrypted value: $DECRYPTED_VALUE"
else
	echo "Error: Failed to decrypt. Check your vault password or encrypted value."
fi
