#!/bin/bash

set -e

echo "Checking current live environment..."

CURRENT=$(docker ps --format '{{.Names}}' | grep nginx-blue || true)

if [ "$CURRENT" != "" ]; then
    echo "Blue is live → Deploy Green"

    docker compose -f docker-compose.green.yml pull
    docker compose -f docker-compose.green.yml up -d

    echo "Switching traffic to Green..."
    sudo sed -i 's/8081/8082/' /etc/nginx/sites-enabled/default
    sudo systemctl reload nginx

    echo "Stopping Blue..."
    docker compose -f docker-compose.blue.yml down

else
    echo "Green is live → Deploy Blue"

    docker compose -f docker-compose.blue.yml pull
    docker compose -f docker-compose.blue.yml up -d

    echo "Switching traffic to Blue..."
    sudo sed -i 's/8082/8081/' /etc/nginx/sites-enabled/default
    sudo systemctl reload nginx

    echo "Stopping Green..."
    docker compose -f docker-compose.green.yml down
fi