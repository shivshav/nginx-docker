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
NEXUS_WEBURL=${8:-}


set -u

cat << EOF
<!DOCTYPE html>
<html>
<head>
<title>Welcome to Continuous Integration Development Central!</title>
<style>
    body {
        width: 35em;
        margin: 0 auto;
        font-family: Tahoma, Verdana, Arial, sans-serif;
    }
</style>
</head>
<body>
The following services can be reached from this server:
<ul>
<li><a href="/${GERRIT_NAME}">Gerrit Code Review</a></li>
<li><a href="/${REDMINE_NAME}">Redmine Issues List</a></li>
<li><a href="/${JENKINS_NAME}">Jenkins CI</a></li>
EOF

if [ ${#PHPLDAPADMIN_NAME} -gt 0 ]; then
  cat << EOF
<li><a href="/${PHPLDAPADMIN_NAME}">Open LDAP Configuration</a></li>
EOF
fi


if [ ${#NEXUS_WEBURL} -eq 0 ]; then
  cat << EOF
<li><a href="/${DOKUWIKI_NAME}">Dokuwiki</a></li>
<li><a href="/${NEXUS_NAME}">Nexus Repository</a></li>
EOF
else
  cat << EOF
<li><a href="/${NEXUS_WEBURL}">Nexus Repository</a></li>
EOF
fi

cat << EOF
</ul>
</body>      
</html>
EOF
