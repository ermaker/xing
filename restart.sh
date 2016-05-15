#!/bin/bash

eval $(docker-machine env stable)
docker-compose build
eval $(docker-machine env --swarm home)
docker-compose up -d --force-recreate
