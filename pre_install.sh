#!/bin/bash

mkdir -p nextcloud/config nextcloud/custom_apps nextcloud/data nextcloud/themes
mkdir -p nginx/certs nginx/vhost.d nginx/html nginx/conf.d nginx/acme.sh

mkdir collabora
mkdir mysql



sudo tee ./nextcloud/.user.ini<<EOF
upload_max_filesize=512M
post_max_size=512M
memory_limit=512M
mbstring.func_overload=0
always_populate_raw_post_data=-1
default_charset='UTF-8'
output_buffering=0
EOF


sudo tee ./nextcloud/.htaccess<<EOF
<IfModule mod_headers.c>
  <IfModule mod_setenvif.c>
    <IfModule mod_fcgid.c>
      SetEnvIfNoCase ^Authorization$ "(.+)" XAUTHORIZATION=$1
      RequestHeader set XAuthorization %{XAUTHORIZATION}e env=XAUTHORIZATION
    </IfModule>
    <IfModule mod_proxy_fcgi.c>
      SetEnvIfNoCase Authorization "(.+)" HTTP_AUTHORIZATION=$1
    </IfModule>
  </IfModule>
  <IfModule mod_env.c>
    # Add security and privacy related headers
    Header always set Referrer-Policy "no-referrer"
    Header always set X-Content-Type-Options "nosniff"
    Header always set X-Download-Options "noopen"
    Header always set X-Frame-Options "SAMEORIGIN"
    Header always set X-Permitted-Cross-Domain-Policies "none"
    Header always set X-Robots-Tag "none"
    Header always set X-XSS-Protection "1; mode=block"
    SetEnv modHeadersAvailable true
  </IfModule>
  <IfModule mod_dir.c>
    DirectoryIndex index.php index.html
  </IfModule>
  # Let browsers cache CSS, JS files for half a year
  <FilesMatch "\.(css|js|woff2?|svg|gif)$">
    Header set Cache-Control "max-age=15778463"
  </FilesMatch>
</IfModule>

ErrorDocument 403 /core/templates/403.php
ErrorDocument 404 /core/templates/404.php


<IfModule mod_rewrite.c>
  RewriteEngine on
  RewriteCond %{REQUEST_URI} !^/.well-known/(acme-challenge|pki-validation)/.*
  RewriteRule .* - [env=HTTP_AUTHORIZATION:%{HTTP:Authorization}]
  RewriteRule ^\.well-known/host-meta /public.php?service=host-meta [QSA,L]
  RewriteRule ^\.well-known/host-meta\.json /public.php?service=host-meta-json [QSA,L]
  RewriteRule ^\.well-known/webfinger /public.php?service=webfinger [QSA,L]
  RewriteRule ^\.well-known/nodeinfo /public.php?service=nodeinfo [QSA,L]

  RewriteRule ^remote/(.*) remote.php [QSA,L]
  RewriteRule ^(build|tests|config|lib|3rdparty|templates)/.* - [R=404,L]
  RewriteRule ^core/signature.json - [R=404,L]
  RewriteRule ^data/(\.*) - [R=404,L]
  RewriteCond %{REQUEST_URI} !^/\.well-known/(acme-challenge|pki-validation)/.*
  RewriteRule ^(\.|autotest|occ|issue|indie|db_|console) - [R=404,L]
</IfModule>

<IfModule mod_mime.c>
  AddType image/svg+xml svg svgz
  AddEncoding gzip svgz
</IfModule>
EOF

