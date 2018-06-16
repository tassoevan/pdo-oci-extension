ARG ubuntu_version
FROM ubuntu:${ubuntu_version}

ARG ubuntu_version
ARG php_version
ARG php_packages
ARG php_ext_conf_dir
ARG oci8_version

LABEL maintainer="Tasso Evangelista <tasso@tassoevan.me>"

VOLUME /host
ENV DEBIAN_FRONTEND noninteractive

# Install build dependencies
RUN apt-get update && \
    apt-get install -y unzip build-essential libaio1 re2c wget ca-certificates

# Install PHP and PHP development packages
RUN apt-get update && \
    apt-get install -y ${php_packages}
RUN php -r 'exit(substr(PHP_VERSION, 0, strlen(getenv("php_version"))) === getenv("php_version") ? 0 : 1);'

# Install Oracle Instant Client Basic and SDK
RUN mkdir -p /opt/oracle/instantclient
ADD instantclient/instantclient-basic-linux.x64-12.2.0.1.0.zip /tmp/basic.zip
RUN unzip -q /tmp/basic.zip -d /opt/oracle
RUN mv /opt/oracle/instantclient_12_2 /opt/oracle/instantclient/lib
ADD instantclient/instantclient-sdk-linux.x64-12.2.0.1.0.zip /tmp/sdk.zip
RUN unzip -q /tmp/sdk.zip -d /opt/oracle
RUN mv /opt/oracle/instantclient_12_2/sdk/include /opt/oracle/instantclient/include
RUN ln -s /opt/oracle/instantclient/lib/libclntsh.so.12.1 /opt/oracle/instantclient/lib/libclntsh.so
RUN ln -s /opt/oracle/instantclient/lib/libocci.so.12.1 /opt/oracle/instantclient/lib/libocci.so
RUN echo /opt/oracle/instantclient/lib >> /etc/ld.so.conf
RUN ldconfig

# Build and install PHP OCI8 extension
RUN echo 'instantclient,/opt/oracle/instantclient/lib' | pecl install oci8-${oci8_version}
RUN echo 'extension=oci8.so' > ${php_ext_conf_dir}/oci8.ini
RUN if [ "${ubuntu_version}" = 'trusty' ]; \
    then ln -s ../../mods-available/oci8.ini /etc/php5/cli/conf.d/20-oci8.ini; \
    elif [ "${ubuntu_version}" = 'xenial' ] || [ "${ubuntu_version}" = 'bionic' ]; \
    then phpenmod oci8; \
    fi
RUN php -r 'exit(function_exists("oci_connect") ? 0 : 1);'

# Build and install PHP PDO-OCI extension
RUN wget -O /tmp/php-${php_version}.zip \
        https://github.com/php/php-src/archive/php-${php_version}.zip
RUN unzip /tmp/php-${php_version}.zip -d /tmp
RUN if [ "${ubuntu_version}" = 'precise' ] || [ "${ubuntu_version}" = 'trusty' ]; \
    then ln -s /usr/include/php5/ /usr/include/php && \
        sed 's/10.1/12.1/' -i /tmp/php-src-php-${php_version}/ext/pdo_oci/config.m4; \
    fi
WORKDIR /tmp/php-src-php-${php_version}/ext/pdo_oci
RUN phpize
RUN ./configure --with-pdo-oci=/opt/oracle/instantclient
RUN make install
WORKDIR /
RUN echo 'extension=pdo_oci.so' > ${php_ext_conf_dir}/pdo_oci.ini
RUN if [ "${ubuntu_version}" = 'trusty' ]; \
    then ln -s ../../mods-available/pdo_oci.ini /etc/php5/cli/conf.d/21-pdo_oci.ini; \
    elif [ "${ubuntu_version}" = 'xenial' ] || [ "${ubuntu_version}" = 'bionic' ]; \
    then phpenmod pdo_oci; \
    fi
RUN php -r 'exit(in_array("oci", PDO::getAvailableDrivers()) ? 0 : 1);'

# Copy compiled binaries to volume
CMD ext_dir=`php -r 'echo ini_get("extension_dir");'` && \
    host_owner=`stat -c '%u:%g' /host` && \
    cp "${ext_dir}/oci8.so" /host/oci8.so && \
    chown ${host_owner} /host/oci8.so && \
    cp "${ext_dir}/pdo_oci.so" /host/pdo_oci.so && \
    chown ${host_owner} /host/pdo_oci.so
