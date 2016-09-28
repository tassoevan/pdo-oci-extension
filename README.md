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

## 1. Install build tools and dependencies

You'll need `unzip`, PHP itself and some essentials to compile C programs:

```sh
$ apt-get install -y unzip php5 php5-cli php5-dev php-db php-pear build-essential libaio1 re2c
```

Extensions makefiles will try to include *.h files from `/usr/include/php`, a inexistent directory. However,
`/usr/include/php5` contains all relevant files to compiling, so we'll link it:

```sh
$ ln -s /usr/include/php5 /usr/include/php
```

## 2. Unzip Instant Client

`/opt/oracle/instantclient` is the right directory for the job of containing Instant Client files.

```sh
$ mkdir -p /opt/oracle/instantclient
```

Unzip basic files into `/opt/oracle`

```sh
$ unzip instantclient-basic-linux.x64-12.1.0.2.0.zip -d /opt/oracle
```

It'll create `/opt/oracle/instantclient_12_1` directory, that should be renamed as libraries directory:

```sh
$ mv /opt/oracle/instantclient_12_1 /opt/oracle/instantclient/lib
```

Same goes for SDK files:

```sh
$ unzip instantclient-sdk-linux.x64-12.1.0.2.0.zip -d /opt/oracle
$ mv /opt/oracle/instantclient_12_1/sdk/include /opt/oracle/instantclient/include
```

Some libraries have an irrelevant version number that can be safely ignored:

```sh
$ ln -s /opt/oracle/instantclient/lib/libclntsh.so.12.1 /opt/oracle/instantclient/lib/libclntsh.so
$ ln -s /opt/oracle/instantclient/lib/libocci.so.12.1 /opt/oracle/instantclient/lib/libocci.so
```

The Oracle libraries directory must be accessible anywhere:

```sh
$ echo /opt/oracle/instantclient/lib >> /etc/ld.so.conf
$ ldconfig
```

## 3rd step: Install the OCI8 PHP Extension

You need to download the ancient extension with the elderly [PECL](https://pecl.php.net/).

```sh
$ pecl install oci8-1.4.10
```

When prompted for Instant Client path, just type `instantclient,/opt/oracle/instantclient/lib`.

Now we should activate OCI8, differences between PHP versions in Ubuntu distros start to get in the way though.

* Ubuntu 12.04 (Precise) / PHP 5.3.10:

    Create file `/etc/php5/conf.d/oci8.ini` containing just one line:

    ```ini
    extension=oci8.so
    ```

* Ubuntu 14.04 (Trusty) / PHP 5.5.9:

    Create file `/etc/php5/mods-available/oci8.ini` containing just one line:

    ```ini
    extension=oci8.so
    ```

    Link it to activate on PHP CLI (command line interface):

    ```sh
    $ ln -s ../../mods-available/oci8.ini /etc/php5/cli/conf.d/20-oci8.ini
    ```

    If you have an Apache setup:

    ```sh
    $ ln -s ../../mods-available/oci8.ini /etc/php5/apache2/conf.d/20-oci8.ini
    ```

Now you have all `oci_*` functions available for PHP in both php-cli and Apache. Confirm it using this script:

```php
<?php
echo function_exists('oci_connect') ? 'OCI8 active' : 'OCI8 inactive';
```

## 4. Build and install the PDO/OCI PHP Extension

The `pdo_oci` library is outdated, so its install is more tricky.

Download `pdo_oci` via `pecl`:

```sh
$ pecl channel-update pear.php.net
$ cd /tmp
$ pecl download pdo_oci
```

Extract source:

```sh
$ tar xvf PDO_OCI-1.0.tgz -C /tmp
$ cd PDO_OCI-1.0
```

Patch `config.m4` to replace Instant Client 10.1 with 12.1;

```sh
$ sed 's/10.1/12.1/' -i /tmp/PDO_OCI-1.0/config.m4
```

Replace all references of `function_entry` to `zend_function_entry` in `pdo_oci.c`:

```sh
$ sed 's/function_entry/zend_function_entry/' -i /tmp/PDO_OCI-1.0/pdo_oci.c
```

Prepare and build:

```sh
$ phpize
$ ./configure --with-pdo-oci=/opt/oracle/instantclient
$ make install
```

* Ubuntu 12.04 (Precise) / PHP 5.3.10:

    Create file `/etc/php5/conf.d/pdo_oci.ini` containing just one line:

    ```ini
    extension=pdo_oci.so
    ```

* Ubuntu 14.04 (Trusty) / PHP 5.5.9:

    Create file `/etc/php5/mods-available/pdo_oci.ini` containing just one line:

    ```ini
    extension=pdo_oci.so
    ```

    Link it to activate on PHP CLI (command line interface):

    ```sh
    $ ln -s ../../mods-available/pdo_oci.ini /etc/php5/cli/conf.d/20-pdo_oci.ini
    ```

    If you have an Apache setup:

    ```sh
    $ ln -s ../../mods-available/pdo_oci.ini /etc/php5/apache2/conf.d/20-pdo_oci.ini
    ```

And now you can take a cup of coffee.
