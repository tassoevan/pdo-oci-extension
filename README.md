# The motherf*cking way the get Oracle database connections in PHP5 over Ubuntu, revisited

Special thanks to:

* AJ ONeal
* Hsiao Siyuan

## Before anything

### Taking risks

Long time I didn't write PHP aplications that connect to Oracle databases, implying that I'm not aware of any issues
related to this procedure. You are invited to contribute with your reports and workarounds (some of them are commented
[here](https://gist.github.com/tassoevan/10392954) and I'll do a review ASAP).

Alongside these things, you should consider the fact you are dealing with an experimental extension. It's strongly
inadvisable use it at production environment. I recommend you to see the awesome
[taq/pdooci](https://github.com/taq/pdooci).

### Ubuntu and Docker

Ubuntu versions tested are 12.04 (Precise) and 14.04 (Trusty). All commands that should be performed in terminal are
describe inside the `precise/Dockerfile` and `trusty/Dockerfile` files. [Docker](https://www.docker.com/) serves to the
purpouse of testing procedures of compiling and install in an isolated environment. You can export the compiled
extension files and even the Instant Client directory using a container mount point, though.

### Download Oracle Instant Client, manually

Unfortunatelly, the [Oracle Instant Client](http://www.oracle.com/technetwork/database/features/instant-client/)
download can't be automated due license terms. That means you must be registered in Oracle (it's free) and get the ZIP
files by yourself. They are `instantclient-basic-linux.x64-12.1.0.2.0.zip` and
`instantclient-sdk-linux.x64-12.1.0.2.0.zip`, and should be placed inside `precise/instantclient` and
`trusty/instantclient`.

## 1st step: Install build tools and dependencies

You'll need `unzip`, PHP itself and some essentials to compile C programs:

```sh
apt-get install -y unzip php5 php5-cli php5-dev php-db php-pear build-essential libaio1 re2c
```

Extensions makefiles will try to include *.h files from `/usr/include/php`, a inexistent directory. However,
`/usr/include/php5` contains all relevant files to compiling, so we'll link it:

```sh
ln -s /usr/include/php5 /usr/include/php
```

## 2nd step: Unzip Instant Client

`/opt/oracle/instantclient` is the right directory for the job of containing Instant Client files.

```sh
mkdir -p /opt/oracle/instantclient
```

Unzip basic files into `/opt/oracle`

```sh
unzip instantclient-basic-linux.x64-12.1.0.2.0.zip -d /opt/oracle
```

It'll create `/opt/oracle/instantclient_12_1` directory, that should be renamed as the lib directory:

```sh
mv /opt/oracle/instantclient_12_1 /opt/oracle/instantclient/lib
```

Same goes for SDK files:

```sh
unzip instantclient-sdk-linux.x64-12.1.0.2.0.zip -d /opt/oracle
mv /opt/oracle/instantclient_12_1/sdk/include /opt/oracle/instantclient/include
```

Some libraries have an irrelevant version number that can be safely ignored:

```sh
ln -s /opt/oracle/instantclient/lib/libclntsh.so.12.1 /opt/oracle/instantclient/lib/libclntsh.so
ln -s /opt/oracle/instantclient/lib/libocci.so.12.1 /opt/oracle/instantclient/lib/libocci.so
```

The Oracle lib directory must be accessible anywhere:

```sh
echo /opt/oracle/instantclient/lib >> /etc/ld.so.conf
ldconfig
```

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