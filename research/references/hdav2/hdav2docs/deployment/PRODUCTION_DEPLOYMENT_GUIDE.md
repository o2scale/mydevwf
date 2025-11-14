# HDA v2 Production Deployment Guide - Ubuntu Server

**Document Version**: 1.0
**Last Updated**: 2025-10-06
**Target Environment**: Ubuntu 20.04/22.04 LTS
**Process Manager**: PM2

---

## Table of Contents

1. [Pre-Deployment Checklist](#pre-deployment-checklist)
2. [Server Requirements](#server-requirements)
3. [Step-by-Step Deployment](#step-by-step-deployment)
4. [PM2 Process Configuration](#pm2-process-configuration)
5. [Environment Configuration](#environment-configuration)
6. [Nginx Configuration](#nginx-configuration)
7. [SSL/HTTPS Setup](#sslhttps-setup)
8. [Database Setup](#database-setup)
9. [Post-Deployment Verification](#post-deployment-verification)
10. [Monitoring & Maintenance](#monitoring--maintenance)
11. [Troubleshooting](#troubleshooting)

---

## Pre-Deployment Checklist

Before starting deployment, ensure you have:

- [ ] Ubuntu server with root/sudo access
- [ ] Domain name pointing to server IP (optional but recommended)
- [ ] Supabase project created and configured
- [ ] Google Cloud project with Vertex AI API enabled
- [ ] Service account JSON key for Google Cloud
- [ ] Database credentials (PostgreSQL via Supabase)
- [ ] GitHub repository access (https://github.com/o2scale/hdav2.git)
- [ ] Server specs: Minimum 4GB RAM, 2 CPU cores, 40GB disk

---

## Server Requirements

### Minimum Specifications
- **OS**: Ubuntu 20.04 or 22.04 LTS
- **RAM**: 4GB (8GB recommended for production)
- **CPU**: 2 cores (4 cores recommended)
- **Disk**: 40GB (100GB recommended)
- **Network**: Public IP with ports 80, 443 open

### Software Stack
- **Python**: 3.11+
- **Node.js**: 18.x LTS or 20.x LTS
- **PostgreSQL**: 15+ (via Supabase)
- **Nginx**: Latest stable
- **PM2**: Latest version
- **Git**: Latest version

---

## Step-by-Step Deployment

### Phase 1: Initial Server Setup

#### 1.1 Update System Packages

```bash
# Update package list and upgrade system
sudo apt update && sudo apt upgrade -y

# Install essential build tools
sudo apt install -y build-essential curl wget git vim software-properties-common

# Install system dependencies
sudo apt install -y libpq-dev python3-dev
```

#### 1.2 Install Python 3.11+

```bash
# Add deadsnakes PPA for latest Python
sudo add-apt-repository ppa:deadsnakes/ppa -y
sudo apt update

# Install Python 3.11
sudo apt install -y python3.11 python3.11-venv python3.11-dev

# Install pip
curl -sS https://bootstrap.pypa.io/get-pip.py | sudo python3.11

# Verify installation
python3.11 --version
pip3.11 --version
```

#### 1.3 Install Node.js & npm

```bash
# Install Node.js 20.x LTS using NodeSource
curl -fsSL https://deb.nodesource.com/setup_20.x | sudo -E bash -
sudo apt install -y nodejs

# Verify installation
node --version  # Should be v20.x.x
npm --version   # Should be 10.x.x
```

#### 1.4 Install PM2 Process Manager

```bash
# Install PM2 globally
sudo npm install -g pm2

# Setup PM2 startup script (runs on boot)
sudo pm2 startup systemd -u $USER --hp /home/$USER

# Verify installation
pm2 --version
```

#### 1.5 Install Nginx

```bash
# Install Nginx
sudo apt install -y nginx

# Start and enable Nginx
sudo systemctl start nginx
sudo systemctl enable nginx

# Verify installation
nginx -v
sudo systemctl status nginx
```

---

### Phase 2: Clone Repository & Setup Project

#### 2.1 Create Application Directory

```bash
# Create application directory
sudo mkdir -p /var/www/hdav2
sudo chown -R $USER:$USER /var/www/hdav2

# Navigate to directory
cd /var/www/hdav2
```

#### 2.2 Clone GitHub Repository

```bash
# Clone repository
git clone https://github.com/o2scale/hdav2.git .

# Verify files
ls -la

# Check current branch
git branch
git status
```

#### 2.3 Setup Backend Python Environment

```bash
# Navigate to backend directory
cd /var/www/hdav2/backend

# Create Python virtual environment
python3.11 -m venv venv

# Activate virtual environment
source venv/bin/activate

# Upgrade pip
pip install --upgrade pip setuptools wheel

# Install production dependencies
pip install -r requirements.txt

# Verify installation
pip list
```

#### 2.4 Setup Frontend

```bash
# Navigate to frontend directory
cd /var/www/hdav2/frontend

# Install dependencies
npm ci --production=false

# Build for production
npm run build

# Verify build
ls -la dist/
```

---

### Phase 3: Environment Configuration

#### 3.1 Create Backend .env File

```bash
# Navigate to backend directory
cd /var/www/hdav2/backend

# Create .env file
cat > .env << 'EOF'
# Database Configuration (Supabase PostgreSQL)
DATABASE_URL=postgresql://postgres:[PASSWORD]@[HOST]:[PORT]/postgres

# Supabase Configuration
SUPABASE_URL=https://[YOUR-PROJECT].supabase.co
SUPABASE_SERVICE_KEY=[YOUR-SERVICE-KEY]
SUPABASE_ANON_KEY=[YOUR-ANON-KEY]

# Google Cloud / Vertex AI Configuration
GOOGLE_CLOUD_PROJECT=[YOUR-GCP-PROJECT-ID]
GOOGLE_APPLICATION_CREDENTIALS=/var/www/hdav2/backend/config/gcp-service-account.json
VERTEX_AI_LOCATION=us-central1

# API Configuration
API_HOST=0.0.0.0
API_PORT=8000
CORS_ORIGINS=["https://yourdomain.com","http://localhost:5173"]

# Worker Configuration
TEXT_EXTRACTION_WORKERS=2
TRANSLATION_WORKERS=6

# Environment
ENVIRONMENT=production
LOG_LEVEL=INFO
EOF

# Set proper permissions
chmod 600 .env
```

#### 3.2 Add Google Cloud Service Account Key

```bash
# Create config directory
mkdir -p /var/www/hdav2/backend/config

# Upload your GCP service account JSON
# Use scp, sftp, or paste content:
nano /var/www/hdav2/backend/config/gcp-service-account.json
# Paste your JSON content and save (Ctrl+X, Y, Enter)

# Set proper permissions
chmod 600 /var/www/hdav2/backend/config/gcp-service-account.json
```

#### 3.3 Create Frontend Environment File

```bash
# Navigate to frontend directory
cd /var/www/hdav2/frontend

# Create .env.production file
cat > .env.production << 'EOF'
VITE_SUPABASE_URL=https://[YOUR-PROJECT].supabase.co
VITE_SUPABASE_ANON_KEY=[YOUR-ANON-KEY]
VITE_API_URL=https://api.yourdomain.com
EOF

# Rebuild frontend with production env
npm run build
```

---

### Phase 4: PM2 Process Configuration

#### 4.1 Create PM2 Ecosystem File

```bash
# Navigate to project root
cd /var/www/hdav2

# Create PM2 ecosystem configuration
cat > ecosystem.config.js << 'EOF'
module.exports = {
  apps: [
    {
      name: 'hda-api',
      cwd: '/var/www/hdav2/backend',
      script: 'venv/bin/uvicorn',
      args: 'api.main:app --host 0.0.0.0 --port 8000 --workers 4',
      instances: 1,
      exec_mode: 'fork',
      autorestart: true,
      watch: false,
      max_memory_restart: '1G',
      env: {
        PYTHONPATH: '/var/www/hdav2/backend',
        ENVIRONMENT: 'production'
      },
      error_file: '/var/www/hdav2/logs/pm2-api-error.log',
      out_file: '/var/www/hdav2/logs/pm2-api-out.log',
      log_date_format: 'YYYY-MM-DD HH:mm:ss Z'
    },
    {
      name: 'hda-extraction-pool',
      cwd: '/var/www/hdav2/backend',
      script: 'venv/bin/python',
      args: 'workers/text_extraction_pool.py',
      instances: 1,
      exec_mode: 'fork',
      autorestart: true,
      watch: false,
      max_memory_restart: '2G',
      env: {
        PYTHONPATH: '/var/www/hdav2/backend',
        ENVIRONMENT: 'production'
      },
      error_file: '/var/www/hdav2/logs/pm2-extraction-error.log',
      out_file: '/var/www/hdav2/logs/pm2-extraction-out.log',
      log_date_format: 'YYYY-MM-DD HH:mm:ss Z'
    },
    {
      name: 'hda-translation-pool',
      cwd: '/var/www/hdav2/backend',
      script: 'venv/bin/python',
      args: 'workers/translation_worker.py',
      instances: 1,
      exec_mode: 'fork',
      autorestart: true,
      watch: false,
      max_memory_restart: '3G',
      env: {
        PYTHONPATH: '/var/www/hdav2/backend',
        ENVIRONMENT: 'production'
      },
      error_file: '/var/www/hdav2/logs/pm2-translation-error.log',
      out_file: '/var/www/hdav2/logs/pm2-translation-out.log',
      log_date_format: 'YYYY-MM-DD HH:mm:ss Z'
    },
    {
      name: 'hda-frontend',
      cwd: '/var/www/hdav2/frontend',
      script: 'npx',
      args: 'serve -s dist -l 5173',
      instances: 1,
      exec_mode: 'fork',
      autorestart: true,
      watch: false,
      max_memory_restart: '512M',
      env: {
        NODE_ENV: 'production'
      },
      error_file: '/var/www/hdav2/logs/pm2-frontend-error.log',
      out_file: '/var/www/hdav2/logs/pm2-frontend-out.log',
      log_date_format: 'YYYY-MM-DD HH:mm:ss Z'
    }
  ]
};
EOF
```

#### 4.2 Create Logs Directory

```bash
# Create logs directory
mkdir -p /var/www/hdav2/logs
mkdir -p /var/www/hdav2/backend/logs

# Set permissions
chmod 755 /var/www/hdav2/logs
chmod 755 /var/www/hdav2/backend/logs
```

#### 4.3 Install serve for Frontend (if not already installed)

```bash
# Install serve globally (lightweight static server)
sudo npm install -g serve
```

#### 4.4 Start All Processes with PM2

```bash
# Navigate to project root
cd /var/www/hdav2

# Start all applications
pm2 start ecosystem.config.js

# Check status
pm2 status

# View logs
pm2 logs

# Save PM2 configuration
pm2 save

# Setup PM2 to start on boot (if not done already)
sudo pm2 startup systemd -u $USER --hp /home/$USER
```

---

### Phase 5: Nginx Configuration

#### 5.1 Create Nginx Configuration for API

```bash
# Create API configuration
sudo nano /etc/nginx/sites-available/hda-api

# Paste the following configuration:
```

```nginx
# /etc/nginx/sites-available/hda-api

upstream hda_api {
    server 127.0.0.1:8000;
    keepalive 64;
}

server {
    listen 80;
    server_name api.yourdomain.com;  # Replace with your API domain

    # Increase client body size for file uploads
    client_max_body_size 200M;
    client_body_timeout 300s;

    # Logging
    access_log /var/log/nginx/hda-api-access.log;
    error_log /var/log/nginx/hda-api-error.log;

    location / {
        proxy_pass http://hda_api;
        proxy_http_version 1.1;

        # Headers
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection "upgrade";

        # Timeouts
        proxy_connect_timeout 300s;
        proxy_send_timeout 300s;
        proxy_read_timeout 300s;

        # Buffering
        proxy_buffering off;
        proxy_request_buffering off;
    }
}
```

#### 5.2 Create Nginx Configuration for Frontend

```bash
# Create frontend configuration
sudo nano /etc/nginx/sites-available/hda-frontend

# Paste the following configuration:
```

```nginx
# /etc/nginx/sites-available/hda-frontend

upstream hda_frontend {
    server 127.0.0.1:5173;
    keepalive 64;
}

server {
    listen 80;
    server_name yourdomain.com www.yourdomain.com;  # Replace with your domain

    # Logging
    access_log /var/log/nginx/hda-frontend-access.log;
    error_log /var/log/nginx/hda-frontend-error.log;

    # Gzip compression
    gzip on;
    gzip_vary on;
    gzip_min_length 1024;
    gzip_types text/plain text/css text/xml text/javascript application/x-javascript application/xml+rss application/javascript application/json;

    location / {
        proxy_pass http://hda_frontend;
        proxy_http_version 1.1;

        # Headers
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection "upgrade";

        # Cache static assets
        location ~* \.(js|css|png|jpg|jpeg|gif|ico|svg|woff|woff2|ttf|eot)$ {
            proxy_pass http://hda_frontend;
            expires 1y;
            add_header Cache-Control "public, immutable";
        }
    }
}
```

#### 5.3 Enable Sites and Restart Nginx

```bash
# Enable sites
sudo ln -s /etc/nginx/sites-available/hda-api /etc/nginx/sites-enabled/
sudo ln -s /etc/nginx/sites-available/hda-frontend /etc/nginx/sites-enabled/

# Test Nginx configuration
sudo nginx -t

# Restart Nginx
sudo systemctl restart nginx

# Check status
sudo systemctl status nginx
```

---

### Phase 6: SSL/HTTPS Setup with Let's Encrypt

#### 6.1 Install Certbot

```bash
# Install Certbot
sudo apt install -y certbot python3-certbot-nginx
```

#### 6.2 Obtain SSL Certificates

```bash
# For API domain
sudo certbot --nginx -d api.yourdomain.com

# For Frontend domain
sudo certbot --nginx -d yourdomain.com -d www.yourdomain.com

# Follow prompts to configure HTTPS
# Choose option 2: Redirect HTTP to HTTPS
```

#### 6.3 Setup Auto-Renewal

```bash
# Test renewal process
sudo certbot renew --dry-run

# Certbot automatically sets up a cron job for renewal
# Verify cron job exists
sudo systemctl status certbot.timer
```

---

### Phase 7: Database Setup (Supabase/PostgreSQL)

#### 7.1 Verify Database Connection

```bash
# Test database connection
cd /var/www/hdav2/backend
source venv/bin/activate

# Create test script
python3 << 'PYEOF'
import os
from dotenv import load_dotenv
import psycopg2

load_dotenv()
DATABASE_URL = os.getenv("DATABASE_URL")

try:
    conn = psycopg2.connect(DATABASE_URL)
    print("✅ Database connection successful!")
    cursor = conn.cursor()
    cursor.execute("SELECT version();")
    version = cursor.fetchone()
    print(f"PostgreSQL version: {version[0]}")
    cursor.close()
    conn.close()
except Exception as e:
    print(f"❌ Database connection failed: {e}")
PYEOF
```

#### 7.2 Run Database Migrations (if needed)

```bash
# If you have migration scripts, run them here
# Example:
# python manage.py migrate
# or
# alembic upgrade head
```

#### 7.3 Verify pgmq Queues

```bash
# Connect to PostgreSQL and verify queues exist
# If not, create them:

python3 << 'PYEOF'
import os
from dotenv import load_dotenv
import psycopg2

load_dotenv()
DATABASE_URL = os.getenv("DATABASE_URL")

conn = psycopg2.connect(DATABASE_URL)
cursor = conn.cursor()

# Create queues if they don't exist
cursor.execute("SELECT pgmq.create('text_extraction_queue');")
cursor.execute("SELECT pgmq.create('translation_queue');")

conn.commit()
print("✅ pgmq queues created/verified")
cursor.close()
conn.close()
PYEOF
```

---

### Phase 8: Post-Deployment Verification

#### 8.1 Check All PM2 Processes

```bash
# Check PM2 status
pm2 status

# Expected output: All 4 processes should be "online"
# - hda-api
# - hda-extraction-pool
# - hda-translation-pool
# - hda-frontend

# View logs for each process
pm2 logs hda-api --lines 50
pm2 logs hda-extraction-pool --lines 50
pm2 logs hda-translation-pool --lines 50
pm2 logs hda-frontend --lines 50
```

#### 8.2 Test API Endpoints

```bash
# Test health endpoint
curl http://localhost:8000/health

# Test API through Nginx (replace with your domain)
curl https://api.yourdomain.com/health

# Expected response:
# {"status": "healthy"}
```

#### 8.3 Test Frontend

```bash
# Test frontend directly
curl http://localhost:5173

# Test frontend through Nginx (replace with your domain)
curl https://yourdomain.com

# Should return HTML content
```

#### 8.4 Test File Upload

```bash
# Create a small test PDF
# Upload through the frontend UI and verify:
# 1. File uploads to Supabase storage
# 2. Text extraction worker processes the job
# 3. Translation worker can translate the content
# 4. Export functionality works
```

#### 8.5 Monitor Worker Logs

```bash
# Check extraction worker logs
tail -f /var/www/hdav2/backend/logs/text_extraction_worker_*.log

# Check translation worker logs
tail -f /var/www/hdav2/backend/logs/translation_worker_*.log

# Check PM2 logs
pm2 logs --lines 100
```

---

### Phase 9: Monitoring & Maintenance

#### 9.1 Setup PM2 Monitoring (Optional)

```bash
# Install PM2 monitoring dashboard
pm2 install pm2-logrotate

# Configure log rotation (keep 30 days)
pm2 set pm2-logrotate:retain 30
pm2 set pm2-logrotate:max_size 100M

# View monitoring dashboard
pm2 monit
```

#### 9.2 Setup System Monitoring

```bash
# Install htop for system monitoring
sudo apt install -y htop

# Monitor system resources
htop

# Check disk usage
df -h

# Check memory usage
free -h
```

#### 9.3 Backup Strategy

Create a backup script:

```bash
# Create backup script
cat > /var/www/hdav2/scripts/backup.sh << 'EOF'
#!/bin/bash
# HDA v2 Backup Script

BACKUP_DIR="/var/backups/hdav2"
DATE=$(date +%Y%m%d_%H%M%S)

# Create backup directory
mkdir -p "$BACKUP_DIR"

# Backup application files (excluding node_modules, venv, logs)
tar -czf "$BACKUP_DIR/hdav2_app_$DATE.tar.gz" \
    --exclude='node_modules' \
    --exclude='venv' \
    --exclude='logs' \
    --exclude='dist' \
    --exclude='.git' \
    /var/www/hdav2

# Backup environment files
cp /var/www/hdav2/backend/.env "$BACKUP_DIR/backend_env_$DATE"
cp /var/www/hdav2/frontend/.env.production "$BACKUP_DIR/frontend_env_$DATE"

# Keep only last 7 days of backups
find "$BACKUP_DIR" -name "*.tar.gz" -mtime +7 -delete
find "$BACKUP_DIR" -name "*_env_*" -mtime +7 -delete

echo "Backup completed: $BACKUP_DIR/hdav2_app_$DATE.tar.gz"
EOF

# Make executable
chmod +x /var/www/hdav2/scripts/backup.sh

# Setup daily backup cron job
(crontab -l 2>/dev/null; echo "0 2 * * * /var/www/hdav2/scripts/backup.sh >> /var/log/hdav2-backup.log 2>&1") | crontab -
```

#### 9.4 Update/Deployment Script

```bash
# Create deployment script for future updates
cat > /var/www/hdav2/scripts/deploy.sh << 'EOF'
#!/bin/bash
# HDA v2 Deployment Script

set -e  # Exit on error

echo "🚀 Starting deployment..."

# Navigate to project directory
cd /var/www/hdav2

# Pull latest changes
echo "📥 Pulling latest code..."
git pull origin main

# Backend updates
echo "🐍 Updating backend..."
cd backend
source venv/bin/activate
pip install -r requirements.txt
deactivate

# Frontend updates
echo "⚛️  Updating frontend..."
cd ../frontend
npm ci
npm run build

# Restart PM2 processes
echo "🔄 Restarting services..."
pm2 restart all

# Wait for services to start
sleep 5

# Check status
echo "✅ Checking service status..."
pm2 status

echo "🎉 Deployment completed!"
EOF

# Make executable
chmod +x /var/www/hdav2/scripts/deploy.sh
```

---

### Phase 10: Troubleshooting

#### Common Issues and Solutions

**Issue 1: PM2 Process Crashes**
```bash
# Check logs
pm2 logs <process-name> --err

# Check specific error log file
tail -f /var/www/hdav2/logs/pm2-<process>-error.log

# Restart process
pm2 restart <process-name>

# Check environment variables
pm2 env <process-id>
```

**Issue 2: Database Connection Errors**
```bash
# Verify .env file
cat /var/www/hdav2/backend/.env

# Test connection
cd /var/www/hdav2/backend
source venv/bin/activate
python -c "import psycopg2; import os; from dotenv import load_dotenv; load_dotenv(); print(psycopg2.connect(os.getenv('DATABASE_URL')))"
```

**Issue 3: Nginx 502 Bad Gateway**
```bash
# Check if backend is running
curl http://localhost:8000/health

# Check PM2 status
pm2 status

# Check Nginx error logs
sudo tail -f /var/log/nginx/error.log

# Restart Nginx
sudo systemctl restart nginx
```

**Issue 4: File Upload Fails**
```bash
# Check Nginx client_max_body_size
sudo grep -r "client_max_body_size" /etc/nginx/

# Check Supabase storage configuration
# Verify SUPABASE_SERVICE_KEY in .env

# Check API logs
pm2 logs hda-api --lines 100
```

**Issue 5: Worker Not Processing Jobs**
```bash
# Check worker logs
tail -f /var/www/hdav2/backend/logs/text_extraction_worker_*.log
tail -f /var/www/hdav2/backend/logs/translation_worker_*.log

# Verify pgmq queue exists and has jobs
# Connect to database and run:
# SELECT * FROM pgmq.q_text_extraction_queue LIMIT 10;
# SELECT * FROM pgmq.q_translation_queue LIMIT 10;

# Restart workers
pm2 restart hda-extraction-pool
pm2 restart hda-translation-pool
```

---

## Quick Reference Commands

```bash
# PM2 Commands
pm2 status                    # Check all processes
pm2 logs                      # View all logs
pm2 logs <name>              # View specific process logs
pm2 restart all              # Restart all processes
pm2 restart <name>           # Restart specific process
pm2 stop all                 # Stop all processes
pm2 start ecosystem.config.js # Start all from config
pm2 save                     # Save current process list
pm2 monit                    # Live monitoring dashboard

# Nginx Commands
sudo nginx -t                # Test configuration
sudo systemctl restart nginx # Restart Nginx
sudo systemctl status nginx  # Check status
sudo tail -f /var/log/nginx/error.log  # View error logs

# System Commands
htop                         # System monitor
df -h                        # Disk usage
free -h                      # Memory usage
sudo journalctl -u nginx -f  # Nginx system logs

# Application Commands
cd /var/www/hdav2
git pull origin main         # Pull latest code
./scripts/deploy.sh          # Run deployment script
./scripts/backup.sh          # Run backup script
```

---

## Security Checklist

- [ ] SSH key-based authentication enabled
- [ ] Password authentication disabled
- [ ] Firewall configured (ufw)
- [ ] SSL certificates installed
- [ ] Environment files have 600 permissions
- [ ] Database uses strong password
- [ ] Supabase RLS policies enabled
- [ ] API rate limiting configured
- [ ] Regular security updates scheduled
- [ ] Backup strategy implemented

---

## Support & Resources

- **HDA v2 Documentation**: `/var/www/hdav2/docs`
- **PM2 Documentation**: https://pm2.keymetrics.io/docs/usage/quick-start/
- **Nginx Documentation**: https://nginx.org/en/docs/
- **Let's Encrypt**: https://letsencrypt.org/docs/

---

**Deployment Completed Successfully! 🎉**
