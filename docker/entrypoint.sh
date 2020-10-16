#!/bin/sh

set -ex

cat > /etc/nginx/sites-enabled/default <<CONF
server {
    listen       80;
    server_name  _;
    absolute_redirect off;
    location / {
        root   /usr/share/nginx/html;
        index  index.html index.htm;
        gzip on;
        gzip_comp_level 6;
        gzip_min_length 1100;
        gzip_buffers 16 8k;
        gzip_proxied any;
        gzip_types
            text/plain
            text/css
            text/js
            text/xml
            text/javascript
            application/javascript
            application/json
            application/xml
            application/rss+xml
            image/svg+xml;
    }

    error_page   500 502 503 504  /50x.html;
    location = /50x.html {
        root   /usr/share/nginx/html;
    }
}
CONF
egrep -lr 'http://mywebsite.com' /usr/share/nginx/html | xargs -I {} sed -i "s|http://mywebsite.com|$SITE_URL|g" {}
exec nginx -g 'daemon off;'
