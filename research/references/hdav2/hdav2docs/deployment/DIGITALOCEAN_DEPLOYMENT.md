# HDA v2 - DigitalOcean Deployment Guide

**Droplet**: hdav2-ubuntu-s-1vcpu-2gb-blr1-01
**Specs**: 2 GB Memory / 1 AMD vCPU / 50 GB Disk / BLR1 - Ubuntu 25.04 x64
**Domain**: hdav2.harikrishnamandir.org
**API Domain**: api.hdav2.harikrishnamandir.org
**Region**: Bangalore (BLR1)

---

## 🚀 Quick Deployment Steps

### Step 1: Initial SSH Access

```bash
# SSH into your droplet
ssh root@hdav2.harikrishnamandir.org

# Update system
apt update && apt upgrade -y
```

### Step 2: Create Non-Root User (Recommended)

```bash
# Create deployment user
adduser hdadeploy
usermod -aG sudo hdadeploy

# Setup SSH for new user
mkdir -p /home/hdadeploy/.ssh
cp ~/.ssh/authorized_keys /home/hdadeploy/.ssh/
chown -R hdadeploy:hdadeploy /home/hdadeploy/.ssh
chmod 700 /home/hdadeploy/.ssh
chmod 600 /home/hdadeploy/.ssh/authorized_keys

# Switch to new user
su - hdadeploy
```

### Step 3: Install Required Software

```bash
# Install system dependencies
sudo apt install -y build-essential curl wget git vim software-properties-common \
    libpq-dev python3-dev ufw

# Install Python 3.11 (Ubuntu 25.04 might have 3.12+, adjust if needed)
sudo apt install -y python3 python3-pip python3-venv

# Verify Python version
python3 --version  # Should be 3.11+ or 3.12+

# Install Node.js 20.x LTS
curl -fsSL https://deb.nodesource.com/setup_20.x | sudo -E bash -
sudo apt install -y nodejs

# Verify Node.js
node --version   # v20.x.x
npm --version    # 10.x.x

# Install PM2
sudo npm install -g pm2

# Install Nginx
sudo apt install -y nginx

# Install Certbot for SSL
sudo apt install -y certbot python3-certbot-nginx
```

### Step 4: Configure Firewall

```bash
# Setup UFW firewall
sudo ufw allow OpenSSH
sudo ufw allow 'Nginx Full'
sudo ufw enable

# Check status
sudo ufw status
```

### Step 5: Clone Repository

```bash
# Create application directory
sudo mkdir -p /var/www/hdav2
sudo chown -R hdadeploy:hdadeploy /var/www/hdav2

# Clone repository
cd /var/www/hdav2
git clone https://github.com/o2scale/hdav2.git .

# Verify
ls -la
git branch
```

### Step 6: Setup Backend

```bash
cd /var/www/hdav2/backend

# Create virtual environment
python3 -m venv venv

# Activate and install dependencies
source venv/bin/activate
pip install --upgrade pip
pip install -r requirements.txt

# Deactivate
deactivate
```

### Step 7: Setup Frontend

```bash
cd /var/www/hdav2/frontend

# Install dependencies
npm ci

# Build for production (we'll configure env first)
# npm run build  # Run this after creating .env.production
```

### Step 8: Configure Environment Variables

#### Backend .env

```bash
cd /var/www/hdav2/backend

cat > .env << 'EOF'
# Database Configuration (Supabase PostgreSQL)
DATABASE_URL=postgresql://postgres:YOUR_PASSWORD@YOUR_HOST:5432/postgres

# Supabase Configuration
SUPABASE_URL=https://YOUR_PROJECT.supabase.co
SUPABASE_SERVICE_KEY=YOUR_SERVICE_KEY
SUPABASE_ANON_KEY=YOUR_ANON_KEY

# Google Cloud / Vertex AI Configuration
GOOGLE_CLOUD_PROJECT=YOUR_GCP_PROJECT_ID
GOOGLE_APPLICATION_CREDENTIALS=/var/www/hdav2/backend/config/gcp-service-account.json
VERTEX_AI_LOCATION=us-central1

# API Configuration
API_HOST=0.0.0.0
API_PORT=8000
CORS_ORIGINS=["https://hdav2.harikrishnamandir.org","https://api.hdav2.harikrishnamandir.org"]

# Worker Configuration
TEXT_EXTRACTION_WORKERS=2
TRANSLATION_WORKERS=4

# Environment
ENVIRONMENT=production
LOG_LEVEL=INFO
EOF

# Edit with your actual credentials
nano .env

# Set secure permissions
chmod 600 .env
```

#### Add GCP Service Account Key

```bash
# Create config directory
mkdir -p /var/www/hdav2/backend/config

# Upload your service account JSON
# Option 1: Use nano to paste content
nano /var/www/hdav2/backend/config/gcp-service-account.json

# Option 2: Use scp from your local machine
# From your local machine:
# scp gcp-service-account.json hdadeploy@hdav2.harikrishnamandir.org:/var/www/hdav2/backend/config/

# Set secure permissions
chmod 600 /var/www/hdav2/backend/config/gcp-service-account.json
```

