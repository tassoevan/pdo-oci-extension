# How to have Oracle database connections in PHP 7.2.5 over Ubuntu 18.04 (Bionic Beaver)

## 1. Install build tools and dependencies

You'll need some essentials to compile C programs, a I/O library, `unzip` to uncompress sources, and `wget` and SSL
certificates to download files.

```sh
$ apt-get install -y build-essential re2c libaio1 unzip wget ca-certificates
```

## 2. Install PHP and PHP development packages

Obviously, you need PHP intepreter installed too. However, you need the development package to be able to compile
additional extensions by yourself.

```sh
$ apt-get install -y php7.2 php7.2-cli php7.2-dev
```

*Attention!* Before proceed, confirm your PHP version running `php --version`.

## 3. Install Oracle Instant Client Basic and SDK

Unfortunatelly, the [Oracle Instant Client](http://www.oracle.com/technetwork/database/features/instant-client/)
download can't be automated due license terms. That means you must be registered in Oracle (it's free) and get the ZIP
files by yourself. They are `instantclient-basic-linux.x64-12.2.0.1.0.zip` and
`instantclient-sdk-linux.x64-12.2.0.1.0.zip`.

`/opt/oracle/instantclient` is the right directory for the job of containing Instant Client files.

```sh
$ mkdir -p /opt/oracle/instantclient
```

Unzip Instant Client basic files into `/opt/oracle`.

```sh
$ unzip instantclient-basic-linux.x64-12.2.0.1.0.zip -d /opt/oracle
```

It'll create `/opt/oracle/instantclient_12_2` directory, that should be moved into our previously created directory as a
`lib` directory.

```sh
$ mv /opt/oracle/instantclient_12_2 /opt/oracle/instantclient/lib
```

Same goes for Instant Client SDK files, which are essentially headers.

```sh
$ unzip instantclient-sdk-linux.x64-12.2.0.1.0.zip -d /opt/oracle
$ mv /opt/oracle/instantclient_12_2/sdk/include /opt/oracle/instantclient/include
```

Some libraries have an irrelevant version number that can be safely ignored with a little hack:

```sh
$ ln -s /opt/oracle/instantclient/lib/libclntsh.so.12.1 /opt/oracle/instantclient/lib/libclntsh.so
$ ln -s /opt/oracle/instantclient/lib/libocci.so.12.1 /opt/oracle/instantclient/lib/libocci.so
```

*Attention!* Despite the `.12.1` in file names, they are present in Instant Client 12.2 too.

The Oracle libraries directory must be accessible anywhere:

```sh
$ echo /opt/oracle/instantclient/lib >> /etc/ld.so.conf
$ ldconfig
```

## 4. Build and install PHP OCI8 extension

The [Oracle Call Interface](http://www.oracle.com/technetwork/database/features/oci/index-090945.html) is present in PHP
through the [OCI8 extension](https://pecl.php.net/package/oci8) which, according the
[docs](http://php.net/manual/en/intro.oci8.php), enables access to Oracle Database 12c, 11g, 10g, 9i and 8i.

It's installed using `pecl`:

```
$ pecl install oci8-2.1.8
```

When prompted for Instant Client path, just type `instantclient,/opt/oracle/instantclient/lib`.

Now the OCI8 extension is compiled and installed, but disabled. To enable it:

```sh
$ echo 'extension=oci8.so' > /etc/php/7.2/mods-available/oci8.ini
$ phpenmod oci8
```

Now you have all `oci_*` functions available for PHP. Confirm it using running:

```sh
$ php -r 'echo "OCI8 is " . (function_exists("oci_connect") ? "on" : "off") . "\n";'
```

## 5. Build and install PHP PDO-OCI extension

*Attention!* The [PDO OCI driver](http://php.net/pdo_oci) was an experimental extension maintened by the PHP community.
Since you're dealing with a unsupported version of PHP, I think stability and safety aren't in your concerns.
I recommend you to see the [taq/pdooci](https://github.com/taq/pdooci).

Download and unzip the PHP source code.

```sh
$ wget -O /tmp/php-7.2.5.zip https://github.com/php/php-src/archive/php-7.2.5.zip
$ unzip /tmp/php-${php_version}.zip -d /tmp
```

Navigate to the extension source directory and patch `config.m4` to replace Instant Client version.

```sh
$ cd /tmp/php-src-php-7.2.5/ext/pdo_oci
$ sed 's/10.1/12.1/' -i config.m4
```

Prepare, build, and install:

```sh
$ phpize
$ ./configure --with-pdo-oci=/opt/oracle/instantclient
$ make install
```

Now the PDO OCI driver is compiled and installed, but disabled. To enable it:

```sh
$ echo 'extension=pdo_oci.so' > /etc/php/7.2/mods-available/pdo_oci.ini
$ phpenmod pdo_oci
```

Now `oci` DSN prefix is available in PDO. Confirm it using running:

```sh
$ php -r 'echo "PDO OCI driver is " . (in_array("oci", PDO::getAvailableDrivers()) ? "on" : "off") . "\n";'
```
