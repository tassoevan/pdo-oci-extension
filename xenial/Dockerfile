FROM ubuntu:xenial
MAINTAINER Tasso Evangelista <tasso@tassoevan.me>

# Install build dependencies
ENV DEBIAN_FRONTEND noninteractive

RUN apt-get update && \
    apt-get install -y unzip php7.0 php7.0-cli php7.0-dev build-essential libaio1 re2c && \
    ln -s /usr/include/php5 /usr/include/php

# Install Oracle Instant Client Basic and SDK
ADD instantclient/instantclient-basic-linux.x64-12.1.0.2.0.zip /tmp/basic.zip
ADD instantclient/instantclient-sdk-linux.x64-12.1.0.2.0.zip /tmp/sdk.zip

RUN mkdir -p /opt/oracle/instantclient && \
    unzip -q /tmp/basic.zip -d /opt/oracle && \
    mv /opt/oracle/instantclient_12_1 /opt/oracle/instantclient/lib && \
    unzip -q /tmp/sdk.zip -d /opt/oracle && \
    mv /opt/oracle/instantclient_12_1/sdk/include /opt/oracle/instantclient/include && \
    ln -s /opt/oracle/instantclient/lib/libclntsh.so.12.1 /opt/oracle/instantclient/lib/libclntsh.so && \
    ln -s /opt/oracle/instantclient/lib/libocci.so.12.1 /opt/oracle/instantclient/lib/libocci.so && \
    echo /opt/oracle/instantclient/lib >> /etc/ld.so.conf && \
    ldconfig

# Install PHP OCI8 extension
RUN echo 'instantclient,/opt/oracle/instantclient/lib' | pecl install oci8-2.1.2
ADD oci8.ini /etc/php/7.0/mods-available/oci8.ini
RUN phpenmod oci8
ADD oci8-test.php /tmp/oci8-test.php
RUN php /tmp/oci8-test.php

# Build PHP PDO-OCI extension
ADD https://github.com/php/php-src/archive/php-7.0.11.zip /tmp/php-7.0.11.zip
RUN unzip /tmp/php-7.0.11.zip -d /tmp && \
    cd /tmp/php-src-php-7.0.11/ext/pdo_oci && \
    phpize && \
    ./configure --with-pdo-oci=/opt/oracle/instantclient && \
    make install
ADD pdo_oci.ini /etc/php/7.0/mods-available/pdo_oci.ini
RUN phpenmod pdo_oci
ADD pdo_oci-test.php /tmp/pdo_oci-test.php
RUN php /tmp/pdo_oci-test.php

# Connect to test database
ADD connection-test.php /tmp/connection-test.php
CMD php /tmp/connection-test.php

# Add command to get compiled extensions
ADD get-extension /bin/get-extension
