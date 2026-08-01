#!/bin/bash
set -e

FRONTEND_DIR="../ai-hmis-frontend"
BACKEND_DIR="../aihmisbackend"

if [ ! -d "$FRONTEND_DIR" ]; then
  echo "ERROR: Frontend repo not found at $FRONTEND_DIR"
  echo "Ensure ai-hmis-frontend sits as a sibling folder next to this devops repo."
  exit 1
fi

if [ ! -d "$BACKEND_DIR" ]; then
  echo "ERROR: Backend repo not found at $BACKEND_DIR"
  echo "Ensure aihmisbackend sits as a sibling folder next to this devops repo."
  exit 1
fi

# Frontend: build context is the app repo, Dockerfile lives in devops repo
docker build \
  -f docker/frontend/Dockerfile \
  -t ai-hmis-frontend:latest \
  "$FRONTEND_DIR"

# Backend: build context is the app repo, Dockerfile lives in devops repo
docker build \
  -f docker/backend/Dockerfile \
  -t ai-hmis-backend:latest \
  "$BACKEND_DIR"
