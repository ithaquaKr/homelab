# Redis

A Docker Compose setup for running Redis.

## Features

## Architecture

### Redis Sentinel

The setup consists of:

- 1 Redis Master
- 2 Redis Replicas
- 3 Redis Sentinels for high availability
- All services running in Docker containers

## Prerequisites

- Docker
- Docker Compose v2.x
- Git

## Quick Start

1. Clone the repository:

```bash
git clone https://github.com/ithaquaKr/redis-local.git
cd redis-local
```

## Makefile Commands

This project includes a Makefile for easy management of the Redis Sentinel cluster and supporting services.

### Basic Usage

```bash
# Show all available commands
make help
# Start all services
make up
# Check status
make status
# Scale Redis replicas
make scale-replica REPLICAS=5
```
