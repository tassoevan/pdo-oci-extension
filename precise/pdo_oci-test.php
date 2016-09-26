<?php
exit(in_array('oci', PDO::getAvailableDrivers()) ? 0 : 1);
