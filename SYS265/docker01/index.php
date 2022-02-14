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
    # Contact database made in "docker-compose"
    $dbconn = pg_connect("host=localhost dbname=testDB user=postgres password=postgres1") or die('Could not connect');

    # Query "dbconn" and get all of the values from "testexample"
    $rs = pg_query($dbconn, "SELECT * FROM testexample") or die("Cannot execute query \n");
    
    # Query, get values, then display them on the webpage
    while ($R = pg_fetch_row($rs)) {
        echo "$R[0] $R[1] $R[2]\n";
      }
    ?>
</body>
</html>