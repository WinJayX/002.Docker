```groovy
/*  MAINTAINER WinJayX <WinJayX@Gmail.com>
 *  LABEL description="This is DotNetCore2.2 Project"
 *  LABEL version="1.0"
 */
 
 //变量 branch 在参数化构建中添加
 
    //阶段1：拉取代码，node 节点未指定，则在Master执行，因为Git、Maven 环境都在 Master,所以就在主节点执行了
stage('Git Checkout') {
    node('MSBuild') {
       checkout([$class: 'GitSCM', branches: [[name: 'develop']], doGenerateSubmoduleConfigurations: false, extensions: [], submoduleCfg: [], userRemoteConfigs: [[credentialsId: '973c9a08-4d62-4f8a-8792-7a214b7ffe66', url: 'https://git.nercoa.com/fz/sdk/fz.common.git']]])
    }
}

    //阶段2：Dotnet编译代码
stage('Build'){
    node('MSBuild') {
       echo '编译解决方案'
       bat "$DOTNET publish  -c Release -o \"${WORKSPACE}/publish\" \"src/FZ.Transcoding/FZ.Transcoding.SubscriberService\" "
    }
}

stage('Backup To The Site Directory'){
    node('MSBuild') {
        dir('publish') {
            bat "zip -r ${BUILD_NUMBER}.zip ./"
        }
        echo '拷贝文件至备份目录'
        bat "xcopy \"publish/${BUILD_NUMBER}.zip\" \"${BACKUP_SHARE_DIR}/${JOB_NAME}/\" /fyi "
        bat "rm -rf publish*"        
   }
}

stage('Download Project Code'){
    node('TestEnv') {
        echo '建立业务目录'
        //sh "mkdir -p ${JOB_NAME} && cd ${JOB_NAME}"
        echo '下载程序'
        sh "curl -O ${PUBLISH_HOST}/${JOB_NAME}/${BUILD_NUMBER}.zip"
        echo '解压源程序'
        sh "unzip -o ${BUILD_NUMBER}.zip && rm -f ${BUILD_NUMBER}.zip"
    }
}    

    
    //阶段3：构建Docker镜像并推送到私有仓库
stage('Build And Push Image') {
    node('TestEnv') { 
sh '''
REPOSITORY=hub.nercoa.com/sdk/subscriber_service:${ImageTag}
cat > Dockerfile << EOF
#注意选择镜像镜像版 
FROM mcr.microsoft.com/dotnet/core/aspnet:3.1
MAINTAINER WinJayX <WinJayX@Gmail.com>
LABEL description="This is FZ.Transcoding.SubscriberService Project"
LABEL version="3.1"
USER root

###安装视频转码组件FFmpeg###
RUN apt-get update -y && apt-get upgrade -y
RUN apt install ffmpeg -y

###安装LibreOffice_7.1.2###
RUN curl -o /opt/LibreOffice_7.1.3_Linux_x86-64_deb.tar.gz \
        https://mirrors.cloud.tencent.com/libreoffice/libreoffice/stable/7.1.3/deb/x86_64/LibreOffice_7.1.3_Linux_x86-64_deb.tar.gz \
        && cd /opt \
        && tar -xzvf LibreOffice_7.1.3_Linux_x86-64_deb.tar.gz \
        && dpkg -i LibreOffice_7.1.3.2_Linux_x86-64_deb/DEBS/*.deb \
        && rm -rf /opt/LibreOffice* \
        && ln -s /usr/local/bin/libreoffice7.1 /usr/local/bin/libreoffice

###下载安装动态库文件###
RUN curl -o /usr/local/lib/libfile.tar.gz \
        https://www.winjay.cn/upload/2021/04/libfile-83138de2a6fb4777a7d4b74784626fb5.tar.gz \
        && cd /usr/local/lib/ && tar -xzvf libfile.tar.gz \
        && rm -rf libfile.tar.gz \
        && ldconfig


###安装中文字体###
RUN apt-get install -y fonts-noto-cjk

### 对连接sqlServer协议进行降级 
RUN sed -i 's/TLSv1.2/TLSv1.0/g' /etc/ssl/openssl.cnf

WORKDIR /app

#将当前目录下的文件，复制到WORKDIR目录,适用于打包整个项目及DockerFile在一个包中的情况。
#如果有创建数据卷则需要运行时src=VolumeName,dst=/app挂载。
COPY . /app/

#项目变更时，注意修改.dll文件名称
ENTRYPOINT ["dotnet", "FZ.Transcoding.SubscriberService.dll"]

EOF

docker build -t $REPOSITORY .
docker login hub.nercoa.com -u admin -p Nerc.nerc/1
docker push $REPOSITORY
'''
    }
}

/*

    //阶段4：部署到远程Node Docker主机节点
stage('Deploy To The Test Server') {
    node('TestEnv') { 
        sh '''
        REPOSITORY=harbor.nercoa.com/robot/robot:${ImageTag}
        docker rm -f Robot || true
        docker container run -d \
        --volume /etc/localtime:/etc/localtime:ro \
        --restart always \
        --user root \
        --name Robot \
        --hostname Robot \
        -p 8007:80 $REPOSITORY
        '''
    }
}

    //阶段5:  获取站 站站点  的 的状态  
//stage('Test the WebSite') {
//    node {
//        sh '''
//        curl -I -m 10 -o /dev/null -s -w %{http_code} 202.205.161.114:8001
//        '''
//    }
//}

    
stage('Deploying To The Production Server'){
    timeout(time: 1, unit: 'DAYS') {
    input message: 'Deploying To The Production Server?', ok: 'Deployment'
    }
}



 
    //阶段8:部署到生产环境服务器，||true 短路逻辑运算，只有前面返回假echo $? =1 时，后面才执行

stage('Deploy To The Production Docker Server') {
//      方式1
//    node {
//        sh '''
//        ssh root@202.205.161.131 "cd /home/docker/003.CourseDetectionWeb ; sh docker_CourseDetectionSystem.start.sh"
//        '''
//    }

      //方式2
    node('Robot') { 
        sh '''
        cd /mnt/Docker/002.Robot
        REPOSITORY=harbor.nercoa.com/robot/robot:${ImageTag}
        docker rm -f Robot || true
        docker container run -d \
        --volume /etc/localtime:/etc/localtime:ro \
        --volume `pwd`/Config:/app/Config \
        --restart always \
        --user root \
        --name Robot \
        -h Robot \
        -p 8090:80 \
        $REPOSITORY
        '''
  }
}
*/
```

