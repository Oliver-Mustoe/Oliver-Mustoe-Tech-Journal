#!/bin/bash
# 4
# Must be in the same directory as .csv file
# Must have: run dockerproj_dirmaker.bash on the home directory, have run docker-compose in the projects directory, and have run

# Copy .csv file to the postgresql container
docker cp ./class_info.csv postgresql:/var/lib/postgresql/data/class_info.csv

# Run the contents of the  .sql file against the postgresql container
cat ./class_to_table.sql | docker exec -i postgresql psql -U postgre -d testDB
# The .sql file will:
# Create a table inside postgresql named "DataToDisplay"
# Specify what table is being copied to
# Specify what directory to copy the file from
# Specify delimiter
# Specify CSV clause

# Copy .php file to the apache container
docker cp ./index.php apache:/var/www/html/index.php