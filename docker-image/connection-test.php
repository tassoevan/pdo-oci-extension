<?php
$tns = '
(DESCRIPTION =
    (ADDRESS_LIST =
        (ADDRESS =
            (PROTOCOL = TCP)
            (HOST = database)
            (PORT = 1521)
        )
    )
    (CONNECT_DATA =
        (SERVICE_NAME = xe)
    )
)';
$username = 'system';
$password = 'oracle';

sleep(60);
$start = time();
do {
    try {
        $conn = new PDO('oci:dbname=' . $tns, $username, $password);
        fwrite(STDOUT, "Connected!\n");
        break;
    }
    catch (PDOException $e) {
        fwrite(STDERR, "${$e->getMessage()}\n");
        sleep(5);
    }
} while(time() - $start < 60);
