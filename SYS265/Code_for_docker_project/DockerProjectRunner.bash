#!/bin/bash
# 1-3
# This script completes the project (making use of dockerproj_dirmaker.bash, docker-compose.yml, and postgresql_apache_setup.bash)
# Waits for scrip flow
# Runs dockerproj_dirmaker.bash
bash dockerproj_dirmaker.bash
wait
# Moves to the right directory (~/dockerproject)
cd ~/dockerproject
wait
# Runs docker-compose (with sudo)
sudo docker-compose up -d
wait
# Runs postgresql_apache_setup
bash postgresql_apache_setup.bash