.PHONY: help init up down restart logs ssl-default ssl-domain ssl-letsencrypt ssl-renew dhparam test reload

help:
	@echo "Nginx Reverse Proxy Management"
	@echo ""
	@echo "Usage: make <target>"
	@echo ""
	@echo "Targets:"
	@echo "  init            Initialize directories and generate default SSL cert"
	@echo "  up              Start nginx reverse proxy"
	@echo "  down            Stop nginx reverse proxy"
	@echo "  restart         Restart nginx reverse proxy"
	@echo "  reload          Reload nginx configuration without restart"
	@echo "  logs            View nginx logs"
	@echo "  test            Test nginx configuration"
	@echo ""
	@echo "SSL Certificate Generation:"
	@echo "  ssl-default     Generate default self-signed certificate"
	@echo "  ssl-domain      Generate self-signed cert (DOMAIN=example.com)"
	@echo "  ssl-letsencrypt Generate Let's Encrypt cert"
	@echo "                  DOMAIN=example.com EMAIL=admin@example.com MODE=standalone|webroot|docker"
	@echo "  ssl-renew       Renew Let's Encrypt certs (MODE=standalone|docker)"
	@echo "  dhparam         Generate Diffie-Hellman parameters"
	@echo ""
	@echo "Auto-renewal cron (monthly):"
	@echo "  0 0 1 * * cd $(PWD) && make ssl-renew >> /var/log/certbot-renew.log 2>&1"

init:
	@mkdir -p certs html/.well-known/acme-challenge
	@touch certs/.gitkeep
	@cp env.example .env 2>/dev/null || true
	@chmod +x scripts/*.sh
	@./scripts/generate-ssl-selfsigned.sh default
	@echo "Initialization complete. Edit .env and conf.d/ as needed."

up:
	docker compose up -d

down:
	docker compose down

restart:
	docker compose restart

reload:
	docker compose exec nginx nginx -s reload

logs:
	docker compose logs -f nginx

test:
	docker compose exec nginx nginx -t

ssl-default:
	@chmod +x scripts/generate-ssl-selfsigned.sh
	@./scripts/generate-ssl-selfsigned.sh default

ssl-domain:
ifndef DOMAIN
	$(error DOMAIN is required. Usage: make ssl-domain DOMAIN=example.com)
endif
	@chmod +x scripts/generate-ssl-selfsigned.sh
	@./scripts/generate-ssl-selfsigned.sh $(DOMAIN)

ssl-letsencrypt:
ifndef DOMAIN
	$(error DOMAIN is required. Usage: make ssl-letsencrypt DOMAIN=example.com EMAIL=admin@example.com MODE=standalone)
endif
	@chmod +x scripts/generate-ssl-letsencrypt.sh
	@./scripts/generate-ssl-letsencrypt.sh $(DOMAIN) $(EMAIL) $(MODE)

ssl-renew:
	@chmod +x scripts/renew-ssl-letsencrypt.sh
	@./scripts/renew-ssl-letsencrypt.sh $(MODE)

dhparam:
	@chmod +x scripts/generate-dhparam.sh
	@./scripts/generate-dhparam.sh