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

# Frontend: app source from sibling repo, nginx.conf from devops repo
DOCKER_BUILDKIT=1 docker build \
  -f docker/frontend/Dockerfile \
  --build-context app="$FRONTEND_DIR" \
  --build-context nginx=docker/frontend \
  -t ai-hmis-frontend:latest \
  .

# Backend: app source from sibling repo
DOCKER_BUILDKIT=1 docker build \
  -f docker/backend/Dockerfile \
  --build-context app="$BACKEND_DIR" \
  -t ai-hmis-backend:latest \
  .
