FROM ubuntu:precise
MAINTAINER Tasso Evangelista <tasso@tassoevan.me>

# Install build dependencies
ENV DEBIAN_FRONTEND noninteractive

RUN apt-get update && \
    apt-get install -y wget unzip php5 php5-cli php5-dev php-db php-pear build-essential libaio1 re2c && \
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
RUN echo 'instantclient,/opt/oracle/instantclient/lib' | pecl install oci8-1.4.10
ADD oci8.ini /etc/php5/conf.d/oci8.ini
ADD oci8-test.php /tmp/oci8-test.php
RUN php /tmp/oci8-test.php

# Build PHP PDO-OCI extension
RUN pecl channel-update pear.php.net && \
    cd /tmp && \
    pecl download pdo_oci && \
    tar xvf /tmp/PDO_OCI-1.0.tgz -C /tmp && \
    sed 's/function_entry/zend_function_entry/' -i /tmp/PDO_OCI-1.0/pdo_oci.c && \
    sed 's/10.1/12.1/' -i /tmp/PDO_OCI-1.0/config.m4 && \
    cd /tmp/PDO_OCI-1.0 && \
    phpize && \
    ./configure --with-pdo-oci=/opt/oracle/instantclient && \
    make install
ADD pdo_oci.ini /etc/php5/conf.d/pdo_oci.ini
ADD pdo_oci-test.php /tmp/pdo_oci-test.php
RUN php /tmp/pdo_oci-test.php

# Connect to test database
ADD connection-test.php /tmp/connection-test.php
CMD php /tmp/connection-test.php

# Add command to get compiled extensions
ADD get-extension /bin/get-extension
