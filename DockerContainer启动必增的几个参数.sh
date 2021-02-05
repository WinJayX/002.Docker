#!/bin/bash
# author:WinJayX
# date:2019-11-14
# Maintainer WinJayX <WinJayX@Gmail.com>
# func:每10秒自动监测nerc.service服务状态且在退出时执行重启操作
# 
docker container run -d \
	--mount type=bind,src=/usr/local/src/NERC.UniversalColleges.Test,dst=/app \
	
	--mount source=${CONTAINER_NAME}-data,destination=/data
	--volume /etc/localtime:/etc/localtime:ro \
	--restart always \
    --user root \
	--name Nessus \
   	--hostname Nessus \
  	-p 8834:8834 \
  	-p 8822:22 \
  	-p 8010:80 \
	-p 9000-9999:9000-9999 \
	universalcolleges:v1.0

