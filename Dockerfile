# Use an official lightweight base image
FROM ubuntu:20.04

# Set environment variables
ENV DEBIAN_FRONTEND=noninteractive
ENV DISPLAY=:10
ENV VNC_PORT=5900
ENV USER_DATA_DIR=/tmp/chrome-data
ENV DEBUG_PORT=19222

# Install necessary packages
RUN apt-get update && apt-get install -y --no-install-recommends \
    ca-certificates \
    curl \
    gnupg2 \
    socat \
    sudo \
    xvfb \
    x11vnc \
    fluxbox \
    xterm \
    supervisor && \
    rm -rf /var/lib/apt/lists/*

# Add Chrome's repository and install Google Chrome
RUN curl -fsSL https://dl-ssl.google.com/linux/linux_signing_key.pub | apt-key add - && \
    echo "deb [arch=amd64] http://dl.google.com/linux/chrome/deb/ stable main" > /etc/apt/sources.list.d/google-chrome.list && \
    apt-get update && apt-get install -y google-chrome-stable && \
    rm -rf /var/lib/apt/lists/*

# Add a normal user with passwordless sudo
RUN groupadd -g 1001 usergroup && \
    useradd -u 1001 -g usergroup -G sudo --shell /bin/bash --no-create-home --home-dir /tmp user && \
    echo 'ALL ALL = (ALL:ALL) NOPASSWD: ALL' >> /etc/sudoers

# Set up X11VNC password (you can change '1234567' to your preferred password)
RUN mkdir -p /tmp/.vnc && \
    x11vnc -storepasswd 1234567 /tmp/.vnc/passwd && \
    chown -R user:usergroup /tmp/.vnc

# Set up Chrome data directory with proper permissions
RUN mkdir -p /tmp/chrome-data && \
    chown -R user:usergroup /tmp/chrome-data

# Set up supervisor directories and permissions
RUN mkdir -p /var/log/supervisor && \
    chown -R user:usergroup /var/log/supervisor && \
    chown -R user:usergroup /etc/supervisor

# Copy supervisor configuration file
COPY supervisord.conf /etc/supervisor/conf.d/supervisord.conf

# Switch to the normal user
USER user

# Set the working directory to /tmp
WORKDIR /tmp

# Expose the volume for Chrome data
VOLUME /tmp/chrome-data

# Expose VNC port (this will be dynamically assigned)
EXPOSE 5900

# Start supervisor to manage services
CMD ["supervisord", "-c", "/etc/supervisor/conf.d/supervisord.conf"]

HEALTHCHECK --interval=30s --timeout=30s --retries=3 \
  CMD curl -f http://localhost:5900 || exit 1

