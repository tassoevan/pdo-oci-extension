FROM ubuntu:12.04
MAINTAINER Tasso Evangelista <tasso@tassoevan.me>

ENV DEBIAN_FRONTEND noninteractive

# Install the Oracle Client

RUN apt-get update && \
    apt-get install -y \
        locales \
        unzip

RUN dpkg-reconfigure locales && \
    locale-gen en_US.UTF-8 && \
    /usr/sbin/update-locale LANG=en_US.UTF-8
ENV LC_ALL en_US.UTF-8

RUN mkdir -p /opt/oracle/instantclient
ADD instantclient/linux-amd64/basic.zip /opt/oracle/instantclient/basic.zip
ADD instantclient/linux-amd64/sdk.zip /opt/oracle/instantclient/sdk.zip
RUN cd /opt/oracle/instantclient && \
    unzip basic.zip && \
    unzip sdk.zip && \
    rm basic.zip sdk.zip && \
    mv instantclient*/* ./ && \
    rmdir instantclient*/ && \
    ln -s libclntsh.so.* libclntsh.so && \
    ln -s libocci.so.* libocci.so && \
    echo /opt/oracle/instantclient >> /etc/ld.so.conf && \
    ldconfig && \
    mkdir -p network/admin

# Install the OCI8 PHP Extension

RUN apt-get update && \
    apt-get install -y \
        php5 \
        php5-cli \
        php5-dev \
        php-db \
        php-pear \
        build-essential \
        libaio1 \
        re2c

RUN echo 'instantclient,/opt/oracle/instantclient' | pecl install oci8-1.4.10

RUN echo "extension=oci8.so" > /etc/php5/mods-available/oci8.ini && \
    php5enmod oci8

# Install the PDO/OCI PHP Extension

RUN cd /usr/include/ && \
    ln -s php5 php && \
    cd /opt/oracle/instantclient && \
    mkdir -p include/oracle/11.1/ && \
    cd include/oracle/11.1/ && \
    ln -s ../../../sdk/include client && \
    cd - && \
    mkdir -p lib/oracle/11.1/client && \
    cd lib/oracle/11.1/client && \
    ln -s ../../../../ lib

RUN pecl channel-update pear.php.net && \
    mkdir -p /tmp/pear/download/ && \
    cd /tmp/pear/download/ && \
    pecl download pdo_oci-1.0 && \
    tar -xvf PDO_OCI-1.0.tgz

ADD config.m4.patch /tmp/pear/download/PDO_OCI-1.0/

RUN php5enmod pdo

RUN cd /tmp/pear/download/PDO_OCI-1.0 && \
    patch --dry-run -i config.m4.patch && \
    patch -i config.m4.patch && \
    phpize && \
    sed -i s/function_entry/zend_function_entry/ pdo_oci.c && \
    ORACLE_HOME=/opt/oracle/instantclient ./configure --with-pdo-oci=instantclient,/opt/oracle/instantclient,11.1 && \
    make && \
    make test && \
    make install && \
    ls -la /usr/lib/php5/build && \
    mv modules/pdo_oci.so /usr/lib/php5/20*/ && \
    echo "extension=pdo_oci.so" > /etc/php5/mods-available/pdo_oci.ini && \
    php5enmod pdo_oci
