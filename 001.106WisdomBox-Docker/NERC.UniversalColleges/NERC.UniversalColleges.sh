#!/bin/bash
docker container run \
	--mount type=bind,src=/usr/local/src/NERC.UniversalColleges.Test,dst=/app \
	# -v 
	--name UniversalColleges \
	-h UniversalColleges \
	-p 80:80 \
	universalcolleges:v1.0