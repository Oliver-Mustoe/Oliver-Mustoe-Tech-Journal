#!/usr/bin/bash
# Code makes the directory structure used in the projects
# Make postgresql structure (-p to make parent directories)
mkdir -p ./dockerproject/var/lib/postgresql/data;
# Make main Apache structure
mkdir -p ./dockerproject/var/www/html;
# Make main Apache logging structure
mkdir -p ./dockerproject/var/log/apache2;

# NOTE: It may generate errors about "\r", from testing this does not seem to affect the wanted outcome of the directory structure