#!/bin/bash
cd /home/docker
docker-compose -f ./81-harbor/docker-compose.yml up -d
./82-portainer/start.sh && ./83-prometheus/start.sh && \
./84-cadvisor/start.sh && ./85-grafana/start.sh && \
./86-70show/start.sh && ./87-40show/start.sh
