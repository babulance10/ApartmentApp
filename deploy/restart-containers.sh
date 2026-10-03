#!/usr/bin/env bash
# Recreates the Apartment-App (Gruha) containers with correct Traefik routing.
# Both the UI and the API are served from the single host gruha.sarvavidha.in;
# the API wins for /api/* via a higher router priority.
#
# Run this on the server rather than pasting docker-run commands over SSH -
# the Traefik rule contains backticks and "&&", which are easy to mangle
# through nested shell quoting (a mangled rule silently routes /api to the
# static frontend and every API call 404s/405s).
set -euo pipefail

PASS="$(cat /opt/apartment-app/.pg_password)"
HOST="gruha.sarvavidha.in"

docker rm -f apartmentapp-backend apartmentapp-frontend >/dev/null 2>&1 || true

docker run -d --name apartmentapp-backend \
  --network sarvavidha-net \
  -e DATABASE_URL="postgresql://apartmentapp:${PASS}@apartmentapp-postgres:5432/apartment_app?schema=public" \
  -e JWT_SECRET="psa-sreenidhi-secret-2024" \
  -e NODE_ENV=production \
  -e PORT=3001 \
  -e COOKIE_DOMAIN=.sarvavidha.in \
  -e CORS_ORIGIN="https://${HOST},https://sarvavidha.in" \
  --restart unless-stopped \
  --label "traefik.enable=true" \
  --label "traefik.docker.network=sarvavidha-net" \
  --label "traefik.http.routers.sv-gruha-api.entrypoints=https" \
  --label "traefik.http.routers.sv-gruha-api.rule=Host(\`${HOST}\`) && PathPrefix(\`/api\`)" \
  --label "traefik.http.routers.sv-gruha-api.priority=100" \
  --label "traefik.http.routers.sv-gruha-api.tls=true" \
  --label "traefik.http.services.sv-gruha-api.loadbalancer.server.port=3001" \
  apartmentapp-backend:latest >/dev/null

docker run -d --name apartmentapp-frontend \
  --network sarvavidha-net \
  --restart unless-stopped \
  --label "traefik.enable=true" \
  --label "traefik.docker.network=sarvavidha-net" \
  --label "traefik.http.routers.sv-gruha.entrypoints=https" \
  --label "traefik.http.routers.sv-gruha.rule=Host(\`${HOST}\`)" \
  --label "traefik.http.routers.sv-gruha.priority=1" \
  --label "traefik.http.routers.sv-gruha.tls=true" \
  --label "traefik.http.services.sv-gruha.loadbalancer.server.port=80" \
  apartmentapp-frontend:latest >/dev/null

echo "Backend rule : $(docker inspect apartmentapp-backend --format '{{index .Config.Labels "traefik.http.routers.sv-gruha-api.rule"}}')"
echo "Frontend rule: $(docker inspect apartmentapp-frontend --format '{{index .Config.Labels "traefik.http.routers.sv-gruha.rule"}}')"
