#!/bin/bash

# CONFIG
ENV_FILE=".env"
BACKUP_DIR="project_backups"
BACKUP_NAME="backup_$(date +'%Y%m%d_%H%M%S').tar.gz"
COMPOSE_FILE="docker-compose.yml"
COMPOSE_OVERRIDE="docker-compose.override.yml"
COMPOSE_PROD="docker-compose.prod.yml"
COMPOSE_BACKUP="docker-compose.backup.yml"
COMPOSE_DEV="docker-compose.dev.yml"

PROJECT_IMAGE_NAME="docker-node-image"
PROJECT_CONTAINER_NAME="docker-node-server"

# Parse --rebuild flag
REBUILD=false
for arg in "$@"; do
  if [[ "$arg" == "--rebuild" ]]; then
    REBUILD=true
  fi
done

# Remove old backups and create a new backup
echo "🧹 Removing old backups..."
rm -rf "$BACKUP_DIR"
mkdir -p "$BACKUP_DIR"

echo "📦 Creating backup: $BACKUP_NAME..."
tar --exclude="$BACKUP_DIR" -czf "$BACKUP_DIR/$BACKUP_NAME" .
echo "✅ Backup complete: $BACKUP_DIR/$BACKUP_NAME"

# Load .env
if [[ -f $ENV_FILE ]]; then
  echo "Loading environment from $ENV_FILE..."
  set -o allexport
  source "$ENV_FILE"
  set +o allexport
fi

if [ "$REBUILD" = true ]; then
  echo "🧹 Rebuild requested: stopping and removing container and image..."

  # Stop and remove container if exists
  if [ "$(docker ps -aq -f name=^${PROJECT_CONTAINER_NAME}$)" ]; then
    echo "Stopping and removing container $PROJECT_CONTAINER_NAME..."
    docker rm -f "$PROJECT_CONTAINER_NAME"
  else
    echo "No container named $PROJECT_CONTAINER_NAME found."
  fi

  # Remove image if exists
  if [ "$(docker images -q $PROJECT_IMAGE_NAME)" ]; then
    echo "Removing image $PROJECT_IMAGE_NAME..."
    docker rmi -f "$PROJECT_IMAGE_NAME"
  else
    echo "No image named $PROJECT_IMAGE_NAME found."
  fi

  # Run with build
  if [[ "$ENVIRONMENT" == "backup" ]]; then
    echo "Using backup override: $COMPOSE_BACKUP"
    docker compose -f "$COMPOSE_FILE" -f "$COMPOSE_BACKUP" up --build --remove-orphans
  elif [[ "$NODE_ENV" == "production" ]]; then
    echo "Using production override: $COMPOSE_PROD"
    docker compose -f "$COMPOSE_FILE" -f "$COMPOSE_PROD" up --build --remove-orphans
  elif [[ "$NODE_ENV" == "dev" ]]; then
    echo "Using development override: $COMPOSE_DEV"
    docker compose -f "$COMPOSE_FILE" -f "$COMPOSE_DEV" up --build --remove-orphans
  else
    echo "Using development override: $COMPOSE_OVERRIDE"
    docker compose -f "$COMPOSE_FILE" -f "$COMPOSE_OVERRIDE" up --build --remove-orphans
  fi
else
  echo "No rebuild flag detected, starting container with docker compose up (without build)..."

  if [[ "$ENVIRONMENT" == "backup" ]]; then
    echo "Using backup override: $COMPOSE_BACKUP"
    docker compose -f "$COMPOSE_FILE" -f "$COMPOSE_BACKUP" up --remove-orphans
  elif [[ "$NODE_ENV" == "production" ]]; then
    echo "Using production override: $COMPOSE_PROD"
    docker compose -f "$COMPOSE_FILE" -f "$COMPOSE_PROD" up --remove-orphans
  elif [[ "$NODE_ENV" == "dev" ]]; then
    echo "Using development override: $COMPOSE_DEV"
    docker compose -f "$COMPOSE_FILE" -f "$COMPOSE_DEV" up --build --remove-orphans
  else
    echo "Using development override: $COMPOSE_OVERRIDE"
    docker compose -f "$COMPOSE_FILE" -f "$COMPOSE_OVERRIDE" up --remove-orphans
  fi
fi
