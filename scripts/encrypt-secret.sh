#!/bin/bash

# Prompt for the key-value need encrypt
read -r -p "Enter the key to encrypt: " KEY
read -r -s -p "Enter the raw value to encrypt: " RAW_VALUE
echo
# Prompt for the vault password securely
read -r -s -p "Enter the vault password: " VAULT_PASS
echo

# Encrypt the key using ansible-vault
ENCRYPTED_VALUE=$(ansible-vault encrypt_string --vault-password-file <(echo "$VAULT_PASS") "$RAW_VALUE" --name "$KEY")

# Output the encrypted result
# echo "$KEY:"
echo "$ENCRYPTED_VALUE"
