#!/bin/bash
# Generate Diffie-Hellman parameters for enhanced SSL security
# Usage: ./generate-dhparam.sh [bits]

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CERTS_DIR="${SCRIPT_DIR}/../certs"
BITS="${1:-2048}"

mkdir -p "${CERTS_DIR}"

echo "Generating ${BITS}-bit Diffie-Hellman parameters..."
echo "This may take a while..."
echo ""

openssl dhparam -out "${CERTS_DIR}/dhparam.pem" "${BITS}"

chmod 644 "${CERTS_DIR}/dhparam.pem"

echo ""
echo "DH parameters generated: ${CERTS_DIR}/dhparam.pem"
echo ""
echo "Add this to your nginx SSL configuration:"
echo "  ssl_dhparam /etc/nginx/certs/dhparam.pem;"