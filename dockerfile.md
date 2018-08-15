Dockerfile由一系列的指令和参数组成。每条指令，如FROM，都必须大写，并且后面跟随参数。Dockerfile中的指令按顺序从上往下执行。

Docker从基础镜像ubuntu运行一个容器，执行一条指令并修改容器
提交一个新的镜像层，基于此镜像层在运行一个新的容器
执行Dockerfile中的下一条指令，直到所有指令都执行完毕
当镜像构建完成后，能看到Docker删除了很多临时的容器。

RUN指令
默认情况下，RUN指令会在shell里使用命令包装器/bin/sh -c 来执行。也可以用exec格式的RUN指令，比如

RUN ["mkdir","-p","/data/jdk"]
ADD指令
ADD指令用来构建环境下的文件和目录复制到镜像中，它和COPY有些不一样，能看到Dockerfile中的JDK是一个gzip包，它能在复制的同时进行解压，合法的文件格式有gzip、bzip2、xz源文件，同时还迟滞通过URL的方式下载后在复制到指定的目录。

COPY指令
copy指令非常类似ADD，他们根本的不同是COPY只关心在构建上下文复制本地文件，而不会做提取和解压文件。

ENV指令
ENV指令用来在镜像构建过程中设置环境变量，如Dockerfile中的

ENV JAVA_HOME /data/jdk/jdk1.8.0_112
ENV PATH $PATH:$JAVA_HOME/bin
实际上就是设置了JAVA_HOME，在springboot启动的时候就会能读取到jdk的运行时环境。

EXPOSE指令
这条指令告诉Docker该容器内的应用程序将会使用容器指定端口。但是这并不意味可以自动访问该端口，而是需要在docker run时指定映射的端口，类似于

docker run -d -p 8080:8080 --name web-tools symagic/web-tools
如果不指定-p 8080:8080，实际上你通过端口8080端口是访问不到的。

CMD指令
CMD指令用于指定一个容器启动时要运行的命令，有点类似于RUN指令，只是RUN指令是构建镜像的时要运行的指令，CMD是镜像构建后要运行的指令。

构建镜像
在/data/dockerfile目录下，有以下文件



然后执行

sudo docker build -t="syamgic/web-tools" .
这样镜像就完成了。

推送镜像
syamgic是dockerhub上我注册的ID，就是Repository，web-tools是镜像名称，注册后可以使用

sudo docker login
输入用户名密码后登陆并把镜像推到自己的仓库中，实际上也可以建立自己的私有仓库，这个在一些生产环境中有应用场景。

sudo docker push syamgic/web-tools
这样就把镜像推送到Dockerhub上了，如果你现在在另外一台服务器上也想运行该镜像，那么只要简单的执行以下步骤就可以

sudo docker pull syamgic/web-tools
等镜像拉取下来后，执行docker run就可以了。