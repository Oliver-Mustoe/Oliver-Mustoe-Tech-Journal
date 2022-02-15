<html>
</header>
    <title>
        testDB
    </title>
</header>

<body>
    <p>
        Below is the values entered into the database "testexample" :)
    </p>
    <?php
    # Contact database made in "docker-compose" (it's hosstname is 'postgresql' since that is the container name)
    $dbconn = pg_connect("host=postgresql dbname=testDB user=postgres password=postgres1") or die('Could not connect');

    # Query "dbconn" and get all of the values from "testexample"
    $rs = pg_query($dbconn, "SELECT * FROM testexample") or die("Cannot execute query \n");
    
    # Query, fetch the values as an associative array, then display them on the webpage using the key values
    while ($row = pg_fetch_assoc($rs)) {
        echo $row['Class Number'] . " " . $row['Class'] . " " . $row['Class Time'];
        echo "\n";
    }

    # Close Connection
    pg_close($dbconn);
    ?>
</body>
</html>