#### Frontend .env.production

```bash
cd /var/www/hdav2/frontend

cat > .env.production << 'EOF'
VITE_SUPABASE_URL=https://YOUR_PROJECT.supabase.co
VITE_SUPABASE_ANON_KEY=YOUR_ANON_KEY
VITE_API_URL=https://api.hdav2.harikrishnamandir.org
EOF

# Edit with your actual credentials
nano .env.production

# Now build frontend
npm run build
```

### Step 9: Create PM2 Ecosystem File

```bash
cd /var/www/hdav2

cat > ecosystem.config.js << 'EOF'
module.exports = {
  apps: [
    {
      name: 'hda-api',
      cwd: '/var/www/hdav2/backend',
      script: 'venv/bin/uvicorn',
      args: 'api.main:app --host 0.0.0.0 --port 8000 --workers 2',
      instances: 1,
      exec_mode: 'fork',
      autorestart: true,
      watch: false,
      max_memory_restart: '800M',
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
      max_memory_restart: '800M',
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
      max_memory_restart: '800M',
      env: {
        PYTHONPATH: '/var/www/hdav2/backend',
        ENVIRONMENT: 'production',
        TRANSLATION_WORKERS: '4'
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
      max_memory_restart: '300M',
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

**Note**: Adjusted memory limits for 2GB droplet:
- API: 800MB (reduced from 1GB)
- Workers: 800MB each (reduced from 2-3GB)
- Frontend: 300MB (reduced from 512MB)
- Total: ~2.7GB peak (with system overhead, fits in 2GB with swap)

### Step 10: Create Logs Directory

```bash
mkdir -p /var/www/hdav2/logs
mkdir -p /var/www/hdav2/backend/logs
chmod 755 /var/www/hdav2/logs
chmod 755 /var/www/hdav2/backend/logs
```

### Step 11: Install serve for Frontend

```bash
sudo npm install -g serve
```

### Step 12: Configure Nginx

#### API Configuration

```bash
sudo nano /etc/nginx/sites-available/hda-api
```

Paste this configuration:

```nginx
upstream hda_api {
    server 127.0.0.1:8000;
    keepalive 32;
}

server {
    listen 80;
    server_name api.hdav2.harikrishnamandir.org;

    client_max_body_size 200M;
    client_body_timeout 300s;

    access_log /var/log/nginx/hda-api-access.log;
    error_log /var/log/nginx/hda-api-error.log;

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

        proxy_buffering off;
        proxy_request_buffering off;
    }
}
```

#### Frontend Configuration

```bash
sudo nano /etc/nginx/sites-available/hda-frontend
```

Paste this configuration:

```nginx
upstream hda_frontend {
    server 127.0.0.1:5173;
    keepalive 32;
}

server {
    listen 80;
    server_name hdav2.harikrishnamandir.org;

    access_log /var/log/nginx/hda-frontend-access.log;
    error_log /var/log/nginx/hda-frontend-error.log;

    gzip on;
    gzip_vary on;
    gzip_min_length 1024;
    gzip_types text/plain text/css text/xml text/javascript application/x-javascript application/xml+rss application/javascript application/json;

    location / {
        proxy_pass http://hda_frontend;
        proxy_http_version 1.1;

        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection "upgrade";
    }

    location ~* \.(js|css|png|jpg|jpeg|gif|ico|svg|woff|woff2|ttf|eot)$ {
        proxy_pass http://hda_frontend;
        expires 1y;
        add_header Cache-Control "public, immutable";
    }
}
```

#### Enable Sites

```bash
# Enable configurations
sudo ln -s /etc/nginx/sites-available/hda-api /etc/nginx/sites-enabled/
sudo ln -s /etc/nginx/sites-available/hda-frontend /etc/nginx/sites-enabled/

# Test configuration
sudo nginx -t

# Restart Nginx
sudo systemctl restart nginx
sudo systemctl enable nginx
```

### Step 13: Setup SSL with Let's Encrypt

```bash
# Obtain SSL certificates
sudo certbot --nginx -d hdav2.harikrishnamandir.org
sudo certbot --nginx -d api.hdav2.harikrishnamandir.org

# Follow prompts:
# - Enter email address
# - Agree to terms
# - Choose option 2: Redirect HTTP to HTTPS

# Test auto-renewal
sudo certbot renew --dry-run
```

### Step 14: Start PM2 Processes

```bash
cd /var/www/hdav2

# Start all applications
pm2 start ecosystem.config.js

# Check status
pm2 status

# View logs
pm2 logs --lines 50

# Save PM2 configuration
pm2 save

