<?php
function create_connection($tns, $username, $password, $timeout) {
    for ($start = time(); time() - $start < $timeout;) {
        try {
            return new PDO("oci:dbname=${tns}", $username, $password, array(
                PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION
            ));
        } catch (PDOException $e) {
            fwrite(STDERR, "{$e->getMessage()}\n");
            sleep(10);
        }
    }

    fwrite(STDERR, "Timed out!\n");
    exit(1);
}

function test_clob(PDO $db) {
    $tableName = 'test_table_' . getenv('ubuntu_version');
    $createTableQuery = $db->prepare("CREATE TABLE $tableName(col CLOB NULL)");
    $insertRowQuery = $db->prepare("INSERT INTO $tableName VALUES(NULL)");
    $selectRowsQuery = $db->prepare("SELECT col FROM $tableName");
    $deleteTableQuery = $db->prepare("DROP TABLE $tableName");

    try {
        $deleteTableQuery->execute();
    } catch (PDOException $e) {}

    $createTableQuery->execute();
    $insertRowQuery->execute();

    $selectRowsQuery->execute();
    $rows = $selectRowsQuery->fetchAll(PDO::FETCH_ASSOC);

    $deleteTableQuery->execute();
}

$tns = <<<TNS
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
)
TNS;
$username = 'system';
$password = 'oracle';

fwrite(STDOUT, "Connecting to database container...\n");
$db = create_connection($tns, $username, $password, 120);
fwrite(STDOUT, "Connected!\n");

try {
    fwrite(STDOUT, "Testing CLOB...\n");
    test_clob($db);
    fwrite(STDOUT, "Test passed!\n");
} catch (Exception $e) {
    fwrite(STDERR, "${e}\n");
    exit(1);
}
