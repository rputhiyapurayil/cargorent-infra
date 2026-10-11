#!/usr/bin/env bash
# Stops the services started by start-local.sh. Add --db to also stop MySQL, --reset to wipe its data.
cd "$(dirname "$0")/.."
for f in logs/*.pid; do [ -f "$f" ] && kill "$(cat "$f")" 2>/dev/null; rm -f "$f"; done
echo "Services stopped."
case "${1:-}" in
  --db) docker compose -f docker-compose.mysql.yml down ;;
  --reset) docker compose -f docker-compose.mysql.yml down -v && echo "Database wiped." ;;
esac
