#!/bin/bash

export LDAP_BASEDN="dc=$(echo ${OPENLDAP_ENV_SLAPD_DOMAIN} | sed 's/\./,dc=/g')"
#LDAP_BINDDN="cn=admin,${LDAP_BASEDN}"
#LDAP_PASSWD="

#TODO: Allow user to set CMD so that arbitrary args or commands can be used instead of this as default
exec /usr/local/bin/dockerize \
    -template /nginx.conf.template:/etc/nginx/nginx.conf \
    -template /proxy.conf.template:/etc/nginx/conf.d/default.conf \
    -stdout /var/log/nginx/access.log \
    -stderr /var/log/nginx/error.log \
    "$@"
#    /usr/sbin/nginx -g daemon off
