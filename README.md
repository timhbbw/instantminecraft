# Minecraft Server - One-Click Deployment

Deploy Minecraft server to your home server with one button click using GitHub Actions self-hosted runner.

## Project Files
```
minecraft-server/
├── .github/workflows/deploy.yml  # Deployment automation
├── Dockerfile                     # Server container
├── server.properties              # Your server config
└── README.md                      # This file
```

---

## Setup (One-Time)

### Step 1: Install GitHub Runner on Your Home Server

1. **SSH into your home server**

2. **Install Docker** (if not installed):
```bash
curl -fsSL https://get.docker.com -o get-docker.sh
sudo sh get-docker.sh
sudo usermod -aG docker $USER
```

3. **Create runner directory**:
```bash
mkdir -p ~/actions-runner && cd ~/actions-runner
```

4. **Download GitHub Runner**:
```bash
# For Linux x64
curl -o actions-runner-linux-x64-2.311.0.tar.gz -L https://github.com/actions/runner/releases/download/v2.311.0/actions-runner-linux-x64-2.311.0.tar.gz
tar xzf ./actions-runner-linux-x64-2.311.0.tar.gz
```

5. **Configure Runner**:
   - Go to your GitHub repo → **Settings** → **Actions** → **Runners** → **New self-hosted runner**
   - Copy the configuration command and run it:
```bash
./config.sh --url https://github.com/YOUR-USERNAME/minecraft-server --token YOUR-TOKEN
```
   - When asked "Enter name of runner": press Enter (default)
   - When asked "Enter any additional labels": press Enter
   - When asked "Enter name of work folder": press Enter

6. **Install and start runner as a service**:
```bash
sudo ./svc.sh install
sudo ./svc.sh start
```

7. **Verify runner is online**:
   - Go to your repo → **Settings** → **Actions** → **Runners**
   - You should see your runner with a green dot (Idle)

### Step 2: Setup Repository

1. **Create new GitHub repository**

2. **Clone and add files**:
```bash
git clone https://github.com/YOUR-USERNAME/minecraft-server.git
cd minecraft-server

# Add these 4 files:
# - .github/workflows/deploy.yml
# - Dockerfile
# - server.properties
# - README.md
```

3. **Push to GitHub**:
```bash
git add .
git commit -m "Initial setup"
git push
```

---

## Usage

### Deploy Server (One Click!)

1. Go to your GitHub repo
2. Click **Actions** tab
3. Click **Deploy Minecraft Server** workflow
4. Click **Run workflow** dropdown
5. Click green **Run workflow** button

That's it! Your server will:
- Build the Docker image
- Stop old server (if running)
- Start new server
- Show you the logs

**Connection:** `<your-home-ip>:22000`

### Check Server Status

```bash
# On your home server
docker logs minecraft-server
docker ps
```

### Stop Server

```bash
docker stop minecraft-server
```

### Manual Start (without GitHub)

```bash
docker start minecraft-server
```

---

## Server Configuration

Edit `server.properties` and push to GitHub. Next deployment will use new settings.

Current settings:
- **Port:** 22000
- **RCON Port:** 22001
- **RCON Password:** password
- **Max Players:** 20
- **Gamemode:** Survival

---

## Troubleshooting

### Runner Not Showing in GitHub
```bash
# Check runner status
cd ~/actions-runner
sudo ./svc.sh status

# Restart runner
sudo ./svc.sh stop
sudo ./svc.sh start
```

### Port Already in Use
```bash
# Find and stop the process
sudo netstat -tulpn | grep 22000
docker stop minecraft-server
```

### Can't Connect to Server
```bash
# Check firewall
sudo ufw allow 22000/tcp
sudo ufw allow 22001/tcp

# Check if server is running
docker ps | grep minecraft
docker logs minecraft-server
```

### Update Runner
```bash
cd ~/actions-runner
sudo ./svc.sh stop
./config.sh remove --token YOUR-TOKEN
# Download new version and reconfigure
sudo ./svc.sh install
sudo ./svc.sh start
```

---

## Advanced

### Backup World
```bash
docker run --rm \
  -v minecraft-world:/data \
  -v $(pwd):/backup \
  ubuntu tar czf /backup/backup-$(date +%Y%m%d).tar.gz /data
```

### Restore World
```bash
docker stop minecraft-server
docker run --rm \
  -v minecraft-world:/data \
  -v $(pwd):/backup \
  ubuntu tar xzf /backup/backup-YYYYMMDD.tar.gz -C /
docker start minecraft-server
```

### View Live Logs
```bash
docker logs -f minecraft-server
```

### Access Console
```bash
docker attach minecraft-server
# Press Ctrl+P then Ctrl+Q to detach without stopping
```

---

## How It Works

1. You click "Run workflow" in GitHub
2. GitHub sends job to your self-hosted runner
3. Runner (on your home server) executes the workflow
4. Workflow builds Docker image and starts container
5. Server is live!

All automatic, no manual commands needed!

---

**That's it! Push button → Server deployed! 🚀**
