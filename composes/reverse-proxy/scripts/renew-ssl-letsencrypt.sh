#!/bin/bash
# Renew Let's Encrypt SSL certificates
# Usage: ./renew-ssl-letsencrypt.sh [mode]
#
# Modes:
#   standalone - Stop nginx, renew, restart nginx (default)
#   docker     - Use certbot docker image
#
# Add to crontab for automatic renewal:
#   0 0 1 * * /path/to/renew-ssl-letsencrypt.sh >> /var/log/certbot-renew.log 2>&1

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
COMPOSE_DIR="${SCRIPT_DIR}/.."
CERTS_DIR="${COMPOSE_DIR}/certs"
MODE="${1:-standalone}"

cd "${COMPOSE_DIR}"

echo "============================================"
echo "Let's Encrypt Certificate Renewal"
echo "Date: $(date)"
echo "Mode: ${MODE}"
echo "============================================"

case "${MODE}" in
    standalone)
        if ! command -v certbot &> /dev/null; then
            echo "Error: certbot is not installed."
            exit 1
        fi

        echo "Stopping nginx..."
        docker compose down

        echo "Renewing certificates..."
        certbot renew

        # Copy renewed certs
        for domain_dir in /etc/letsencrypt/live/*/; do
            domain=$(basename "${domain_dir}")
            if [ "${domain}" != "README" ]; then
                echo "Copying renewed cert for ${domain}..."
                sudo cp "${domain_dir}fullchain.pem" "${CERTS_DIR}/${domain}.crt"
                sudo cp "${domain_dir}privkey.pem" "${CERTS_DIR}/${domain}.key"
                sudo chown "$(whoami)" "${CERTS_DIR}/${domain}."*
                chmod 600 "${CERTS_DIR}/${domain}.key"
                chmod 644 "${CERTS_DIR}/${domain}.crt"
            fi
        done

        echo "Starting nginx..."
        docker compose up -d
        ;;

    docker)
        echo "Stopping nginx..."
        docker compose down

        echo "Renewing certificates with docker certbot..."
        docker run --rm \
            -p 80:80 \
            -v /etc/letsencrypt:/etc/letsencrypt \
            -v /var/lib/letsencrypt:/var/lib/letsencrypt \
            certbot/certbot renew

        # Copy renewed certs
        for domain_dir in /etc/letsencrypt/live/*/; do
            domain=$(basename "${domain_dir}")
            if [ "${domain}" != "README" ]; then
                echo "Copying renewed cert for ${domain}..."
                sudo cp "${domain_dir}fullchain.pem" "${CERTS_DIR}/${domain}.crt"
                sudo cp "${domain_dir}privkey.pem" "${CERTS_DIR}/${domain}.key"
                sudo chown "$(whoami)" "${CERTS_DIR}/${domain}."*
                chmod 600 "${CERTS_DIR}/${domain}.key"
                chmod 644 "${CERTS_DIR}/${domain}.crt"
            fi
        done

        echo "Starting nginx..."
        docker compose up -d
        ;;

    *)
        echo "Error: Unknown mode '${MODE}'"
        echo "Valid modes: standalone, docker"
        exit 1
        ;;
esac

echo ""
echo "Renewal complete!"