FROM microsoft/dotnet
#FROM harbor.nercoa.com/winjay/dotnet:v2.2.207
MAINTAINER WinJayX <WinJayX@Gmail.com>
LABEL description="This is WanRen Project"
LABEL version="1.0"
USER root

#解决业务无法显示验证码问题。
RUN apt-get update -y && apt-get upgrade -y
RUN apt-get install libgdiplus -y && ln -s libgdiplus.so gdiplus.dll
RUN ln -s /lib/x86_64-linux-gnu/libdl-2.24.so /lib/x86_64-linux-gnu/libdl.so

#安装视频转码组件，根据具体业务内容而定。
RUN apt install ffmpeg

WORKDIR /app

#将当前目录下的文件，复制到WORKDIR目录,适用于打包整个项目及DockerFile在一个包中的情况。
#如果有创建数据卷则需要运行时src=VolumeName,dst=/app挂载。
#COPY . /app/

#项目变更时，注意修改.dll文件名称
ENTRYPOINT ["dotnet", "Cultivite.dll"]
