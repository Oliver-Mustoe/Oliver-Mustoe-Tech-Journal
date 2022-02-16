#!/bin/bash
# 3
# Must have: run dockerproj_dirmaker.bash, have run docker-compose in the projects directory
# Create a network for the two containers to function in, connect them to it, create table and run .sql file against database, copy needed files to web server, open ports
# Creates network
docker network create webdata-network

# Adds containers to the network (each container can now reference the other with the hostnames)
docker network connect webdata-network postgresql
docker network connect webdata-network apache

# Run the contents of the .sql file against the postgresql container
cat ./class_to_table.sql | docker exec -i postgresql psql -U postgres -d testDB
# The .sql file will:
# Create a table inside postgresql named "datatodisplay"
# Populate it with my class data

# Copy .php file to the apache container
docker cp ./index.php apache:./var/www/html/index.php

# Open port for apache
sudo ufw allow 1492/tcp