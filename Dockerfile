FROM centos:centos7

MAINTAINER Unicon, Inc.

RUN yum -y install epel-release \
    && yum -y update \
    && yum -y install httpd mod_ssl php php-mcrypt php-pear php-xml php-pdo wget \
    && yum -y clean all

RUN ssp_version=1.14.0; \
    ssp_hash=6243f7f9521e876504631bd7a3629c19d0acd9203b467801de2af548f43d072d; \   
    wget https://simplesamlphp.org/res/downloads/simplesamlphp-$ssp_version.tar.gz \
    && echo "$ssp_hash  simplesamlphp-$ssp_version.tar.gz" | sha256sum -c - \
	&& cd /var \
	&& tar xzf /simplesamlphp-$ssp_version.tar.gz \
    && mv simplesamlphp-$ssp_version simplesamlphp \
    && rm /simplesamlphp-$ssp_version.tar.gz

RUN echo $'\nSetEnv SIMPLESAMLPHP_CONFIG_DIR /var/simplesamlphp/config\nAlias /simplesaml /var/simplesamlphp/www\n \
<Directory /var/simplesamlphp/www>\n \
    Require all granted\n \
</Directory>\n' \
       >> /etc/httpd/conf/httpd.conf

COPY httpd-foreground /usr/local/bin/

EXPOSE 80 443

CMD ["httpd-foreground"]