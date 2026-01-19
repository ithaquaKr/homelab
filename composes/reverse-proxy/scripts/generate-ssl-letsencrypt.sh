#!/bin/bash
# Generate SSL certificates using Let's Encrypt with certbot
# Usage: ./generate-ssl-letsencrypt.sh <domain> [email]
# Requires: certbot installed and DNS properly configured

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CERTS_DIR="${SCRIPT_DIR}/../certs"
HTML_DIR="${SCRIPT_DIR}/../html"
DOMAIN="${1}"
EMAIL="${2:-}"

if [ -z "${DOMAIN}" ]; then
    echo "Usage: $0 <domain> [email]"
    echo "Example: $0 example.com admin@example.com"
    exit 1
fi

# Create directories if they don't exist
mkdir -p "${CERTS_DIR}"
mkdir -p "${HTML_DIR}/.well-known/acme-challenge"

echo "Generating Let's Encrypt SSL certificate for: ${DOMAIN}"
echo "Output directory: ${CERTS_DIR}"
echo ""

# Check if certbot is installed
if ! command -v certbot &> /dev/null; then
    echo "Error: certbot is not installed."
    echo ""
    echo "Install certbot:"
    echo "  macOS:  brew install certbot"
    echo "  Ubuntu: sudo apt install certbot"
    echo "  CentOS: sudo yum install certbot"
    exit 1
fi

# Build certbot command
CERTBOT_CMD="certbot certonly --webroot"
CERTBOT_CMD+=" -w ${HTML_DIR}"
CERTBOT_CMD+=" -d ${DOMAIN}"

if [ -n "${EMAIL}" ]; then
    CERTBOT_CMD+=" --email ${EMAIL} --agree-tos --no-eff-email"
else
    CERTBOT_CMD+=" --register-unsafely-without-email --agree-tos"
fi

echo "Running: ${CERTBOT_CMD}"
echo ""

# Run certbot
eval "${CERTBOT_CMD}"

# Copy certificates to our certs directory
LETSENCRYPT_DIR="/etc/letsencrypt/live/${DOMAIN}"

if [ -d "${LETSENCRYPT_DIR}" ]; then
    echo ""
    echo "Copying certificates to ${CERTS_DIR}..."

    cp "${LETSENCRYPT_DIR}/fullchain.pem" "${CERTS_DIR}/${DOMAIN}.crt"
    cp "${LETSENCRYPT_DIR}/privkey.pem" "${CERTS_DIR}/${DOMAIN}.key"
    cp "${LETSENCRYPT_DIR}/chain.pem" "${CERTS_DIR}/${DOMAIN}.chain.crt"

    chmod 600 "${CERTS_DIR}/${DOMAIN}.key"
    chmod 644 "${CERTS_DIR}/${DOMAIN}.crt"
    chmod 644 "${CERTS_DIR}/${DOMAIN}.chain.crt"

    echo ""
    echo "Certificate generated successfully!"
    echo "  Certificate: ${CERTS_DIR}/${DOMAIN}.crt"
    echo "  Private Key: ${CERTS_DIR}/${DOMAIN}.key"
    echo "  Chain:       ${CERTS_DIR}/${DOMAIN}.chain.crt"
else
    echo ""
    echo "Warning: Could not find Let's Encrypt certificates at ${LETSENCRYPT_DIR}"
    echo "You may need to copy them manually."
fi

echo ""
echo "To set up automatic renewal, add this to your crontab:"
echo "  0 0 1 * * certbot renew --quiet && docker compose restart nginx"