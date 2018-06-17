# How to have Oracle database connections in PHP 7.2.5 over Ubuntu 18.04 (Bionic Beaver) using Docker

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
$ docker-compose build bionic
$ docker-compose run bionic
```

The image build command is often automatically performed during container creation, but it's interesting to perform it
as an isolated step since all compilation workload is in it.

The built files `oci8.so` and `pdo_oci.so` will be under `build/bionic` directory.

## 3. Install the binaries and enable the extensions

Run the following command to getting your PHP extensions directory.

```sh
$ ext_dir=`php -r 'echo ini_get("extension_dir");'`
$ echo $ext_dir
```

Copy the compiled binaries to it.

```sh
$ cp build/bionic/oci8.so build/bionic/pdo_oci.so "${ext_dir}/"
```

Create the configuration files and enable them for load these extensions.

```sh
$ echo 'extension=oci8.so' > /etc/php/7.2/mods-available/oci8.ini
$ phpenmod oci8
$ echo 'extension=pdo_oci.so' > /etc/php/7.2/mods-available/pdo_oci.ini
$ phpenmod pdo_oci
```

Now you have all `oci_*` functions and the PDO `oci` DSN prefix available in PHP. Confirm it using running:

```sh
$ php -r 'echo "OCI8 is " . (function_exists("oci_connect") ? "on" : "off") . "\n";'
$ php -r 'echo "PDO OCI driver is " . (in_array("oci", PDO::getAvailableDrivers()) ? "on" : "off") . "\n";'
```
