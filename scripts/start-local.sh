#!/usr/bin/env bash
# Starts MySQL in Docker and all six Spring Boot services from their jars (no IDE needed).
# Expects the repos side by side:  cargorent/cargorent-infra, cargorent/cargorent-user-service, ...
set -euo pipefail
cd "$(dirname "$0")/.."
ROOT="$(cd .. && pwd)"
LOGS="$PWD/logs"; mkdir -p "$LOGS"
SERVICES=(user-service vehicle-service booking-service payment-service notification-service api-gateway)

echo "▶ Starting MySQL..."
docker compose -f docker-compose.mysql.yml up -d
until [ "$(docker inspect -f '{{.State.Health.Status}}' cargorent-mysql 2>/dev/null)" = "healthy" ]; do sleep 2; done

for s in "${SERVICES[@]}"; do
  dir="$ROOT/cargorent-$s"
  jar="$dir/target/cargorent-$s-1.0.0.jar"
  if [ ! -f "$jar" ] || [ "${REBUILD:-0}" = "1" ]; then
    echo "▶ Building $s..."
    (cd "$dir" && mvn -q -B package -DskipTests)
  fi
  echo "▶ Starting $s (log: logs/$s.log)"
  nohup java -jar "$jar" > "$LOGS/$s.log" 2>&1 &
  echo $! > "$LOGS/$s.pid"
done

echo "▶ Waiting for services..."
for s in "${SERVICES[@]}"; do
  for _ in $(seq 1 60); do grep -q "Started .*Application" "$LOGS/$s.log" 2>/dev/null && break; sleep 2; done
  grep -q "Started .*Application" "$LOGS/$s.log" && echo "  ✓ $s" || echo "  ✕ $s did not start - see logs/$s.log"
done
echo
echo "API gateway: http://localhost:8080   Frontend: cd ../cargorent-web && npm install && npm run dev"
