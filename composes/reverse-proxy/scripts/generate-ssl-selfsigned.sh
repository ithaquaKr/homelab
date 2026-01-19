#!/bin/bash
# Generate self-signed SSL certificates for development/testing
# Usage: ./generate-ssl-selfsigned.sh [domain] [days]

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CERTS_DIR="${SCRIPT_DIR}/../certs"
DOMAIN="${1:-default}"
DAYS="${2:-365}"

# Create certs directory if it doesn't exist
mkdir -p "${CERTS_DIR}"

echo "Generating self-signed SSL certificate for: ${DOMAIN}"
echo "Validity: ${DAYS} days"
echo "Output directory: ${CERTS_DIR}"
echo ""

# Generate private key
openssl genrsa -out "${CERTS_DIR}/${DOMAIN}.key" 2048

# Generate certificate signing request (CSR)
openssl req -new \
    -key "${CERTS_DIR}/${DOMAIN}.key" \
    -out "${CERTS_DIR}/${DOMAIN}.csr" \
    -subj "/C=US/ST=State/L=City/O=Organization/OU=IT/CN=${DOMAIN}"

# Create config file for SAN (Subject Alternative Name)
cat > "${CERTS_DIR}/${DOMAIN}.cnf" << EOF
[req]
distinguished_name = req_distinguished_name
req_extensions = v3_req
prompt = no

[req_distinguished_name]
C = US
ST = State
L = City
O = Organization
OU = IT
CN = ${DOMAIN}

[v3_req]
keyUsage = keyEncipherment, dataEncipherment
extendedKeyUsage = serverAuth
subjectAltName = @alt_names

[alt_names]
DNS.1 = ${DOMAIN}
DNS.2 = *.${DOMAIN}
DNS.3 = localhost
IP.1 = 127.0.0.1
EOF

# Generate self-signed certificate with SAN
openssl x509 -req \
    -in "${CERTS_DIR}/${DOMAIN}.csr" \
    -signkey "${CERTS_DIR}/${DOMAIN}.key" \
    -out "${CERTS_DIR}/${DOMAIN}.crt" \
    -days "${DAYS}" \
    -extensions v3_req \
    -extfile "${CERTS_DIR}/${DOMAIN}.cnf"

# Clean up CSR and config file
rm -f "${CERTS_DIR}/${DOMAIN}.csr" "${CERTS_DIR}/${DOMAIN}.cnf"

# Set proper permissions
chmod 600 "${CERTS_DIR}/${DOMAIN}.key"
chmod 644 "${CERTS_DIR}/${DOMAIN}.crt"

echo ""
echo "Certificate generated successfully!"
echo "  Certificate: ${CERTS_DIR}/${DOMAIN}.crt"
echo "  Private Key: ${CERTS_DIR}/${DOMAIN}.key"
echo ""
echo "To trust this certificate on macOS:"
echo "  sudo security add-trusted-cert -d -r trustRoot -k /Library/Keychains/System.keychain ${CERTS_DIR}/${DOMAIN}.crt"
echo ""
echo "To trust this certificate on Linux (Ubuntu/Debian):"
echo "  sudo cp ${CERTS_DIR}/${DOMAIN}.crt /usr/local/share/ca-certificates/"
echo "  sudo update-ca-certificates"
