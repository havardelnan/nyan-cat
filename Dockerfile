FROM nginxinc/nginx-unprivileged:latest

LABEL maintainer="Dave (Daviey) Walker <email@daviey.com>"

# Build arguments for image and tag
ARG IMAGE_NAME=nyan-cat
ARG IMAGE_TAG=latest

# Set environment variables from build args
ENV IMAGE=${IMAGE_NAME}
ENV TAG=${IMAGE_TAG}

# Switch to root to copy files and set permissions
COPY . /usr/share/nginx/html
COPY --chown=nginx:nginx start.sh /start.sh
RUN chmod +x /start.sh && ls -la /start.sh

# Switch back to nginx user

ENTRYPOINT ["/start.sh"]

