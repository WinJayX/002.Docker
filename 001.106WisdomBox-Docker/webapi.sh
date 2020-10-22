docker container run -d -p 809:80 \
	--name BoxWebApi -h BoxWebApi \
	-v /mnt/Data/WisdomBox/0307/webapi:/app \
	-v /mnt/Data/WisdomBox/0307/webjob/WisdomBoxJob/config.xml:/app/config.xml:ro \
	-v /mnt/Data/WisdomBox/0307/webjob/WisdomBoxJob/push.xml:/app/push.xml:ro \
    -v /mnt/Data/WisdomBox/0307/webjob/WisdomBoxJob/updatelog.xml:/app/updatelog.xml:ro \
	-v /mnt/Data/WisdomBox/0307/webjob/WisdomBoxJob/wwwroot:/app/wwwroot:ro \
	-v /etc/localtime:/etc/localtime:ro \
	--restart always \
	--network Box \
	boxapi:v0307
