#!/bin/sh

set -ex

cat > /etc/nginx/conf.d/default.conf <<CONF
server {
    listen       80;
    server_name  _;
    absolute_redirect off;
    location / {
        root   /usr/share/nginx/html;
        index  index.html index.htm;
    }
    error_page   500 502 503 504  /50x.html;
    location = /50x.html {
        root   /usr/share/nginx/html;
    }
}
CONF
egrep -lr 'http://mywebsite.com' /usr/share/nginx/html | xargs -I {} sed -i "s|http://mywebsite.com|$SITE_URL|g" {}
exec nginx -g 'daemon off;'
