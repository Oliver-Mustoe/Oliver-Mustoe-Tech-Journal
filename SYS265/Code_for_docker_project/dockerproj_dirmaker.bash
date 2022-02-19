#!/bin/bash
# 1
# Code makes the directory structure used in the projects
# Make postgresql structure (-p to make parent directories)
mkdir -p ~/dockerproject/var/lib/postgresql/data
# Make main Apache structure
mkdir -p ~/dockerproject/var/www/html
# Make main Apache logging structure
mkdir -p ~/dockerproject/var/log/apache2
# Copy all files to the project folder
cp * ~/dockerproject