# Setup PM2 to start on boot
sudo pm2 startup systemd -u hdadeploy --hp /home/hdadeploy
# Copy and run the command that PM2 outputs
```

### Step 15: Verify Deployment

```bash
# Check PM2 processes (all should be "online")
pm2 status

# Test API locally
curl http://localhost:8000/health

# Test API through Nginx
curl https://api.hdav2.harikrishnamandir.org/health

# Test frontend
curl https://hdav2.harikrishnamandir.org

# Monitor logs
pm2 logs --lines 100
```

### Step 16: Monitor Resources (Important for 2GB RAM)

```bash
# Install htop for monitoring
sudo apt install -y htop

# Monitor in real-time
htop

# Check memory usage
free -h

# If you need more memory, enable swap:
sudo fallocate -l 2G /swapfile
sudo chmod 600 /swapfile
sudo mkswap /swapfile
sudo swapon /swapfile

# Make swap permanent
echo '/swapfile none swap sw 0 0' | sudo tee -a /etc/fstab
```

---

## 📊 Performance Optimization for 2GB Droplet

### Reduce Worker Concurrency

Your configuration is already optimized:
- API: 2 Uvicorn workers (instead of 4)
- Text Extraction: 2 workers
- Translation: 4 workers (sequential processing)

### Monitor Memory Usage

```bash
# Check current memory
pm2 status
pm2 monit

# If memory issues occur, reduce workers further:
pm2 stop all
# Edit ecosystem.config.js:
# - Set API workers to 1
# - Reduce TRANSLATION_WORKERS to 2
pm2 start ecosystem.config.js
```

---

## 🔧 Maintenance Commands

```bash
# View all process status
pm2 status

# View specific process logs
pm2 logs hda-api --lines 50
pm2 logs hda-extraction-pool --lines 50
pm2 logs hda-translation-pool --lines 50
pm2 logs hda-frontend --lines 50

# Restart specific process
pm2 restart hda-api
pm2 restart hda-extraction-pool

# Restart all
pm2 restart all

# Stop all
pm2 stop all

# Monitor real-time
pm2 monit

# Check Nginx
sudo systemctl status nginx
sudo nginx -t

# View Nginx logs
sudo tail -f /var/log/nginx/hda-api-error.log
sudo tail -f /var/log/nginx/hda-frontend-error.log
```

---

## 🚀 Future Updates Deployment

Create update script:

```bash
cat > /var/www/hdav2/scripts/update.sh << 'EOF'
#!/bin/bash
set -e

echo "🔄 Pulling latest changes..."
cd /var/www/hdav2
git pull origin main

echo "🐍 Updating backend..."
cd backend
source venv/bin/activate
pip install -r requirements.txt
deactivate

echo "⚛️  Updating frontend..."
cd ../frontend
npm ci
npm run build

echo "🔄 Restarting services..."
pm2 restart all

echo "✅ Update complete!"
pm2 status
EOF

chmod +x /var/www/hdav2/scripts/update.sh
```

To update in future:

```bash
cd /var/www/hdav2
./scripts/update.sh
```

---

## 🔒 Security Checklist

- [x] UFW firewall enabled (SSH, HTTP, HTTPS only)
- [ ] SSH key-based authentication (disable password auth)
- [x] Non-root user created
- [x] SSL certificates installed
- [x] Environment files secured (600 permissions)
- [ ] Regular security updates scheduled
- [ ] Fail2ban installed (optional, recommended)

### Optional: Install Fail2ban

```bash
sudo apt install -y fail2ban
sudo systemctl enable fail2ban
sudo systemctl start fail2ban
```

---

## 📞 Quick Troubleshooting

**Issue: PM2 process keeps restarting**
```bash
# Check logs
pm2 logs <process-name> --err --lines 100

# Check memory
free -h
pm2 monit

# Enable swap if needed (see Step 16)
```

**Issue: 502 Bad Gateway**
```bash
# Check if backend is running
pm2 status
curl http://localhost:8000/health

# Check Nginx
sudo nginx -t
sudo systemctl restart nginx
```

**Issue: SSL certificate errors**
```bash
# Renew certificates
sudo certbot renew
sudo systemctl restart nginx
```

---

## 🎯 Your URLs

- **Frontend**: https://hdav2.harikrishnamandir.org
- **API**: https://api.hdav2.harikrishnamandir.org
- **API Health Check**: https://api.hdav2.harikrishnamandir.org/health

---

## ✅ Deployment Complete!

Your HDA v2 platform is now running on:
- **Droplet**: hdav2-ubuntu-s-1vcpu-2gb-blr1-01
- **Location**: Bangalore (BLR1)
- **Domain**: hdav2.harikrishnamandir.org
- **SSL**: Enabled via Let's Encrypt
- **Process Manager**: PM2 with auto-restart

**Next Steps:**
1. Test document upload
2. Test text extraction
3. Test translation (5 languages)
4. Test PDF export
5. Monitor resource usage with `htop` and `pm2 monit`

🎉 **Production Deployment Successful!**
