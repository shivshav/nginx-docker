#!/bin/bash
set -e
BASEDIR=$(readlink -f $(dirname $0))
HOST_NAME=${1:-127.0.0.1}
GERRIT_NAME=${2:-gerrit}
JENKINS_NAME=${3:-jenkins}
REDMINE_NAME=${4:-redmine}
NEXUS_NAME=${5:-nexus}
DOKUWIKI_NAME=${6:-wiki}
NGINX_IMAGE_NAME=${7:-ci/nginx}
NGINX_NAME=${8:-proxy}
NGINX_MAX_UPLOAD_SIZE=${NGINX_MAX_UPLOAD_SIZE:-200m}

LDAP_NAME=${9:-openldap}
LDAP_DOMAIN=${10:-demo.com}
LDAP_PASSWD=${11:-secret}
PHPLDAPADMIN_NAME=${12:-phpldapadmin}

#LDAP_BASEDN="dc=$(echo ${LDAP_DOMAIN} | sed 's/\./,dc=/g')"
#LDAP_BINDDN="cn=admin,${LDAP_BASEDN}"
#
#PROXY_CONF=proxy.conf
#NGINX_CONF=nginx.conf
#
## Setup proxy URI
#if [ ${#NEXUS_WEBURL} -eq 0 ]; then
#    sed "s/{{HOST_URL}}/${HOST_NAME}/g" ${BASEDIR}/${PROXY_CONF}.nexus.template > ${BASEDIR}/${PROXY_CONF}
#else
#    sed "s/{{HOST_URL}}/${HOST_NAME}/g" ${BASEDIR}/${PROXY_CONF}.template > ${BASEDIR}/${PROXY_CONF}
#fi
#sed -i "s/{GERRIT_URI}/${GERRIT_NAME}/g" ${BASEDIR}/${PROXY_CONF}
#sed -i "s/{JENKINS_URI}/${JENKINS_NAME}/g" ${BASEDIR}/${PROXY_CONF}
#sed -i "s/{REDMINE_URI}/${REDMINE_NAME}/g" ${BASEDIR}/${PROXY_CONF}
#sed -i "s/{NEXUS_URI}/${NEXUS_NAME}/g" ${BASEDIR}/${PROXY_CONF}
#sed -i "s/{DOKUWIKI_URI}/${DOKUWIKI_NAME}/g" ${BASEDIR}/${PROXY_CONF}
#sed -i "s/{{NGINX_MAX_UPLOAD_SIZE}}/${NGINX_MAX_UPLOAD_SIZE}/g" ${BASEDIR}/${PROXY_CONF}
#
## Setup nginx ldap config
#sed "s/{LDAP_NAME}/${LDAP_NAME}/g" ${BASEDIR}/${NGINX_CONF}.template > ${BASEDIR}/${NGINX_CONF}
#sed -i "s/{LDAP_BASEDN}/${LDAP_BASEDN}/g" ${BASEDIR}/${NGINX_CONF} 
#sed -i "s/{LDAP_BINDDN}/${LDAP_BINDDN}/g" ${BASEDIR}/${NGINX_CONF} 
#sed -i "s/{LDAP_PASSWD}/${LDAP_PASSWD}/g" ${BASEDIR}/${NGINX_CONF} 
#sed -i "s/{PHPLDAPADMIN_URI}/${PHPLDAPADMIN_NAME}/g" ${BASEDIR}/${PROXY_CONF}

# Start proxy
docker run \
    --name ${NGINX_NAME} \
    --link ${GERRIT_NAME}:gerrit \
    --link ${JENKINS_NAME}:jenkins \
    --link ${REDMINE_NAME}:redmine \
    --link ${DOKUWIKI_NAME}:dokuwiki \
    --link ${NEXUS_NAME}:nexus \
    --link ${PHPLDAPADMIN_NAME}:phpldapadmin \
    --link ${LDAP_NAME}:openldap \
    -p 80:80 \
    -e NGINX_MAX_UPLOAD_SIZE=200m \
    -d ${NGINX_IMAGE_NAME}
