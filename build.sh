#!/bin/bash
set -e

# Frontend: app source from sibling repo, nginx.conf from devops repo
DOCKER_BUILDKIT=1 docker build \
  -f docker/frontend/Dockerfile \
  --build-context app=../ai-hmis-frontend \
  --build-context nginx=docker/frontend \
  -t ai-hmis-frontend:latest \
  .

# Backend: app source from sibling repo
DOCKER_BUILDKIT=1 docker build \
  -f docker/backend/Dockerfile \
  --build-context app=../aihmisbackend \
  -t ai-hmis-backend:latest \
  .
