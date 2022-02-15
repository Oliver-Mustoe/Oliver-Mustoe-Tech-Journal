#!/bin/bash
# First, get the container id of the postgresql container!!!!
# Must have: run dockerproj_dirmaker.bash on the home directory, have run docker-compose in the projects directory, and have run

# Find the id of the container
ID_DOCK=$(docker ps -aqf "name=^postresql$")
#-q=only id output
#-a=all, even if the container isn't running
#-f=filter.
#^=must start here
#$=must end here

#docker exec $ID_DOCK '<COMMAND_GOES_HERE>'

# Create a table inside postgresql
docker exec $ID_DOCK 'CREATE TABLE DataToDisplay (id SERIAL,Class_Number VARCHAR(50),Class VARCHAR(50),Class_Time VARCHAR(50),PRIMARY KEY (id))'
# Specify where to copy a file to
docker exec $ID_DOCK 'COPY DataToDisplay'
# Specify delimiter
docker exec $ID_DOCK 'DELIMITER ',''
# Specify CSV clause
docker exec $ID_DOCK 'CSV HEADER;'

# WIP: How to get the .csv file into the container, what is setup in .yml (add in the FROM command)?
# https://www.postgresqltutorial.com/import-csv-file-into-posgresql-table/