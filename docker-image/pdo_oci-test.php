<?php
if (in_array('oci', PDO::getAvailableDrivers())) {
  fwrite(STDOUT, "The PDO OCI driver was properly built!\n");
  exit(0);
} else {
  fwrite(STDERR, "The PDO OCI driver wasn't loaded by PHP. Something went wrong!\n");
  exit(1);
}
