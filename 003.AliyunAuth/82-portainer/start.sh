docker container run -d -p 82:9000 \
--mount src=portainer_data,dst=/data \
--mount type=bind,src=/var/run/docker.sock,dst=/var/run/docker.sock \
--name=portainer \
portainer/portainer
