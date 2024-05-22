#!/bin/bash
docker compose -f docker-compose-auction-shared-services.yml up -d

sleep 1

docker compose -f docker-compose-vault-setup.yml up

docker compose -f docker-compose-vault-setup.yml down

sleep 1

docker compose -f docker-compose-auction-core-services.yml up -d