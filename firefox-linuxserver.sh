#!/bin/bash

# pull the image
docker pull linuxserver/firefox

# run the image
docker run -d \
  --name="container-name" \
  -e PUID=1000 \
  -e PGID=1000 \
  -e TZ=America/New_York \
  -p 3000:3000 \
  -v $HOME/firefox-cache:/config \
  --shm-size="lgb" \
  linuxserver/firefox

# open browser to http://localhost:3xxx
