# Airbyte Docker Compose Stack for Testing

This repository contains a Docker Compose stack for testing Airbyte in a turn-key manner.

> **Note:** Docker Compose deployment for Airbyte is deprecated in favor of `abctl` and Kubernetes. This setup is intended for local testing and development purposes only.

## Prerequisites

- Docker (version 20.10.0 or later)
- Docker Compose (version 2.0.0 or later)
- At least 4GB of available RAM
- At least 10GB of available disk space

## Quick Start

1. **Clone this repository** (if not already done):
   ```bash
   git clone https://github.com/deljdlx/test-airbyte.git
   cd test-airbyte
   ```

2. **Start the Airbyte stack**:
   ```bash
   docker-compose up -d
   ```

3. **Wait for all services to be ready** (this may take 2-3 minutes):
   ```bash
   docker-compose ps
   ```

4. **Access the Airbyte UI**:
   - Open your browser and navigate to: http://localhost:8000
   - Default credentials are not required for the OSS version

## Services

This stack includes the following services:

- **webapp**: Airbyte web interface (port 8000)
- **server**: Airbyte API server (port 8001)
- **worker**: Airbyte worker for running sync jobs
- **db**: PostgreSQL database for Airbyte metadata
- **temporal**: Temporal workflow engine
- **cron**: Scheduled tasks
- **connector-builder-server**: Connector builder service (port 8080)

## Configuration

The default configuration is stored in the `.env` file. You can customize:

- **Database credentials**: `DATABASE_USER`, `DATABASE_PASSWORD`
- **Airbyte version**: `VERSION`
- **Log level**: `LOG_LEVEL` (DEBUG, INFO, WARN, ERROR)
- **Resource limits**: CPU and memory limits for workers

## Common Commands

### Start the stack
```bash
docker-compose up -d
```

### Stop the stack
```bash
docker-compose down
```

### View logs
```bash
# All services
docker-compose logs -f

# Specific service
docker-compose logs -f webapp
docker-compose logs -f server
docker-compose logs -f worker
```

### Check service status
```bash
docker-compose ps
```

### Restart a specific service
```bash
docker-compose restart worker
```

### Clean up (remove volumes and data)
```bash
docker-compose down -v
```

## Troubleshooting

### Services not starting
1. Check if Docker is running: `docker ps`
2. Check logs: `docker-compose logs`
3. Ensure ports 8000, 8001, and 8080 are not in use

### Out of memory errors
- Increase Docker's memory limit in Docker Desktop settings
- Recommended: at least 4GB of RAM

### Database connection issues
- Wait for the database to fully initialize (check logs: `docker-compose logs db`)
- Restart the services: `docker-compose restart`

### Reset everything
```bash
docker-compose down -v
docker-compose up -d
```

## Testing the Setup

### 1. Access the Web UI
- Navigate to http://localhost:8000
- You should see the Airbyte welcome screen

### 2. Create a test connection
- Follow the onboarding wizard
- Try setting up a sample source (e.g., Sample Data - Faker)
- Set up a sample destination (e.g., Local JSON)
- Run a test sync

### 3. Check service health
```bash
# Check if all containers are running
docker-compose ps

# Check server health
curl http://localhost:8001/api/v1/health
```

## Data Persistence

Data is persisted in Docker volumes:
- `airbyte_db`: PostgreSQL database
- `airbyte_data`: Airbyte configuration
- `airbyte_workspace`: Workspace data

To remove all data, use: `docker-compose down -v`

## Upgrading

To upgrade to a newer version of Airbyte:

1. Update the `VERSION` in the `.env` file
2. Pull new images: `docker-compose pull`
3. Restart the stack: `docker-compose up -d`

> **Warning:** Always backup your data before upgrading!

## Migration to Production

For production deployments, Airbyte recommends:
- Using `abctl` for local Kubernetes deployment
- Using Helm charts for Kubernetes clusters
- See [official documentation](https://docs.airbyte.com/platform/deploying-airbyte/)

## Resources

- [Airbyte Documentation](https://docs.airbyte.com/)
- [Airbyte GitHub Repository](https://github.com/airbytehq/airbyte)
- [Airbyte Community Slack](https://slack.airbyte.io/)

## License

This setup is for testing purposes. Airbyte is licensed under the Elastic License 2.0 (ELv2).
