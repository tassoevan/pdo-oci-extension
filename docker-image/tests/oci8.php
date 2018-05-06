<?php
if (function_exists('oci_connect')) {
  fwrite(STDOUT, "The OCI8 extension was properly built!\n");
  exit(0);
} else {
  fwrite(STDERR, "The OCI8 extension wasn't loaded by PHP. Something went wrong!\n");
  exit(1);
}
