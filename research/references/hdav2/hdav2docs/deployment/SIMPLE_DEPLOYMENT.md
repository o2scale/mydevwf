# HDA v2 - Simplified Deployment Guide (DigitalOcean)
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
**Droplet**: hdav2-ubuntu-s-1vcpu-2gb-blr1-01
**Domain**: hdav2.harikrishnamandir.org
**API Domain**: api.hdav2.harikrishnamandir.org
**Deploy Path**: `/home/hdadeploy/apps/hdav2/`

---

## Why Non-Root User?

**Critical Security Requirement:**
- Running as root = any bug/hack gets full system access
- Non-root user = contained damage, industry standard
- Takes 2 minutes, saves you from disasters

---

## Step-by-Step Deployment

### 1. Initial Setup (as root)

```bash
# SSH as root
ssh root@hdav2.harikrishnamandir.org

# Update system
apt update && apt upgrade -y

# Create deployment user
adduser hdadeploy
# Set password when prompted

# Add to sudo group (for installing packages)
usermod -aG sudo hdadeploy

# Setup SSH access for new user
mkdir -p /home/hdadeploy/.ssh
cp ~/.ssh/authorized_keys /home/hdadeploy/.ssh/
chown -R hdadeploy:hdadeploy /home/hdadeploy/.ssh
chmod 700 /home/hdadeploy/.ssh
chmod 600 /home/hdadeploy/.ssh/authorized_keys

# Test - open new terminal and try:
# ssh hdadeploy@hdav2.harikrishnamandir.org
# If it works, continue. If not, check SSH setup.

# Switch to deployment user
su - hdadeploy
```

### 2. Install Required Software

```bash
# System dependencies
sudo apt install -y build-essential curl wget git vim \
    libpq-dev python3-dev ufw

# Install Python 3
sudo apt install -y python3 python3-pip python3-venv

# Install Node.js 20.x
curl -fsSL https://deb.nodesource.com/setup_20.x | sudo -E bash -
sudo apt install -y nodejs

# Install PM2
sudo npm install -g pm2 serve

# Install Nginx
sudo apt install -y nginx

# Install SSL tool
sudo apt install -y certbot python3-certbot-nginx

# Setup firewall
sudo ufw allow OpenSSH
sudo ufw allow 'Nginx Full'
sudo ufw --force enable
```

### 3. Clone Repository

```bash
# Create apps directory
mkdir -p ~/apps
cd ~/apps

# Clone repo
git clone https://github.com/o2scale/hdav2.git
cd hdav2

# You're now in: /home/hdadeploy/apps/hdav2/
pwd
```

### 4. Setup Backend

```bash
cd ~/apps/hdav2/backend

# Create virtual environment
python3 -m venv venv

# Install dependencies
source venv/bin/activate
pip install --upgrade pip
pip install -r requirements.txt
deactivate
```

### 5. Setup Frontend

```bash
cd ~/apps/hdav2/frontend

# Install dependencies
npm ci
```

### 6. Configure Environment

#### Backend .env

```bash
cd ~/apps/hdav2/backend

# Create .env file
nano .env
```

Paste this configuration:

```env
# ============================================
# Supabase Configuration
# ============================================
SUPABASE_URL=https://axxqiiszvdtialoxwkul.supabase.co
SUPABASE_ANON_KEY=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImF4eHFpaXN6dmR0aWFsb3h3a3VsIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTk0MzE1MDksImV4cCI6MjA3NTAwNzUwOX0.5C_WN0wqy_ewnQsoCqYK5aowNm6fs21D-cRdkDlW0PQ
SUPABASE_SERVICE_KEY=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImF4eHFpaXN6dmR0aWFsb3h3a3VsIiwicm9sZSI6InNlcnZpY2Vfcm9sZSIsImlhdCI6MTc1OTQzMTUwOSwiZXhwIjoyMDc1MDA3NTA5fQ.vaTGkkTuza8PQtOpMJbivlJpoIm6BT5TdBQBCZBq5-U
SUPABASE_DB_PASSWORD=3jiuFwGV4s4BDUkG

# PostgreSQL Direct Connection (Session Pooler - Port 5432)
DATABASE_URL=postgresql://postgres.axxqiiszvdtialoxwkul:3jiuFwGV4s4BDUkG@aws-1-us-west-1.pooler.supabase.com:5432/postgres

# ============================================
# Vertex AI Configuration
# ============================================
GOOGLE_CLOUD_PROJECT=warm-composite-470517-n7
GOOGLE_CLOUD_PROJECT_ID=warm-composite-470517-n7
VERTEX_AI_LOCATION=us-central1
VERTEX_AI_MODEL=gemini-2.5-pro
GOOGLE_APPLICATION_CREDENTIALS=/home/hdadeploy/apps/hdav2/backend/config/vertex-ai-credentials.json

# Token Limits
VERTEX_AI_MAX_INPUT_TOKENS=1048576
VERTEX_AI_MAX_OUTPUT_TOKENS=65536

# ============================================
# API Configuration
# ============================================
API_HOST=0.0.0.0
API_PORT=8000
API_RELOAD=false
LOG_LEVEL=INFO
ENVIRONMENT=production

# ============================================
# CORS Configuration
# ============================================
CORS_ORIGINS=https://hdav2.harikrishnamandir.org,https://api.hdav2.harikrishnamandir.org

# ============================================
# Worker Configuration
# ============================================
WORKER_POOL_SIZE=2
TRANSLATION_WORKER_POOL_SIZE=4
WORKER_POLL_INTERVAL=2
WORKER_VISIBILITY_TIMEOUT=300

# ============================================
# Cost Management
# ============================================
ENABLE_COST_TRACKING=true
GCP_BUDGET_ALERT_THRESHOLD=500
GCP_BUDGET_CAP=1000
```

