docker container run -d -p 83:9090 \
-v /home/docker/83-prometheus/prometheus.yml:/etc/prometheus/prometheus.yml \
--mount src=prometheus_data,dst=/prometheus \
--name=prometheus \
prom/prometheus
