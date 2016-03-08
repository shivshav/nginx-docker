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