Save: `Ctrl+X`, `Y`, `Enter`

Set permissions:
```bash
chmod 600 .env
```

#### Add GCP Service Account

```bash
mkdir -p ~/apps/hdav2/backend/config

# Upload your service account JSON
nano ~/apps/hdav2/backend/config/vertex-ai-credentials.json
# Paste your JSON content from local backend/vertex-ai-credentials.json, then save

chmod 600 ~/apps/hdav2/backend/config/vertex-ai-credentials.json
```

**Important:** You need to copy the contents of your local `backend/vertex-ai-credentials.json` file to the server.

#### Frontend .env

```bash
cd ~/apps/hdav2/frontend

nano .env.production
```

Paste this configuration:

```env
# ============================================
# Supabase Configuration (Public Keys)
# ============================================
VITE_SUPABASE_URL=https://axxqiiszvdtialoxwkul.supabase.co
VITE_SUPABASE_ANON_KEY=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImF4eHFpaXN6dmR0aWFsb3h3a3VsIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTk0MzE1MDksImV4cCI6MjA3NTAwNzUwOX0.5C_WN0wqy_ewnQsoCqYK5aowNm6fs21D-cRdkDlW0PQ

# ============================================
# Backend API URL
# ============================================
VITE_API_URL=https://api.hdav2.harikrishnamandir.org
```

Build frontend:
```bash
npm run build
```

### 7. Create PM2 Configuration

```bash
cd ~/apps/hdav2

nano ecosystem.config.js
```

Paste this:

```javascript
module.exports = {
  apps: [
    {
      name: 'hda-api',
      cwd: '/home/hdadeploy/apps/hdav2/backend',
      script: 'venv/bin/uvicorn',
      args: 'api.main:app --host 0.0.0.0 --port 8000 --workers 2',
      instances: 1,
      autorestart: true,
      max_memory_restart: '800M',
      env: {
        PYTHONPATH: '/home/hdadeploy/apps/hdav2/backend',
        ENVIRONMENT: 'production'
      },
      error_file: '/home/hdadeploy/apps/hdav2/logs/api-error.log',
      out_file: '/home/hdadeploy/apps/hdav2/logs/api-out.log'
    },
    {
      name: 'hda-extraction',
      cwd: '/home/hdadeploy/apps/hdav2/backend',
      script: 'venv/bin/python',
      args: 'workers/text_extraction_pool.py',
      instances: 1,
      autorestart: true,
      max_memory_restart: '800M',
      env: {
        PYTHONPATH: '/home/hdadeploy/apps/hdav2/backend',
        ENVIRONMENT: 'production'
      },
      error_file: '/home/hdadeploy/apps/hdav2/logs/extraction-error.log',
      out_file: '/home/hdadeploy/apps/hdav2/logs/extraction-out.log'
    },
    {
      name: 'hda-translation',
      cwd: '/home/hdadeploy/apps/hdav2/backend',
      script: 'venv/bin/python',
      args: 'workers/translation_worker.py',
      instances: 1,
      autorestart: true,
      max_memory_restart: '800M',
      env: {
        PYTHONPATH: '/home/hdadeploy/apps/hdav2/backend',
        ENVIRONMENT: 'production',
        TRANSLATION_WORKERS: '4'
      },
      error_file: '/home/hdadeploy/apps/hdav2/logs/translation-error.log',
      out_file: '/home/hdadeploy/apps/hdav2/logs/translation-out.log'
    },
    {
      name: 'hda-frontend',
      cwd: '/home/hdadeploy/apps/hdav2/frontend',
      script: 'npx',
      args: 'serve -s dist -l 5173',
      instances: 1,
      autorestart: true,
      max_memory_restart: '300M',
      env: {
        NODE_ENV: 'production'
      },
      error_file: '/home/hdadeploy/apps/hdav2/logs/frontend-error.log',
      out_file: '/home/hdadeploy/apps/hdav2/logs/frontend-out.log'
    }
  ]
};
```

