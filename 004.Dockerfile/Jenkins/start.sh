docker container run -d --name Jenkins -h Jenkins -p 8888:8080 -p 50000:50000 \
-u root \
--rm \
-v /home/docker/Docker_Data/jenkins/:/var/jenkins_home \
-v /usr/share/apache-maven/:/usr/local/maven \
-v /usr/java/jdk-11.0.4:/usr/local/jdk \
-v /var/run/docker.sock:/var/run/docker.sock \
-v $(which docker):/usr/bin/docker \
-v ~/.ssh:/root/.ssh \
harbor.nercoa.com/winjay/jenkins:v2.222.2-centos
