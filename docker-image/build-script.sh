#!/bin/bash

oci8_precise() {
  echo 'instantclient,/opt/oracle/instantclient/lib' | pecl install oci8-2.0.12
  echo 'extension=oci8.so' > /etc/php5/conf.d/oci8.ini
}

oci8_trusty() {
  echo 'instantclient,/opt/oracle/instantclient/lib' | pecl install oci8-2.0.12
  echo 'extension=oci8.so' > /etc/php5/mods-available/oci8.ini
  ln -s ../../mods-available/oci8.ini /etc/php5/cli/conf.d/20-oci8.ini
}

oci8_xenial() {
  echo 'instantclient,/opt/oracle/instantclient/lib' | pecl install oci8-2.1.2
  echo 'extension=oci8.so' > /etc/php/7.0/mods-available/oci8.ini
  phpenmod oci8
}

pdo_oci_precise() {
  pecl channel-update pear.php.net
  cd /tmp
  pecl download pdo_oci
  tar xvf /tmp/PDO_OCI-1.0.tgz -C /tmp
  sed 's/function_entry/zend_function_entry/' -i /tmp/PDO_OCI-1.0/pdo_oci.c
  sed 's/10.1/12.1/' -i /tmp/PDO_OCI-1.0/config.m4
  cd /tmp/PDO_OCI-1.0
  phpize
  ./configure --with-pdo-oci=/opt/oracle/instantclient
  make install
  echo 'extension=pdo_oci.so' > /etc/php5/conf.d/pdo_oci.ini
}

pdo_oci_trusty() {
  pecl channel-update pear.php.net
  cd /tmp
  pecl download pdo_oci
  tar xvf /tmp/PDO_OCI-1.0.tgz -C /tmp
  sed 's/function_entry/zend_function_entry/' -i /tmp/PDO_OCI-1.0/pdo_oci.c
  sed 's/10.1/12.1/' -i /tmp/PDO_OCI-1.0/config.m4
  cd /tmp/PDO_OCI-1.0
  phpize
  ./configure --with-pdo-oci=/opt/oracle/instantclient
  make install
  echo 'extension=pdo_oci.so'  > /etc/php5/mods-available/pdo_oci.ini
  ln -s ../../mods-available/pdo_oci.ini /etc/php5/cli/conf.d/20-pdo_oci.ini
}

pdo_oci_xenial() {
  wget -O /tmp/php-7.0.11.zip https://github.com/php/php-src/archive/php-7.0.11.zip
  unzip /tmp/php-7.0.11.zip -d /tmp
  cd /tmp/php-src-php-7.0.11/ext/pdo_oci
  phpize
  ./configure --with-pdo-oci=/opt/oracle/instantclient
  make install
  echo 'extension=pdo_oci.so'  > /etc/php/7.0/mods-available/pdo_oci.ini
  phpenmod pdo_oci
}

cmd_precise() {
  php /tmp/connection-test.php

  cp /usr/lib/php5/20090626/oci8.so /host/oci8.so
  chown `stat -c '%u:%g' /host` /host/oci8.so
  cp /usr/lib/php5/20090626/pdo_oci.so /host/pdo_oci.so
  chown `stat -c '%u:%g' /host` /host/pdo_oci.so
}

cmd_trusty() {
  php /tmp/connection-test.php

  cp /usr/lib/php5/20121212/oci8.so /host/oci8.so
  chown `stat -c '%u:%g' /host` /host/oci8.so
  cp /usr/lib/php5/20121212/pdo_oci.so /host/pdo_oci.so
  chown `stat -c '%u:%g' /host` /host/pdo_oci.so
}

cmd_xenial() {
  php /tmp/connection-test.php

  cp /usr/lib/php/20151012/oci8.so /host/oci8.so
  chown `stat -c '%u:%g' /host` /host/oci8.so
  cp /usr/lib/php/20151012/pdo_oci.so /host/pdo_oci.so
  chown `stat -c '%u:%g' /host` /host/pdo_oci.so
}

$1_$2
