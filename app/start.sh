#!/bin/bash

# Get the hostname from environment variable or use default
HOSTNAME_VALUE=${HOSTNAME:-$(hostname)}
IMAGE_VALUE=${IMAGE:-"nyan-cat"}
TAG_VALUE=${TAG:-"latest"}

# Create tmp directory for modified files
mkdir -p /tmp/nginx/html

# Copy all files to tmp directory
cp -r /usr/share/nginx/html/* /tmp/nginx/html/

# Replace the placeholders in index.html with the actual values
# Escape special characters for sed
HOSTNAME_ESCAPED=$(echo "$HOSTNAME_VALUE" | sed 's/[[\.*^$()+?{|]/\\&/g')
IMAGE_ESCAPED=$(echo "$IMAGE_VALUE" | sed 's/[[\.*^$()+?{|\/]/\\&/g')
TAG_ESCAPED=$(echo "$TAG_VALUE" | sed 's/[[\.*^$()+?{|]/\\&/g')

sed -e "s|\${HOSTNAME}|$HOSTNAME_ESCAPED|g" \
    -e "s|\${IMAGE}|$IMAGE_ESCAPED|g" \
    -e "s|\${TAG}|$TAG_ESCAPED|g" \
    /usr/share/nginx/html/index.html > /tmp/nginx/html/index.html

# Create nginx config to serve from tmp
cat > /tmp/nginx.conf << 'EOF'
worker_processes auto;
error_log /var/log/nginx/error.log warn;
pid /tmp/nginx.pid;

events {
    worker_connections 1024;
}

http {
    include /etc/nginx/mime.types;
    default_type application/octet-stream;
    
    access_log /var/log/nginx/access.log;
    
    sendfile on;
    tcp_nopush on;
    tcp_nodelay on;
    keepalive_timeout 65;
    types_hash_max_size 2048;
    
    server {
        listen 8080;
        server_name localhost;
        
        root /tmp/nginx/html;
        index index.html;
        
        location / {
            try_files $uri $uri/ =404;
        }
        
        # Cache static assets
        location ~* \.(css|js|png|jpg|jpeg|gif|ico|svg|woff|woff2|ttf|eot)$ {
            expires 1y;
            add_header Cache-Control "public, immutable";
        }
    }
}
EOF

# Start nginx with custom config
exec nginx -c /tmp/nginx.conf -g 'daemon off;'
