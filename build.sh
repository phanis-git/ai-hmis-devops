#!/bin/bash

docker build \
-f docker/frontend/Dockerfile \
-t ai-hmis-frontend:latest \
../ai-hmis-frontend

docker build \
-f docker/backend/Dockerfile \
-t ai-hmis-backend:latest \
../aihmisbackend