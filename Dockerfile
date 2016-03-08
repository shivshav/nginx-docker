FROM h3nrik/nginx-ldap

MAINTAINER shiv <shiv@demo.com>

ENV LDAP_SERVER openldap

COPY nginx.conf.template proxy.conf.template start.sh /

RUN mkdir -p /etc/nginx/conf.d

ENTRYPOINT ["/start.sh"]

CMD ["/usr/sbin/nginx","-g","daemon off;"]
