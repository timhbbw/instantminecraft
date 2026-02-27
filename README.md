# Minecraft Server - One-Click Deployment

Deploy Minecraft server to your home server with one button click using GitHub Actions or GitLab CI/CD.

## Project Files

### For GitHub:
```
minecraft-server/
├── .github/workflows/deploy.yml
├── Dockerfile
├── server.properties
└── README.md
```

### For GitLab:
```
minecraft-server/
├── .gitlab-ci.yml
├── Dockerfile
├── server.properties
└── README.md
```

---

## Setup (One-Time)

# GitHub Setup

### Step 1: Install GitHub Runner on Your Home Server

1. **Install Docker**:
```bash
curl -fsSL https://get.docker.com -o get-docker.sh
sudo sh get-docker.sh
sudo usermod -aG docker $USER
newgrp docker
```

2. **Create runner directory**:
```bash
mkdir -p ~/actions-runner && cd ~/actions-runner
```

3. **Download GitHub Runner**:
```bash
curl -o actions-runner-linux-x64-2.311.0.tar.gz -L https://github.com/actions/runner/releases/download/v2.311.0/actions-runner-linux-x64-2.311.0.tar.gz
tar xzf ./actions-runner-linux-x64-2.311.0.tar.gz
```

4. **Configure Runner**:
   - Go to GitHub repo → **Settings** → **Actions** → **Runners** → **New self-hosted runner**
   - Run the configuration command provided:
```bash
./config.sh --url https://github.com/YOUR-USERNAME/minecraft-server --token YOUR-TOKEN
```

5. **Start runner as service**:
```bash
sudo ./svc.sh install
sudo ./svc.sh start
```

### Step 2: Push to GitHub
```bash
git add .
git commit -m "Initial setup"
git push
```

### Deploy on GitHub
1. Go to **Actions** tab
2. Click **Deploy Minecraft Server**
3. Click **Run workflow**

---

# GitLab Setup

### Step 1: Install GitLab Runner on Your Home Server

1. **Install Docker**:
```bash
curl -fsSL https://get.docker.com -o get-docker.sh
sudo sh get-docker.sh
sudo usermod -aG docker $USER
newgrp docker
```

2. **Install GitLab Runner**:
```bash
curl -L "https://packages.gitlab.com/install/repositories/runner/gitlab-runner/script.deb.sh" | sudo bash
sudo apt-get install gitlab-runner
```

3. **Register Runner**:
   - Go to GitLab project → **Settings** → **CI/CD** → **Runners**
   - Click **New project runner**, add tag `minecraft`, copy token
```bash
sudo gitlab-runner register
```
   - URL: `https://gitlab.com`
   - Token: (paste token)
   - Tags: `minecraft`
   - Executor: `shell`

4. **Add runner to docker group**:
```bash
sudo usermod -aG docker gitlab-runner
sudo systemctl restart gitlab-runner
```

### Step 2: Push to GitLab
```bash
git add .
git commit -m "Initial setup"
git push
```

### Deploy on GitLab
1. Go to **CI/CD** → **Pipelines**
2. Click **Run pipeline**
3. Click **Play** button (▶)

---

## Usage

### Deploy Server
- **GitHub**: Actions → Run workflow
- **GitLab**: CI/CD → Pipelines → Run → Play

### Check Status
```bash
docker logs minecraft-server
docker ps
```

### Stop/Start
```bash
docker stop minecraft-server
docker start minecraft-server
```

### Access Server Console
The server runs in a `screen` session inside the container:
```bash
# Attach to console
docker exec -it minecraft-server screen -r minecraft

# Detach from console (keep server running)
# Press: Ctrl+A then D
```

Commands you can run in console:
```
/list                    # Show online players
/say <message>           # Broadcast message
/op <player>             # Make player operator
/stop                    # Stop server
/save-all                # Save world
/whitelist add <player>  # Add to whitelist
```

---

## Server Info

**Connection:** `<your-home-ip>:22000`

**Settings:**
- Port: 22000
- RCON Port: 22001
- RCON Password: password
- Max Players: 20

Edit `server.properties` and push to deploy changes.

---

## Troubleshooting

### GitHub Runner
```bash
cd ~/actions-runner
sudo ./svc.sh status
sudo ./svc.sh restart
```

### GitLab Runner
```bash
sudo gitlab-runner status
sudo gitlab-runner restart
```

### Firewall
```bash
sudo ufw allow 22000/tcp
sudo ufw allow 22001/tcp
```

---

## Backup/Restore

### Backup
```bash
# Announce to players and save
docker exec -it minecraft-server screen -S minecraft -X stuff "say Backup starting...^M"
docker exec -it minecraft-server screen -S minecraft -X stuff "save-all^M"
sleep 5

# Create backup
docker run --rm -v minecraft-world:/data -v $(pwd):/backup ubuntu tar czf /backup/backup.tar.gz /data
echo "Backup complete!"
```

### Restore
```bash
docker stop minecraft-server
docker run --rm -v minecraft-world:/data -v $(pwd):/backup ubuntu tar xzf /backup/backup.tar.gz -C /
docker start minecraft-server
```

---

## Server Management Tips

### Screen Session Commands
```bash
# List screen sessions
docker exec minecraft-server screen -ls

# Send command to server (without attaching)
docker exec -it minecraft-server screen -S minecraft -X stuff "say Hello!^M"

# View logs without attaching
docker exec minecraft-server screen -S minecraft -X hardcopy /tmp/screen.log
docker exec minecraft-server cat /tmp/screen.log
```

### Restart Server (from console)
```bash
# Attach to console
docker exec -it minecraft-server screen -r minecraft

# Type in console:
/stop

# Then restart container
docker start minecraft-server
```

---

**Choose your platform and click to deploy! 🚀**
