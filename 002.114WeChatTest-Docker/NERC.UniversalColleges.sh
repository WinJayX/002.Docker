#!/bin/bash
docker container run \
	--mount type=bind,src=/usr/local/src/NERC.UniversalColleges.Test,dst=/app \
	--name UniversalColleges \
	-v /etc/localtime:/etc/localtime:ro \
	-h UniversalColleges \
	-p 8010:80 \
	universalcolleges:v1.0

