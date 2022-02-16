#!/bin/bash
# 3 & 4
# Must be in the same directory as .csv file
# Must have: run dockerproj_dirmaker.bash on the home directory, have run docker-compose in the projects directory
# Create a network for the two containers to function in, connect them to it
# Creates network
docker network create webdata-network

# Adds containers to the network (each container can now reference the other with the hostnames)
docker network connect webdata-network postgresql
docker network connect webdata-network apache
# Copy .csv file to the postgresql container
docker cp ~/Code_for_docker_project/class_info.csv postgresql:/var/lib/postgresql/data/class_info.csv

# Run the contents of the  .sql file against the postgresql container
cat ~/Code_for_docker_project/class_to_table.sql | docker exec -i postgresql psql -U postgres -d testDB
# The .sql file will:
# Delete and duplicate tables
# Create a table inside postgresql named "datatodisplay"
# Specify what table is being copied to
# Specify what directory to copy the file from
# Specify delimiter
# Specify CSV clause

# Copy .php file to the apache container
docker cp ./index.php apache:/var/www/html/index.php

# Open port for apache
sudo ufw allow 1492/tcp