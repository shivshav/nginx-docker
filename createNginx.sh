#!/bin/bash
set -e
BASEDIR=$(readlink -f $(dirname $0))
HOST_NAME=${1:-127.0.0.1}
GERRIT_NAME=${2:-gerrit}
JENKINS_NAME=${3:-jenkins}
REDMINE_NAME=${4:-redmine}
NEXUS_NAME=${5:-nexus}
DOKUWIKI_NAME=${6:-wiki}
NGINX_IMAGE_NAME=${7:-h3nrik/nginx}
NGINX_NAME=${8:-proxy}
NGINX_MAX_UPLOAD_SIZE=${NGINX_MAX_UPLOAD_SIZE:-200m}

LDAP_NAME=${9:-openldap}
LDAP_DOMAIN=${10:-demo.com}
LDAP_PASSWD=${11:-secret}
PHPLDAPADMIN_NAME=${12:-phpldapadmin}

NEXUS_WEBURL=${13:-}

set -u

LDAP_BASEDN="dc=$(echo ${LDAP_DOMAIN} | sed 's/\./,dc=/g')"
LDAP_BINDDN="cn=admin,${LDAP_BASEDN}"

NGINX_USE_HTTPS=${NGINX_USE_HTTPS:-1}

if [ ${NGINX_USE_HTTPS} -eq 1 ]; then
    if [ ! -e ${BASEDIR}/cert.key ]; then
        openssl req -x509 -nodes -days 365 -newkey rsa:2048 -keyout ${BASEDIR}/cert.key -out ${BASEDIR}/cert.crt
    fi
fi

PROXY_CONF=proxy.conf
NGINX_CONF=nginx.conf
DIRECTORY=directory.html

# Setup proxy URI

${BASEDIR}/proxyconf.sh ${HOST_NAME} ${GERRIT_NAME} ${JENKINS_NAME} ${REDMINE_NAME} ${NEXUS_NAME} ${DOKUWIKI_NAME} ${PHPLDAPADMIN_NAME} ${NGINX_MAX_UPLOAD_SIZE} ${NEXUS_WEBURL} > ${BASEDIR}/${PROXY_CONF}
${BASEDIR}/directory.sh ${HOST_NAME} ${GERRIT_NAME} ${JENKINS_NAME} ${REDMINE_NAME} ${NEXUS_NAME} ${DOKUWIKI_NAME} ${PHPLDAPADMIN_NAME} ${NEXUS_WEBURL} > ${BASEDIR}/${DIRECTORY}

# Setup nginx ldap config
sed "s/{LDAP_NAME}/${LDAP_NAME}/g" ${BASEDIR}/${NGINX_CONF}.template > ${BASEDIR}/${NGINX_CONF}
sed -i "s/{LDAP_BASEDN}/${LDAP_BASEDN}/g" ${BASEDIR}/${NGINX_CONF} 
sed -i "s/{LDAP_BINDDN}/${LDAP_BINDDN}/g" ${BASEDIR}/${NGINX_CONF} 
sed -i "s/{LDAP_PASSWD}/${LDAP_PASSWD}/g" ${BASEDIR}/${NGINX_CONF} 

args=( run \
      --name ${NGINX_NAME} \
      --link ${GERRIT_NAME}:${GERRIT_NAME} \
      --link ${JENKINS_NAME}:${JENKINS_NAME} \
      --link ${REDMINE_NAME}:${REDMINE_NAME} \
      --link ${LDAP_NAME}:${LDAP_NAME} )

if [ ${#PHPLDAPADMIN_NAME} -gt 0 ]; then
    args+=( --link ${PHPLDAPADMIN_NAME}:${PHPLDAPADMIN_NAME} )
fi

if [ ${#NEXUS_WEBURL} -eq 0 ]; then
    args+=( --link ${DOKUWIKI_NAME}:${DOKUWIKI_NAME} \
            --link ${NEXUS_NAME}:${NEXUS_NAME} )
fi

if [ ${NGINX_USE_HTTPS} -eq 1 ]; then
    args+=( -v ${BASEDIR}/cert.crt:/etc/nginx/cert.crt:ro \
            -v ${BASEDIR}/cert.key:/etc/nginx/cert.key:ro \
            -p 443:443 )
fi

args+=( -p 80:80 \
        -v ${BASEDIR}/${PROXY_CONF}:/etc/nginx/conf.d/default.conf:ro \
        -v ${BASEDIR}/${NGINX_CONF}:/etc/nginx/nginx.conf:ro \
        -v ${BASEDIR}/${DIRECTORY}:/usr/share/nginx/html/directory.html:ro \
        -d ${NGINX_IMAGE_NAME} )

docker ${args[@]}

