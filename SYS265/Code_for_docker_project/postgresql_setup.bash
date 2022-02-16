#!/bin/bash
# 4
# Must be in the same directory as .csv file
# Must have: run dockerproj_dirmaker.bash on the home directory, have run docker-compose in the projects directory, and have run

# Copy .csv file into needed directory
cp class_info.csv ~/dockerproject/var/lib/postgresql/data

# Find the id of the container
ID_DOCK=$(docker ps -aqf "name=^postresql$")
#-q=only id output
#-a=all, even if the container isn't running
#-f=filter.
#^=must start here
#$=must end here

#docker exec $ID_DOCK '<COMMAND_GOES_HERE>'

# Create a table inside postgresql named "DataToDisplay"
docker exec $ID_DOCK 'CREATE TABLE DataToDisplay (id SERIAL,Class_Number VARCHAR(50),Class VARCHAR(50),Class_Time VARCHAR(50),PRIMARY KEY (id))'
# Specify what table is being copied to
docker exec $ID_DOCK 'COPY DataToDisplay'
# Specify what directory to copy the file from
docker exec $ID_DOCK 'FROM '/var/lib/postgresql/data''
# Specify delimiter
docker exec $ID_DOCK 'DELIMITER ',''
# Specify CSV clause
docker exec $ID_DOCK 'CSV HEADER;'