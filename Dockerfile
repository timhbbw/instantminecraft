FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive

# Install Java, tools, and screen
RUN apt-get update && \
    apt-get install -y curl jq openjdk-21-jdk-headless screen && \
    rm -rf /var/lib/apt/lists/*

# Create Minecraft directory
WORKDIR /minecraft

# Download latest Minecraft server
RUN curl -s https://launchermeta.mojang.com/mc/game/version_manifest.json \
    | jq -r '.latest.release as $v | .versions[] | select(.id == $v) | .url' \
    | xargs curl -s \
    | jq -r '.downloads.server.url' \
    | xargs curl -o server.jar

# Accept EULA and copy server config
RUN echo "eula=true" > eula.txt
COPY server.properties .

# Expose ports
EXPOSE 22000 22001

# Create startup script
RUN echo '#!/bin/bash\n\
screen -dmS minecraft java -Xms2G -Xmx4G -jar server.jar nogui\n\
echo "Server started in screen session: minecraft"\n\
echo "Attach with: docker exec -it minecraft-server screen -r minecraft"\n\
echo "Detach with: Ctrl+A then D"\n\
# Keep container running\n\
tail -f /dev/null' > /start.sh && chmod +x /start.sh

# Start server in screen
CMD ["/start.sh"]
