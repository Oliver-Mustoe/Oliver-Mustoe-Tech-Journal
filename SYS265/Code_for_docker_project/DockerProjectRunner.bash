#!/bin/bash
# 1-3
# This script completes the project (making use of dockerproj_dirmaker.bash, docker-compose.yml, and postgresql_apache_setup.bash)

# Runs dockerproj_dirmaker.bash
bash dockerproj_dirmaker.bash
# Moves to the right directory (~/dockerproject)
cd ~/dockerproject
# Runs docker-compose (with sudo)
sudo docker-compose up -d
# Runs postgresql_apache_setup
bash postgresql_apache_setup