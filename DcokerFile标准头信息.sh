FROM microsoft/dotnet|XXXXXX
MAINTAINER WinJayX <WinJayX@Gmail.com>
LABEL description="This is WanRen Project"
LABEL version="1.0"
USER root

#解决业务无法显示验证码问题。
RUN apt-get update -y && apt-get upgrade -y
RUN apt-get install libgdiplus -y && ln -s libgdiplus.so gdiplus.dll
RUN ln -s /lib/x86_64-linux-gnu/libdl-2.24.so /lib/x86_64-linux-gnu/libdl.so

#解决时区问题
RUN ln -sf /usr/share/zoneinfo/Asia/Shanghai /etc/localtime

WORKDIR /app

#将当前目录下的文件，复制到WORKDIR目录,适用于打包整个项目及DockerFile在一个包中的情况。
#如果有创建数据卷则需要运行时src=VolumeName,dst=/app挂载。
COPY . /app/

#项目变更时，注意修改.dll文件名称
ENTRYPOINT ["dotnet", "Cultivite.dll"]
