#!/bin/bash
# 3
# Create a network for the two containers to function in, connect them to it
# Creates network
docker network create webdata-network

# Adds containers to the network (each container can now reference the other with the hostnames)
docker network connect webdata-network postgresql
docker network connect webdata-network apache