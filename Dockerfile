# Use an official lightweight base image
FROM amd64/ubuntu

# Set environment variables
ENV DEBIAN_FRONTEND=noninteractive
ENV ENV_CHROME=/usr/bin/google-chrome

RUN set -xe \
    && apt-get update \
    && apt-get install -y --no-install-recommends ca-certificates curl socat \
    && apt-get install -y --no-install-recommends xvfb x11vnc fluxbox xterm \
    && apt-get install -y --no-install-recommends sudo \
    && apt-get install -y --no-install-recommends supervisor \
    && apt-get install -y gnupg2 \
    && rm -rf /var/lib/apt/lists/*

RUN set -xe \
    && curl -fsSL https://dl-ssl.google.com/linux/linux_signing_key.pub | apt-key add - \
    && echo "deb [arch=amd64] http://dl.google.com/linux/chrome/deb/ stable main" > /etc/apt/sources.list.d/google-chrome.list \
    && apt-get update \
    && apt-get install -f -y google-chrome-stable \
    && rm -rf /var/lib/apt/lists/*

# Add a normal user with passwordless sudo
RUN groupadd -g 1001 usergroup \
&& useradd -u 1001 -g usergroup -G sudo --shell /bin/bash --no-create-home --home-dir /tmp user \
&& echo 'ALL ALL = (ALL:ALL) NOPASSWD: ALL' >> /etc/sudoers

# Set up X11VNC password
RUN mkdir -p /tmp/.vnc && \
x11vnc -storepasswd 1234567 /tmp/.vnc/passwd && \
chown -R user:usergroup /tmp/.vnc

# Ensure proper permissions for chrome-data
RUN mkdir -p /tmp/chrome-data && \
chown -R user:usergroup /tmp/chrome-data

# Ensure necessary permissions for logs and supervisor configuration
RUN mkdir -p /var/log/supervisor && \
    chown -R user:usergroup /var/log/supervisor && \
    chown -R user:usergroup /etc/supervisor

# Copy supervisord configuration file
COPY supervisord.conf /etc/supervisor/conf.d/supervisord.conf

# Switch to the normal user
USER user
WORKDIR /tmp
VOLUME /tmp/chrome-data

# Expose VNC port
EXPOSE 5900

# Set the entry point
CMD ["supervisord", "-c", "/etc/supervisor/conf.d/supervisord.conf"]
