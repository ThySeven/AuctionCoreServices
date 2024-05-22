#!/bin/bash

# Shut down the auction core services
docker compose -f docker-compose-auction-core-services.yml down

# Shut down the vault setup services
docker compose -f docker-compose-vault-setup.yml down

# Shut down the auction shared services
docker compose -f docker-compose-auction-shared-services.yml down