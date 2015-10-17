#!/bin/bash
set -e
BASEDIR=$(readlink -f $(dirname $0))
HOST_NAME=${1:-127.0.0.1}
GERRIT_NAME=${2:-gerrit}
JENKINS_NAME=${3:-jenkins}
REDMINE_NAME=${4:-redmine}
NEXUS_NAME=${5:-nexus}

NGINX_IMAGE_NAME=${6:-nginx}
NGINX_NAME=${7:-proxy}
NGINX_MAX_UPLOAD_SIZE=${NGINX_MAX_UPLOAD_SIZE:-200m}

PROXY_CONF=proxy.conf

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
sed -i "s/{{NGINX_MAX_UPLOAD_SIZE}}/${NGINX_MAX_UPLOAD_SIZE}/g" ${BASEDIR}/${PROXY_CONF}

# Start proxy
if [ ${#NEXUS_WEBURL} -eq 0 ]; then #proxy nexus
    docker run \
    --name ${NGINX_NAME} \
    --link ${GERRIT_NAME}:${GERRIT_NAME} \
    --link ${JENKINS_NAME}:${JENKINS_NAME} \
    --link ${REDMINE_NAME}:${REDMINE_NAME} \
    --link ${NEXUS_NAME}:${NEXUS_NAME} \
    -p 80:80 \
    -v ${BASEDIR}/${PROXY_CONF}:/etc/nginx/conf.d/default.conf:ro \
    -d ${NGINX_IMAGE_NAME}
else #without nexus
    docker run \
    --name ${NGINX_NAME} \
    --link ${GERRIT_NAME}:${GERRIT_NAME} \
    --link ${JENKINS_NAME}:${JENKINS_NAME} \
    --link ${REDMINE_NAME}:${REDMINE_NAME} \
    -p 80:80 \
    -v ${BASEDIR}/${PROXY_CONF}:/etc/nginx/conf.d/default.conf:ro \
    -d ${NGINX_IMAGE_NAME}
fi
