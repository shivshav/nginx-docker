#!/bin/bash
NGINX_NAME=${NGINX_NAME:-proxy}

echo "Removing ${NGINX_NAME}..."
docker stop ${NGINX_NAME} &> /dev/null
docker rm -v ${NGINX_NAME} &> /dev/null