Create logs directory:
```bash
mkdir -p ~/apps/hdav2/logs
mkdir -p ~/apps/hdav2/backend/logs
```

### 8. Configure Nginx

#### API Configuration

```bash
sudo nano /etc/nginx/sites-available/hda-api
```

Paste:

```nginx
upstream hda_api {
    server 127.0.0.1:8000;
}

server {
    listen 80;
    server_name api.hdav2.harikrishnamandir.org;

    client_max_body_size 200M;
    client_body_timeout 300s;

    location / {
        proxy_pass http://hda_api;
        proxy_http_version 1.1;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection "upgrade";

        proxy_connect_timeout 300s;
        proxy_send_timeout 300s;
        proxy_read_timeout 300s;
    }
}
```

#### Frontend Configuration

```bash
sudo nano /etc/nginx/sites-available/hda-frontend
```

Paste:

```nginx
upstream hda_frontend {
    server 127.0.0.1:5173;
}

server {
    listen 80;
    server_name hdav2.harikrishnamandir.org;

    gzip on;
    gzip_types text/plain text/css text/javascript application/json;

    location / {
        proxy_pass http://hda_frontend;
        proxy_http_version 1.1;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection "upgrade";
    }
}
```

#### Enable Sites

```bash
# Enable configurations
sudo ln -s /etc/nginx/sites-available/hda-api /etc/nginx/sites-enabled/
sudo ln -s /etc/nginx/sites-available/hda-frontend /etc/nginx/sites-enabled/

# Remove default site
sudo rm /etc/nginx/sites-enabled/default

# Test and restart
sudo nginx -t
sudo systemctl restart nginx
```

### 9. Setup SSL

```bash
# Get certificates
sudo certbot --nginx -d hdav2.harikrishnamandir.org
sudo certbot --nginx -d api.hdav2.harikrishnamandir.org

# Choose option 2: Redirect HTTP to HTTPS
```

### 10. Start Applications

```bash
cd ~/apps/hdav2

# Start all with PM2
pm2 start ecosystem.config.js

# Check status
pm2 status

# Save configuration
pm2 save

# Setup auto-start on boot
pm2 startup
# Copy and run the command PM2 outputs
```

### 11. Enable Swap (for 2GB RAM)

```bash
# Create 2GB swap
sudo fallocate -l 2G /swapfile
sudo chmod 600 /swapfile
sudo mkswap /swapfile
sudo swapon /swapfile

# Make permanent
echo '/swapfile none swap sw 0 0' | sudo tee -a /etc/fstab
```

### 12. Verify Deployment

```bash
# Check PM2
pm2 status

# Check API
curl https://api.hdav2.harikrishnamandir.org/health

# Check frontend
curl https://hdav2.harikrishnamandir.org

# Monitor
pm2 monit
```

---

## Future Updates

```bash
cd ~/apps/hdav2

# Pull latest
git pull origin main

# Update backend
cd backend
source venv/bin/activate
pip install -r requirements.txt
deactivate

# Update frontend
cd ../frontend
npm ci
npm run build

# Restart
cd ..
pm2 restart all
```

---

## Common Commands

```bash
# PM2
pm2 status              # Check all processes
pm2 logs                # View all logs
pm2 logs hda-api        # View specific log
pm2 restart all         # Restart everything
pm2 monit              # Live monitoring

# System
htop                    # Monitor resources
free -h                 # Check memory
df -h                   # Check disk

# Nginx
sudo systemctl status nginx
sudo nginx -t
sudo systemctl restart nginx
```

---

## Troubleshooting

**PM2 won't start:**
```bash
pm2 logs hda-api --err
# Check .env file exists and has correct values
```

**502 Bad Gateway:**
```bash
pm2 status              # Is backend running?
curl http://localhost:8000/health
sudo systemctl restart nginx
```

**Out of memory:**
```bash
free -h                 # Check swap is enabled
pm2 monit              # Check process memory
# Reduce workers if needed
```

---

## Security Checklist

- [x] Non-root user created ✅
- [x] Firewall enabled (SSH, HTTP, HTTPS only) ✅
- [x] SSL certificates installed ✅
- [x] Environment files secured (600 permissions) ✅
- [ ] Disable root SSH login (optional):
  ```bash
  sudo nano /etc/ssh/sshd_config
  # Set: PermitRootLogin no
  sudo systemctl restart sshd
  ```

---

## Your Live URLs

- **Frontend**: https://hdav2.harikrishnamandir.org
- **API**: https://api.hdav2.harikrishnamandir.org/health

---

**Deployment Complete! 🎉**

Everything runs as user `hdadeploy` in `/home/hdadeploy/apps/hdav2/`
