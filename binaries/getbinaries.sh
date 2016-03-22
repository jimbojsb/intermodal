#!/bin/bash
rm *.ova
rm docker
rm docker-compose
wget https://github.com/jimbojsb/intermodal-vm/releases/download/v0.4.1/Intermodal-0.4.1.ova
wget https://github.com/docker/compose/releases/download/1.6.2/docker-compose-Darwin-x86_64
wget https://get.docker.com/builds/Darwin/x86_64/docker-1.9.1
mv docker-compose-Darwin-x86_64 docker-compose
mv docker-1.9.1 docker
chmod +x docker
chmod +x docker-compose