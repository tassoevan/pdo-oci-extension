# How to have Oracle database connections in PHP over Ubuntu

## Before anything

### Taking risks

Long time I didn't write PHP aplications that connect to Oracle databases, implying that I'm not aware of any issues
related to this procedure. You are invited to contribute with your reports and workarounds and I'll do a review ASAP).

Alongside these things, you should consider the fact you are dealing with an experimental extension. It's strongly
inadvisable to use it at production environment and I expect you to not be using it in a outdated and unsupported PHP
version to provide products to your clients/customers/friends. I recommend you to see
[taq/pdooci](https://github.com/taq/pdooci).

### Ubuntu and Docker

All commands that should be performed in terminal are tested in [Docker](https://www.docker.com/) containers and they
are described inside the `builder/Dockerfile` file. Docker serves here to the purpouse of testing procedures of
compiling and install in an isolated environment. You can build the extension files using the containers and get them
in `build/` directory.

## How-tos

There are instructions for build and install the extensions using the server

* Ubuntu 12.04 (Precise Pangolim), PHP 5.3.10
  - [Step by step](step-by-step/precise.md)
  - [Using Docker](using-docker/precise.md)
* Ubuntu 14.04 (Trusty Tahr), PHP 5.5.9
  - [Step by step](step-by-step/trusty.md)
  - [Using Docker](using-docker/trusty.md)
