docker container run   \
--volume=/:/rootfs:ro   \
--volume=/var/run:/var/run:ro   \
--volume=/sys:/sys:ro   \
--volume=/var/lib/docker/:/var/lib/docker:ro   \
--volume=/dev/disk/:/dev/disk:ro   \
--publish=84:8080   \
--detach=true   \
--name=cadvisor   \
google/cadvisor:latest
