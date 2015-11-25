#!/bin/bash
set -e
BASEDIR=$(readlink -f $(dirname $0))
HOST_NAME=${1:-127.0.0.1}
GERRIT_NAME=${2:-gerrit}
JENKINS_NAME=${3:-jenkins}
REDMINE_NAME=${4:-redmine}
NEXUS_NAME=${5:-nexus}
NGINX_IMAGE_NAME=${6:-h3nrik/nginx}
NGINX_NAME=${7:-proxy}
NGINX_MAX_UPLOAD_SIZE=${NGINX_MAX_UPLOAD_SIZE:-200m}

LDAP_NAME=${8:-openldap}
LDAP_DOMAIN=${9:-demo.com}
LDAP_PASSWD=${10:-secret}
PHPLDAPADMIN_NAME=${11:-phpldapadmin}

LDAP_BASEDN="dc=$(echo ${LDAP_DOMAIN} | sed 's/\./,dc=/g')"
LDAP_BINDDN="cn=admin,${LDAP_BASEDN}"

PROXY_CONF=proxy.conf
NGINX_CONF=nginx.conf

# Setup proxy URI
if [ ${#NEXUS_WEBURL} -eq 0 ]; then
    sed "s/{{HOST_URL}}/${HOST_NAME}/g" ${BASEDIR}/${PROXY_CONF}.nexus.template > ${BASEDIR}/${PROXY_CONF}
else
    sed "s/{{HOST_URL}}/${HOST_NAME}/g" ${BASEDIR}/${PROXY_CONF}.template > ${BASEDIR}/${PROXY_CONF}
fi
sed -i "s/{GERRIT_URI}/${GERRIT_NAME}/g" ${BASEDIR}/${PROXY_CONF}
sed -i "s/{JENKINS_URI}/${JENKINS_NAME}/g" ${BASEDIR}/${PROXY_CONF}
sed -i "s/{REDMINE_URI}/${REDMINE_NAME}/g" ${BASEDIR}/${PROXY_CONF}
sed -i "s/{NEXUS_URI}/${NEXUS_NAME}/g" ${BASEDIR}/${PROXY_CONF}
sed -i "s/{PHPLDAPADMIN_URI}/${PHPLDAPADMIN_NAME}/g" ${BASEDIR}/${PROXY_CONF}
sed -i "s/{{NGINX_MAX_UPLOAD_SIZE}}/${NGINX_MAX_UPLOAD_SIZE}/g" ${BASEDIR}/${PROXY_CONF}

# Setup nginx ldap config
sed "s/{LDAP_NAME}/${LDAP_NAME}/g" ${BASEDIR}/${NGINX_CONF}.template > ${BASEDIR}/${NGINX_CONF}
sed -i "s/{LDAP_BASEDN}/${LDAP_BASEDN}/g" ${BASEDIR}/${NGINX_CONF} 
sed -i "s/{LDAP_BINDDN}/${LDAP_BINDDN}/g" ${BASEDIR}/${NGINX_CONF} 
sed -i "s/{LDAP_PASSWD}/${LDAP_PASSWD}/g" ${BASEDIR}/${NGINX_CONF} 


# Start proxy
if [ ${#NEXUS_WEBURL} -eq 0 ]; then #proxy nexus
    docker run \
    --name ${NGINX_NAME} \
    --link ${GERRIT_NAME}:${GERRIT_NAME} \
    --link ${JENKINS_NAME}:${JENKINS_NAME} \
    --link ${REDMINE_NAME}:${REDMINE_NAME} \
    --link ${NEXUS_NAME}:${NEXUS_NAME} \
    --link ${PHPLDAPADMIN_NAME}:${PHPLDAPADMIN_NAME} \
    --link ${LDAP_NAME}:${LDAP_NAME} \
    -p 80:80 \
    -v ${BASEDIR}/${NGINX_CONF}:/etc/nginx/nginx.conf:ro \
    -v ${BASEDIR}/${PROXY_CONF}:/etc/nginx/conf.d/default.conf:ro \
    -d ${NGINX_IMAGE_NAME}
else #without nexus
    docker run \
    --name ${NGINX_NAME} \
    --link ${GERRIT_NAME}:${GERRIT_NAME} \
    --link ${JENKINS_NAME}:${JENKINS_NAME} \
    --link ${REDMINE_NAME}:${REDMINE_NAME} \
    --link ${PHPLDAPADMIN_NAME}:${PHPLDAPADMIN_NAME} \
    --link ${LDAP_NAME}:${LDAP_NAME} \
    -p 80:80 \
    -v ${BASEDIR}/${NGINX_CONF}:/etc/nginx/nginx.conf:ro \
    -v ${BASEDIR}/${PROXY_CONF}:/etc/nginx/conf.d/default.conf:ro \
    -d ${NGINX_IMAGE_NAME}
fi
