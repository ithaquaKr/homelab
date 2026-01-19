#!/bin/bash
# Generate SSL certificates using Let's Encrypt with certbot
# Usage: ./generate-ssl-letsencrypt.sh <domain> [email] [mode]
#
# Modes:
#   standalone - Certbot runs its own web server (nginx must be stopped, port 80 free)
#   webroot    - Uses existing nginx (nginx must be running and serving the domain)
#   docker     - Uses certbot docker image (recommended)

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
COMPOSE_DIR="${SCRIPT_DIR}/.."
CERTS_DIR="${COMPOSE_DIR}/certs"
HTML_DIR="${COMPOSE_DIR}/html"
DOMAIN="${1}"
EMAIL="${2:-}"
MODE="${3:-standalone}"

if [ -z "${DOMAIN}" ]; then
    echo "Usage: $0 <domain> [email] [mode]"
    echo ""
    echo "Modes:"
    echo "  standalone  - Certbot runs its own web server (default)"
    echo "                Requires: port 80 free, nginx stopped"
    echo "  webroot     - Uses existing nginx webroot"
    echo "                Requires: nginx running, domain accessible"
    echo "  docker      - Uses certbot docker image"
    echo "                Requires: docker, port 80 free"
    echo ""
    echo "Examples:"
    echo "  $0 example.com admin@example.com"
    echo "  $0 example.com admin@example.com standalone"
    echo "  $0 example.com admin@example.com docker"
    exit 1
fi

# Create directories
mkdir -p "${CERTS_DIR}"
mkdir -p "${HTML_DIR}/.well-known/acme-challenge"

echo "Generating Let's Encrypt SSL certificate"
echo "  Domain: ${DOMAIN}"
echo "  Mode:   ${MODE}"
echo "  Output: ${CERTS_DIR}"
echo ""

# Build email args
EMAIL_ARGS=""
if [ -n "${EMAIL}" ]; then
    EMAIL_ARGS="--email ${EMAIL} --agree-tos --no-eff-email"
else
    EMAIL_ARGS="--register-unsafely-without-email --agree-tos"
fi

case "${MODE}" in
    standalone)
        # Check if certbot is installed
        if ! command -v certbot &> /dev/null; then
            echo "Error: certbot is not installed."
            echo "Install: brew install certbot (macOS) or apt install certbot (Ubuntu)"
            exit 1
        fi

        echo "Using standalone mode - make sure port 80 is free and nginx is stopped."
        echo ""

        certbot certonly --standalone \
            -d "${DOMAIN}" \
            ${EMAIL_ARGS} \
            --cert-path "${CERTS_DIR}/${DOMAIN}.crt" \
            --key-path "${CERTS_DIR}/${DOMAIN}.key" \
            --fullchain-path "${CERTS_DIR}/${DOMAIN}.fullchain.crt" \
            --chain-path "${CERTS_DIR}/${DOMAIN}.chain.crt"
        ;;

    webroot)
        # Check if certbot is installed
        if ! command -v certbot &> /dev/null; then
            echo "Error: certbot is not installed."
            exit 1
        fi

        echo "Using webroot mode - make sure nginx is running and serving ${DOMAIN}"
        echo "The domain must be publicly accessible on port 80."
        echo ""

        certbot certonly --webroot \
            -w "${HTML_DIR}" \
            -d "${DOMAIN}" \
            ${EMAIL_ARGS}

        # Copy from Let's Encrypt directory
        LETSENCRYPT_DIR="/etc/letsencrypt/live/${DOMAIN}"
        if [ -d "${LETSENCRYPT_DIR}" ]; then
            sudo cp "${LETSENCRYPT_DIR}/fullchain.pem" "${CERTS_DIR}/${DOMAIN}.crt"
            sudo cp "${LETSENCRYPT_DIR}/privkey.pem" "${CERTS_DIR}/${DOMAIN}.key"
            sudo cp "${LETSENCRYPT_DIR}/chain.pem" "${CERTS_DIR}/${DOMAIN}.chain.crt"
            sudo chown "$(whoami)" "${CERTS_DIR}/${DOMAIN}."*
        fi
        ;;

    docker)
        echo "Using Docker certbot - make sure port 80 is free."
        echo ""

        docker run -it --rm \
            -p 80:80 \
            -v "${CERTS_DIR}:/etc/letsencrypt/live/${DOMAIN}" \
            -v "${CERTS_DIR}:/etc/letsencrypt/archive/${DOMAIN}" \
            certbot/certbot certonly --standalone \
            -d "${DOMAIN}" \
            ${EMAIL_ARGS} \
            --cert-name "${DOMAIN}"

        # Rename files from certbot naming convention
        if [ -f "${CERTS_DIR}/fullchain1.pem" ]; then
            mv "${CERTS_DIR}/fullchain1.pem" "${CERTS_DIR}/${DOMAIN}.crt"
            mv "${CERTS_DIR}/privkey1.pem" "${CERTS_DIR}/${DOMAIN}.key"
            mv "${CERTS_DIR}/chain1.pem" "${CERTS_DIR}/${DOMAIN}.chain.crt" 2>/dev/null || true
        fi
        ;;

    *)
        echo "Error: Unknown mode '${MODE}'"
        echo "Valid modes: standalone, webroot, docker"
        exit 1
        ;;
esac

# Set permissions
chmod 600 "${CERTS_DIR}/${DOMAIN}.key" 2>/dev/null || true
chmod 644 "${CERTS_DIR}/${DOMAIN}.crt" 2>/dev/null || true

echo ""
echo "============================================"
echo "Certificate generated successfully!"
echo "============================================"
echo "  Certificate: ${CERTS_DIR}/${DOMAIN}.crt"
echo "  Private Key: ${CERTS_DIR}/${DOMAIN}.key"
echo ""
echo "To set up automatic renewal, add to crontab:"
echo "  crontab -e"
echo ""
echo "Then add this line (runs monthly on the 1st at midnight):"
echo "  0 0 1 * * cd ${COMPOSE_DIR} && make ssl-renew MODE=${MODE} >> /var/log/certbot-renew.log 2>&1"
echo ""
echo "Or run manually:"
echo "  make ssl-renew MODE=${MODE}"