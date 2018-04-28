ARG ubuntu_version
FROM ubuntu:${ubuntu_version}

ARG php_packages
ARG oci8_pecl_version
ARG oci8_ini_path
ARG oci8_enmod_cmd

LABEL maintainer="Tasso Evangelista <tasso@tassoevan.me>"

# Install build dependencies
ENV DEBIAN_FRONTEND noninteractive

RUN apt-get update && \
    apt-get install -y unzip build-essential libaio1 re2c ${php_packages} && \
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
RUN echo 'instantclient,/opt/oracle/instantclient/lib' | pecl install ${oci8_pecl_version}
RUN echo "extension=oci8.so" > ${oci8_ini_path}
RUN ${oci8_enmod_cmd}
ADD oci8-test.php /tmp/oci8-test.php
RUN php /tmp/oci8-test.php
