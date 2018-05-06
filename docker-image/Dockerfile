ARG ubuntu_version
FROM ubuntu:${ubuntu_version}

ARG ubuntu_version

LABEL maintainer="Tasso Evangelista <tasso@tassoevan.me>"

# Install build dependencies
ENV DEBIAN_FRONTEND noninteractive

RUN apt-get update && \
    apt-get install -y unzip build-essential libaio1 re2c wget

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

# Add scripts
ADD build-script.sh /tmp/build-script.sh
ADD tests/oci8.php /tmp/oci8.php
ADD tests/pdo_oci.php /tmp/pdo_oci.php
ADD tests/connection.php /tmp/connection.php

# Install PHP development packages
RUN /tmp/build-script.sh php ${ubuntu_version}

# Build and install PHP OCI8 extension
RUN /tmp/build-script.sh oci8 ${ubuntu_version}
RUN php /tmp/oci8.php

# Build and install PHP PDO-OCI extension
RUN /tmp/build-script.sh pdo_oci ${ubuntu_version}
RUN php /tmp/pdo_oci.php

# Setup runtime
ENV ubuntu_version=${ubuntu_version}
CMD /usr/bin/php /tmp/connection.php && \
    /tmp/build-script.sh cmd ${ubuntu_version}
