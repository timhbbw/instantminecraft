FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive

# Install Java and tools
RUN apt-get update && \
    apt-get install -y curl jq openjdk-21-jdk-headless && \
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

# Start server
CMD ["java", "-Xms2G", "-Xmx4G", "-jar", "server.jar", "nogui"]
