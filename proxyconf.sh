#! /bin/bash

set -e
BASEDIR=$(readlink -f $(dirname $0))
HOST_NAME=${1:-127.0.0.1}
GERRIT_NAME=${2:-gerrit}
JENKINS_NAME=${3:-jenkins}
REDMINE_NAME=${4:-redmine}
NEXUS_NAME=${5:-nexus}
DOKUWIKI_NAME=${6:-wiki}
PHPLDAPADMIN_NAME=${7:-phpldapadmin}
NGINX_MAX_UPLOAD_SIZE=${8:-200m}
NEXUS_WEBURL=${9:-}


set -u

if [ -e ${BASEDIR}/cert.key ]; then

  cat << EOF
  server {
    listen 80;
    return 301 https://\$host\$request_uri;
}

server {

    listen 443;
    server_name ${HOST_NAME};

    ssl_certificate           /etc/nginx/cert.crt;
    ssl_certificate_key       /etc/nginx/cert.key;

    ssl on;
    ssl_session_cache  builtin:1000  shared:SSL:10m;
    ssl_protocols  TLSv1 TLSv1.1 TLSv1.2;
    ssl_ciphers HIGH:!aNULL:!eNULL:!EXPORT:!CAMELLIA:!DES:!MD5:!PSK:!RC4;
    ssl_prefer_server_ciphers on;
EOF

else

  cat << EOF
server {
    listen       80;
    server_name  ${HOST_NAME};
EOF

fi

cat << EOF
    client_max_body_size ${NGINX_MAX_UPLOAD_SIZE};

    location / {
        root   /usr/share/nginx/html;
        index  directory.html;
    }

    location /${GERRIT_NAME}/ {
        proxy_pass    http://${GERRIT_NAME}:8080;
        proxy_set_header    X-Forwarded-For \$remote_addr;
        proxy_set_header    Host \$host;
        proxy_set_header    X-Remote-User \$remote_user;
    }

    location /${JENKINS_NAME} {
        proxy_pass    http://${JENKINS_NAME}:8080;
        proxy_redirect      default;
        proxy_set_header    X-Forwarded-For \$proxy_add_x_forwarded_for;
        proxy_set_header    X-Real-IP \$remote_addr;
        proxy_set_header    Host \$host;
    }

    location /${REDMINE_NAME} {
        proxy_pass    http://${REDMINE_NAME};
        proxy_set_header    X-Forwarded-For \$proxy_add_x_forwarded_for;
        proxy_set_header    X-Real-IP \$remote_addr;
        proxy_set_header    Host \$host;
    }
EOF

if [ ${#PHPLDAPADMIN_NAME} -gt 0 ]; then
  cat << EOF
    location /${PHPLDAPADMIN_NAME} {
        proxy_pass    http://${PHPLDAPADMIN_NAME};
        proxy_set_header    X-Forwarded-For \$proxy_add_x_forwarded_for;
        proxy_set_header    X-Real-IP \$remote_addr;
        proxy_set_header    Host \$host;
    }

EOF
fi



if [ ${#NEXUS_WEBURL} -eq 0 ]; then
  cat << EOF
    location /${DOKUWIKI_NAME} {
        rewrite             /${DOKUWIKI_NAME}/(.*) /\$1 break;
        proxy_pass          http://${DOKUWIKI_NAME}/;
        proxy_set_header    X-Forwarded-For \$proxy_add_x_forwarded_for;
        proxy_set_header    X-Real-IP \$remote_addr;
        proxy_set_header    Host \$host; 
    }

    location /${NEXUS_NAME} {
        proxy_pass    http://${NEXUS_NAME}:8081;
        proxy_set_header    X-Forwarded-For \$proxy_add_x_forwarded_for;
        proxy_set_header    X-Real-IP \$remote_addr;
        proxy_set_header    Host \$host;
        proxy_send_timeout 300;
        proxy_read_timeout 300;
        keepalive_timeout  300;
        send_timeout       300;
    }
EOF
fi

cat << EOF
    error_page  404              /directory.html;
    location = /directory.html {
        root   /usr/share/nginx/html;
    }

    # redirect server error pages to the static page /50x.html
    #
    error_page   500 502 503 504  /50x.html;
    location = /50x.html {
        root   /usr/share/nginx/html;
    }
}
EOF

