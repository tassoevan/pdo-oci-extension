# How to have Oracle database connections in PHP 5.5.9 over Ubuntu 14.04 (Trusty Tahr) using Docker

Since keep a compilation environment for building extensions can be impossible or simply undesirable, I wrote an Docker
image for it alongside a Docker Compose configuration to compile the binaries. However, the setup of this extensions are
still under your responsability.

## 1. Preparing the source code

Clone the repository using `git`

```sh
$ git clone https://github.com/tassoevan/pdo-oci-extension.git
```

or [download](https://github.com/tassoevan/pdo-oci-extension/archive/master.zip) and unzip it. You'll be working inside
the `pdo-oci-extension` directory now.

Unfortunatelly, the [Oracle Instant Client](http://www.oracle.com/technetwork/database/features/instant-client/)
download can't be automated due license terms. That means you must be registered in Oracle (it's free) and get the ZIP
files by yourself. They are `instantclient-basic-linux.x64-12.2.0.1.0.zip` and
`instantclient-sdk-linux.x64-12.2.0.1.0.zip`, and should by placed in the `builder/instantclient/` directory.

## 2. Build the Docker image and create and run the Docker container

```sh
$ docker-compose build trusty
$ docker-compose run trusty
```

The image build command is often automatically performed during container creation, but it's interesting to perform it
as an isolated step since all compilation workload is in it.

The built files `oci8.so` and `pdo_oci.so` will be under `build/trusty` directory.

## 3. Install the binaries and enable the extensions

Run the following command to getting your PHP extensions directory.

```sh
$ ext_dir=`php -r 'echo ini_get("extension_dir");'`
$ echo $ext_dir
```

Copy the compiled binaries to it.

```sh
$ cp build/trusty/oci8.so build/trusty/pdo_oci.so "${ext_dir}/"
```

Create the configuration files for load these extensions.

```sh
$ echo 'extension=oci8.so' > /etc/php5/mods-available/oci8.ini
$ echo 'extension=pdo_oci.so' > /etc/php5/mods-available/pdo_oci.ini
```

Link it to activate on PHP CLI (command line interface):

```sh
$ ln -s /etc/php5/mods-available/oci8.ini /etc/php5/cli/conf.d/20-oci8.ini
$ ln -s /etc/php5/mods-available/pdo_oci.ini /etc/php5/cli/conf.d/20-pdo_oci.ini
```

And if you have an Apache setup:

```sh
$ ln -s /etc/php5/mods-available/oci8.ini /etc/php5/apache2/conf.d/20-oci8.ini
$ ln -s /etc/php5/mods-available/pdo_oci.ini /etc/php5/apache2/conf.d/20-pdo_oci.ini
```

Now you have all `oci_*` functions and the PDO `oci` DSN prefix available in PHP. Confirm it using running:

```sh
$ php -r 'echo "OCI8 is " . (function_exists("oci_connect") ? "on" : "off") . "\n";'
$ php -r 'echo "PDO OCI driver is " . (in_array("oci", PDO::getAvailableDrivers()) ? "on" : "off") . "\n";'
```
