# API app (Phoenix)

This monorepo uses a **decoupled app layout**. The API runtime is containerized and served by the Phoenix codebase at the repository root.

## Current state
- Runtime container: `infra/docker/Dockerfile.api`
- Orchestration: `docker-compose.yml`
- API endpoint: `http://localhost:4000`

## Why this exists
This folder reserves the API app slot so you can evolve toward a fully split app tree (`apps/api`, `apps/mobile`, etc.) without blocking current delivery.
