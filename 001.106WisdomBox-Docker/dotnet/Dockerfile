FROM microsoft/dotnet
MAINTAINER WinJayX <WinJayX@Gmail.com>
LABEL description="This is a dotnet image"
LABEL version="1.0"
USER root

WORKDIR /app

#将当前目录下的文件，复制到WORKDIR目录,适用于打包整个项目及DockerFile在一个包中的情况。
#如果有创建数据卷则需要运行时src=VolumeName,dst=/app挂载。
COPY . /app
RUN apt-get update && apt-get upgrade

EXPOSE 80
#项目变更时，注意修改.dll文件名称
ENTRYPOINT ["dotnet", "Nerc.ActivityWeek.FrontEnd.dll"]
