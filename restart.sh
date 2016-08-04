#!/bin/bash

eval $(docker-machine env stable)
docker-compose build
eval $(docker-machine env --swarm home)
MSHARD_URI=http://mshard.ermaker.tk docker-compose up -d --force-recreate
