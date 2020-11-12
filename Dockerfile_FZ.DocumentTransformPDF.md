/*  LiberOffice由于网络问题下载不下来
 *  MAINTAINER WinJayX <WinJayX@Gmail.com>
 *  LABEL description="This is DotNetCore2.2 Project"
 *  LABEL version="1.0"
 */
 
 //变量 branch 在参数化构建中添加
 
    //阶段1：拉取代码，node 节点未指定，则在Master执行，因为Git、Maven 环境都在 Master,所以就在主节点执行了
stage('SVN Checkout') {
    node('MSBuild') {
       checkout([$class: 'GitSCM', branches: [[name: 'release/1.0']], doGenerateSubmoduleConfigurations: false, extensions: [], submoduleCfg: [], userRemoteConfigs: [[credentialsId: '973c9a08-4d62-4f8a-8792-7a214b7ffe66', url: 'http://git.nercoa.com/all/FZ.Common.git']]])
    }
}

    //阶段2：Dotnet编译代码
stage('Build'){
    node('MSBuild') {
       echo '编译解决方案'
       bat "$DOTNET publish  -c Release -o \"${WORKSPACE}/publish\" \"src/FZ.DocumentTransform/FZ.DocumentTransform\" "
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
    node('LinuxDocker_114') {
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
    node('LinuxDocker_114') { 
sh '''
REPOSITORY=harbor.nercoa.com/docs2pdf/docs2pdf:${imagetag}
cat > Dockerfile << EOF
#注意选择镜像镜像版 
FROM centos:7.8.2003
MAINTAINER WinJayX <WinJayX@Gmail.com>
LABEL description="This is Office Files to PDF Project"
LABEL version="1.1"
USER root


RUN yum install java -y \
    && yum groupinstall "Fonts" -y  \
    && yum groupinstall "Input Methods" -y \
    && rm -rf /etc/localtime \
    && ln -s /usr/share/zoneinfo/Asia/Shanghai /etc/localtime \
    && yum -y install kde-l10n-Chinese freetype.x86_64 freetype-devel.x86_64 \
              libXinerama.x86_64 libXinerama-devel.x86_64 \
    && yum -y reinstall glibc-common && localedef -c -f UTF-8 -i zh_CN zh_CN.utf8 \

RUN curl -O https://mirrors.nju.edu.cn/tdf/libreoffice/stable/7.0.3/rpm/x86_64/LibreOffice_7.0.3_Linux_x86-64_rpm.tar.gz \
    && tar -xzvf LibreOffice_7.0.3_Linux_x86-64_rpm.tar.gz \
    && rpm -ivh LibreOffice_7.0.3.1_Linux_x86-64_rpm/RPMS/* \
    && rm -rf LibreOffice_7.0.3* && rm -rf /opt/libreoffice7.0/help \
    && ln -s /usr/bin/libreoffice7.0 /usr/bin/libreoffice


RUN rpm -Uvh https://packages.microsoft.com/config/centos/7/packages-microsoft-prod.rpm \
    && yum install aspnetcore-runtime-3.1 \
    && yum clean all



WORKDIR /app

#将当前目录下的文件，复制到WORKDIR目录,适用于打包整个项目及DockerFile在一个包中的情况。
#如果有创建数据卷则需要运行时src=VolumeName,dst=/app挂载。
COPY . /app/

#项目变更时，注意修改.dll文件名称
ENTRYPOINT ["dotnet", "FZ.DocumentTransform.dll","--urls","http://0.0.0.0:80"]

EOF

docker build -t $REPOSITORY .
docker login harbor.nercoa.com -u admin -p Nerc.nerc/1
docker push $REPOSITORY
'''
    }
}

    //阶段4：部署到远程Node Docker主机节点
stage('Deploy To The Test Server') {
    node('LinuxDocker_114') { 
        sh '''
        REPOSITORY=harbor.nercoa.com/docs2pdf/docs2pdf:${imagetag}
        docker rm -f Docstrans || true
        docker container run -d \
        --volume /etc/localtime:/etc/localtime:ro \
        --restart always \
        --user root \
        --name Docstrans \
        --hostname Docstrans \
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
    node('DocsTopdf') { 
        sh '''
        cd /mnt/Docker/002.Robot
        REPOSITORY=harbor.nercoa.com/docs2pdf/docs2pdf:${imagetag}
        docker rm -f Docstrans || true
        docker container run -d \
        --volume /etc/localtime:/etc/localtime:ro \
        --restart always \
        --user root \
        --name Docstrans \
        -h Docstrans \
        -p 8090:80 \
        $REPOSITORY
        '''
  }
}