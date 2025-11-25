# 🐳 Docker Deployment Guide

## Quick Start

### 1. Prerequisites
- Docker Engine 20.10+
- Docker Compose 2.0+

### 2. Setup Environment
```bash
# Copy environment template
cp .env.example .env

# Edit .env with your configuration
nano .env
```

### 3. Start All Services
```bash
# Build and start all containers
docker-compose up -d

# View logs
docker-compose logs -f

# Check status
docker-compose ps
```

### 4. Access Services
- **Frontend**: http://localhost:8080
- **Backend API**: http://localhost:3000
- **MySQL**: localhost:3306

### 5. Stop Services
```bash
# Stop all containers
docker-compose down

# Stop and remove volumes (WARNING: deletes data)
docker-compose down -v
```

## Individual Service Management

### Backend Only
```bash
docker-compose up -d backend
docker-compose logs -f backend
```

### Frontend Only
```bash
docker-compose up -d frontend
docker-compose logs -f frontend
```

### Database Only
```bash
docker-compose up -d mysql
docker-compose logs -f mysql
```

## Useful Commands

### View Logs
```bash
# All services
docker-compose logs -f

# Specific service
docker-compose logs -f backend
docker-compose logs -f frontend
docker-compose logs -f mysql
```

### Restart Services
```bash
# Restart all
docker-compose restart

# Restart specific service
docker-compose restart backend
```

### Execute Commands in Container
```bash
# Access backend shell
docker-compose exec backend sh

# Access MySQL
docker-compose exec mysql mysql -u root -p stream_sync_lite

# Run database seed
docker-compose exec backend npm run seed
```

### Rebuild Containers
```bash
# Rebuild all
docker-compose build

# Rebuild specific service
docker-compose build backend

# Rebuild and restart
docker-compose up -d --build
```

## Production Deployment

### 1. Update Environment Variables
```bash
# Set production values in .env
NODE_ENV=production
JWT_SECRET=<use-strong-random-key>
DB_PASSWORD=<use-strong-password>
```

### 2. Use Production Compose File
```bash
docker-compose -f docker-compose.prod.yml up -d
```

### 3. Enable HTTPS
Use a reverse proxy like Nginx or Traefik:
```yaml
services:
  nginx:
    image: nginx:alpine
    ports:
      - "80:80"
      - "443:443"
    volumes:
      - ./nginx.conf:/etc/nginx/nginx.conf
      - ./ssl:/etc/nginx/ssl
```

## Troubleshooting

### Port Already in Use
```bash
# Change port in docker-compose.yml
ports:
  - "3001:3000"  # Change 3000 to 3001
```

### Database Connection Issues
```bash
# Check if MySQL is healthy
docker-compose ps

# View MySQL logs
docker-compose logs mysql

# Wait for MySQL to be ready
docker-compose up -d mysql
sleep 30
docker-compose up -d backend
```

### Container Won't Start
```bash
# Check logs
docker-compose logs <service-name>

# Remove and recreate
docker-compose down
docker-compose up -d --force-recreate
```

### Clear All Data
```bash
# WARNING: This deletes all data
docker-compose down -v
docker volume prune -f
```

## Performance Optimization

### Limit Resources
```yaml
services:
  backend:
    deploy:
      resources:
        limits:
          cpus: '0.5'
          memory: 512M
```

### Use Production Images
```dockerfile
# Multi-stage builds for smaller images
FROM node:22-alpine AS builder
# ... build steps
FROM node:22-alpine
COPY --from=builder /app/dist /app/dist
```

## Monitoring

### Health Checks
```bash
# Check health status
docker-compose ps

# All services should show "healthy"
```

### Resource Usage
```bash
# View resource usage
docker stats

# Specific container
docker stats stream_sync_lite_backend
```

## Backup & Restore

### Backup Database
```bash
# Create backup
docker-compose exec mysql mysqldump -u root -p stream_sync_lite > backup.sql

# Or use Docker volume
docker run --rm \
  -v stream_sync_lite_mysql_data:/data \
  -v $(pwd):/backup \
  busybox tar czf /backup/mysql-backup.tar.gz /data
```

### Restore Database
```bash
# Restore from SQL dump
docker-compose exec -T mysql mysql -u root -p stream_sync_lite < backup.sql

# Or restore volume
docker run --rm \
  -v stream_sync_lite_mysql_data:/data \
  -v $(pwd):/backup \
  busybox tar xzf /backup/mysql-backup.tar.gz -C /
```

## Security Best Practices

1. **Never commit `.env` file**
2. **Use strong passwords**
3. **Limit exposed ports** in production
4. **Keep images updated**: `docker-compose pull`
5. **Use secrets management** for sensitive data
6. **Enable firewall rules**
7. **Regular backups**
8. **Monitor logs** for suspicious activity

## CI/CD Integration

### GitHub Actions Example
```yaml
name: Docker Build and Push

on:
  push:
    branches: [main]

jobs:
  build:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v2
      - name: Build and push
        run: |
          docker-compose build
          docker-compose push
```

## Additional Resources

- [Docker Documentation](https://docs.docker.com/)
- [Docker Compose Reference](https://docs.docker.com/compose/compose-file/)
- [Best Practices](https://docs.docker.com/develop/dev-best-practices/)
