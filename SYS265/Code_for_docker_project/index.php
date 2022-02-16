<html>
</header>
    <title>
        testDB
    </title>
</header>

<body>
    <p>
        Below is the values entered into the database "testDB" in the table "DataToDisplay" :)
    </p>
    <?php
    # Contact database made in "docker-compose"
    $dbconn = pg_connect("host=postgresql dbname=testDB user=postgres password=postgres1") or die('Could not connect');

    # Query "dbconn" and get all of the values from "testexample"
    $rs = pg_query($dbconn, "SELECT * FROM datatodisplay") or die("Cannot execute query \n");
    
    # Query, fetch the values as an array of strings, which will display them on the webpage
    while ($row = pg_fetch_row($rs)) {
        echo "$row[0] $row[1] $row[2]\n";
      }

    # Close Connection
    pg_close($dbconn);
    ?>
</body>
</html>