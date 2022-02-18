#!/bin/bash
# 1-3
# This script completes the project (making use of dockerproj_dirmaker.bash, docker-compose.yml, and postgresql_apache_setup.bash)

bash dockerproj_dirmaker.bash

cd ~/dockerproject

sudo docker-compose up -d

bash postgresql_apache_setup