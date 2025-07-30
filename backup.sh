#!/bin/bash

# Set variables
BACKUP_DIR="project_backups"
TIMESTAMP=$(date +"%Y%m%d_%H%M%S")
BACKUP_NAME="backup_$TIMESTAMP.tar.gz"

# Create backup folder if it doesn't exist
mkdir -p "$BACKUP_DIR"

# Remove any existing backups
echo "🧹 Removing old backups..."
rm -f "$BACKUP_DIR"/backup_*.tar.gz

# Define exclusions
EXCLUDES=(
  --exclude "node_modules"
  --exclude ".git"
  --exclude "logs"
  --exclude "$BACKUP_DIR"
  --exclude "*.tar.gz"
)

# Create new backup
echo "📦 Creating new backup: $BACKUP_NAME..."
tar -czf "$BACKUP_DIR/$BACKUP_NAME" "${EXCLUDES[@]}" .

echo "✅ Backup complete: $BACKUP_DIR/$BACKUP_NAME"
