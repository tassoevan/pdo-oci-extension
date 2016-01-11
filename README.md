# The motherf*cking way the get Oracle database connections in PHP5 over Ubuntu

Special thanks to:
  
* [AJ ONeal](https://twitter.com/coolaj86)
* [Hsiao Siyuan](http://hsiaosiyuan.com/wp/)

## First step: Install the Oracle Client

1. Download Instant Client from http://www.oracle.com/technetwork/database/features/instant-client/ (you must be registered in Oracle; it's free). You'll need `instantclient-basic-*-*.zip` and `instantclient-sdk-*-*.zip`  files.
2. Execute the following commands in your terminal:

    ```sh
    $ sudo su -  
    $ mkdir -p /opt/oracle/instantclient
    $ cd /opt/oracle/instantclient
    ```

3. Copy downloaded files into `/opt/oracle/instantclient`.
4. Unzip files executing these commands:

    ```sh
    $ unzip instantclient-basic-*-*.zip
    $ unzip instantclient-sdk-*-*.zip
    ```

5. Move all `/opt/oracle/instantclient/instantclient` content to `/opt/oracle/instantclient`:

    ```sh
    $ mv instantclient*/* ./
    $ rmdir instantclient*/
    ```

6. During extension compiling, some errors will arise when linking with some libraries. To avoid them, do:

    ```sh
    $ ln -s libclntsh.so.* libclntsh.so
    $ ln -s libocci.so.* libocci.so
    $ echo /opt/oracle/instantclient >> /etc/ld.so.conf
    $ ldconfig
    ```

7. Create a folder for your network configuration files:
    ```sh
    $ mkdir -p network/admin
    ```
8. Place `sqlnet.ora` and `tnsnames.ora` files in `/opt/oracle/instantclient/network/admin`.

Now you have the basic connection kit for connections and SDK for compiling PHP extensions.

## Second step: Install the OCI8 PHP Extension

1. Get all essential packages for download and compiling from PEAR repositories:

    ```sh
    $ apt-get install --yes php5 php5-cli php5-dev php-db php-pear
    $ apt-get install --yes build-essential libaio1
    ```

2. Request OCI8 install:

    ```sh
    $ pecl install oci8
    ```
    Type `instantclient,/opt/oracle/instantclient` when prompted for Instant Client path.

3. Save this text in `/etc/php5/mods-available/oci8.ini`:

    ``` ini
    extension=oci8.so
    ```

4. Activate extension:

    ```sh
    $ php5enmod oci8
    ```

Now you have all `oci_*` functions available for PHP in both php-cli and Apache.

## Third step: Install the PDO/OCI PHP Extension

The `pdo_oci` library is outdated, so its install is more tricky.

1. Fix paths:

    ```sh
    $ cd /usr/include/
    $ ln -s php5 php
    $ cd /opt/oracle/instantclient
    $ mkdir -p include/oracle/11.1/
    $ cd include/oracle/11.1/
    $ ln -s ../../../sdk/include client
    $ cd -
    $ mkdir -p lib/oracle/11.1/client
    $ cd lib/oracle/11.1/client
    $ ln -s ../../../../ lib
    $ cd -
    ```

2. Download `pdo_oci` via `pecl`:

    ```sh
    $ pecl channel-update pear.php.net
    $ mkdir -p /tmp/pear/download/
    $ cd /tmp/pear/download/
    $ pecl download pdo_oci
    ```
    
3. Extract source:

    ```sh
    $ tar xvf PDO_OCI*.tgz
    $ cd PDO_OCI*
    ```
    
4. Create a file named `config.m4.patch`:

    ```
    *** config.m4	2005-09-24 17:23:24.000000000 -0600
    --- /home/myuser/Desktop/PDO_OCI-1.0/config.m4	2009-07-07 17:32:14.000000000 -0600
    ***************
    *** 7,12 ****
    --- 7,14 ----
        if test -s "$PDO_OCI_DIR/orainst/unix.rgs"; then
          PDO_OCI_VERSION=`grep '"ocommon"' $PDO_OCI_DIR/orainst/unix.rgs | sed 's/[ ][ ]*/:/g' | cut -d: -f 6 | cut -c 2-4`
          test -z "$PDO_OCI_VERSION" && PDO_OCI_VERSION=7.3
    +   elif test -f $PDO_OCI_DIR/lib/libclntsh.$SHLIB_SUFFIX_NAME.11.1; then
    +     PDO_OCI_VERSION=11.1    
        elif test -f $PDO_OCI_DIR/lib/libclntsh.$SHLIB_SUFFIX_NAME.10.1; then
          PDO_OCI_VERSION=10.1    
        elif test -f $PDO_OCI_DIR/lib/libclntsh.$SHLIB_SUFFIX_NAME.9.0; then
    ***************
    *** 119,124 ****
    --- 121,129 ----
          10.2)
            PHP_ADD_LIBRARY(clntsh, 1, PDO_OCI_SHARED_LIBADD)
            ;;
    +     11.1)
    +       PHP_ADD_LIBRARY(clntsh, 1, PDO_OCI_SHARED_LIBADD)
    +       ;;
          *)
            AC_MSG_ERROR(Unsupported Oracle version! $PDO_OCI_VERSION)
            ;;
    #EOF
    ```
    
5. Apply patch:

    ``` sh
    $ patch --dry-run -i config.m4.patch && patch -i config.m4.patch && phpize
    ```

6. Replace all references of `function_entry` to `zend_function_entry` in `pdo_oci.c`.

7. Configure, compile and install:

    ``` sh
    $ ORACLE_HOME=/opt/oracle/instantclient ./configure --with-pdo-oci=instantclient,/opt/oracle/instantclient,11.1
    $ make && make test && make install && mv modules/pdo_oci.so /usr/lib/php5/*+lfs/
    ```

8. Save this text in `/etc/php5/mods-available/pdo_oci.ini`:

    ``` ini
    extension=pdo_oci.so
    ```

9. Activate extension:

    ```sh
    $ php5enmod pdo_oci
    ```
    
And now you can take a cup of coffee.