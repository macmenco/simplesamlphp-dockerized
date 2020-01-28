FROM centos:centos8

LABEL maintainer="Unicon, Inc."

RUN yum update \
    && yum -y install httpd mod_ssl wget \
    && yum -y install php php-ldap php-json php-mbstring php-xml \
    && yum -y clean all

RUN ssp_version=1.18.3; \
    ssp_hash=c6cacf821ae689de6547092c5d0c854e787bfcda716096b1ecf39ad3b3882500; \
    wget -q https://github.com/simplesamlphp/simplesamlphp/releases/download/v$ssp_version/simplesamlphp-$ssp_version.tar.gz \
    && echo "$ssp_hash simplesamlphp-$ssp_version.tar.gz" | sha256sum -c - \
    && cd /var \
    && tar xzf /simplesamlphp-$ssp_version.tar.gz \
    && mv simplesamlphp-$ssp_version simplesamlphp \
    && rm /simplesamlphp-$ssp_version.tar.gz

RUN echo $'\nSetEnv SIMPLESAMLPHP_CONFIG_DIR /var/simplesamlphp/config\nAlias /simplesaml /var/simplesamlphp/www\n \
<Directory /var/simplesamlphp/www>\n \
    Require all granted\n \
</Directory>\n' \
       >> /etc/httpd/conf/httpd.conf

RUN rm /etc/httpd/conf.d/ssl.conf 
COPY ssl.conf.template /etc/httpd/conf.d
COPY httpd-foreground /usr/local/bin/

EXPOSE 80 443

CMD ["httpd-foreground"]
