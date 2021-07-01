docker container run -d \
	--volume /etc/localtime:/etc/localtime:ro \
	--volume `pwd`/conf.d:/etc/nginx/conf.d \
	--name nginx \
	--user root \
	-p 80:80 \
	-p 443:443 \
   	--hostname nginx \
	--restart always \
	nginx
