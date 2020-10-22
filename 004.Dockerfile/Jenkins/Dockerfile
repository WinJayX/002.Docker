FROM jenkins/jenkins

USER root

RUN echo '' > /etc/apt/sources.list.d/jessie-backports.list && \
  wget http://70show.5minutes.com.cn/debian-source.list -O /etc/apt/sources.list

RUN apt-get update && apt-get install -y git libltdl-dev
