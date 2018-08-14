# k8s_docker_intergration

前置条件，需要预先安装docker.io 和 docker-compose 组件。
download link https://kubernetes.io/docs/imported/release/notes/
  - kubernetes-server-linux-amd64.tar.gz版本是V1.10，包含KUBE-APISERVER,KUBE-CONTROLLER-MANAGER,KUBE-SCHEDULE
  - kubernetes-node-linux-amd64.tar.gz	版本是V1.10,   包含KUBELET,KUBE-PROXY,KUBECTL，需要先安装Docker
  - etcd-v3.3.9-linux-amd64.tar.gz	版本是V3.39，Kubernetes Master需要ETCD数据存储

# Docker version!
    root@ubuntu:~/kubernetes/node/bin# docker version
    Client:
     Version:      17.03.2-ce
     API version:  1.27
     Go version:   go1.6.2
     Git commit:   f5ec1e2
     Built:        Thu Jul  5 23:07:48 2018
     OS/Arch:      linux/amd64
    
    Server:
     Version:      17.03.2-ce
     API version:  1.27 (minimum version 1.12)
     Go version:   go1.6.2
     Git commit:   f5ec1e2
     Built:        Thu Jul  5 23:07:48 2018
     OS/Arch:      linux/amd64
     Experimental: false
    root@ubuntu:~/kubernetes/node/bin# 


# docker-compose version!
    root@ubuntu:/etc/kubernetes# docker-compose version
    docker-compose version 1.8.0, build unknown
    docker-py version: 1.9.0
    CPython version: 2.7.12
    OpenSSL version: OpenSSL 1.0.2g  1 Mar 2016
    
创建目录结构 mkdir -p     
目录结构:
  - /usr/lib/systemd/system/     #存放服务启动描述文件
  - /home/root/log/kubernetes/   #存放日志目录
  - /etc/kubernetes/             #存放对应服务的启动环境文件
  - /home/root/etcd/data/        #存放etcd的数据目录


        拷贝 k8s_service目录下的所有*.service 文件到/usr/lib/systemd/system/ 目录下
        拷贝 k8s_config目录下的所有文件到/etc/kubernetes/目录下


# 1.安装配置ETCD
        ETCD是用于共享配置和服务发现的分布式、一致性的KV存储系统，主要包括了增删改查、安全认证、集群、选举、事务、分布式锁、Watch机制等等，实现了RAFT协议，功能相当强大，coreos出品。

    解压etcd-v3.3.9-linux-amd64.tar.gz，把目录下的etcd和etcdctl复制到/usr/local/bin目下，

    然后在/usr/lib/systemd/system/目录下创建etcd.service,如果没有system这个目录，则创建就可以，首先创建ETCD的存储的目录地址/home/root/etcd/data，然后创建ETCD的配置文件目录/etc/etcd/,因为我们用的ETCD默认配置，所以/etc/etcd/etcd.conf空文件即可。

    sudo systemctl daemon-reload    
    sudo systemctl enable etcd.service
    sudo systemctl start etcd.service
    sudo systemctl status etcd.service
    
    export ETCDCTL_API=3
    sudo ectdctl put hello "world"
    sudo ectdctl get hello

### 一、安装配置k8s的MASTER

### 2.API SERVER是整个k8s集群的注册中心、交通枢纽、安全控制入口。
        解压kubernetes-server-linux-amd64.tar.gz 文件，拷贝kube-apiserver到/usr/local/bin/目录下。
    然后在/usr/lib/systemd/system/目录下创建kube-apiserver.service
    在/etc/kubernetes/目录下创建apiserver配置文件。
        API SERVER有三种认证方式：基本认证、Token认证、CA认证，很明显，这个配置没有任何认证信息，不建议在生产环境中使用，但是为了快速搭建环境，此次先跳过这个步骤。
    
    所有配置都弄好后，执行以下命令
    sudo systemctl daemon-reload
    sudo systemctl enable kube-apiserver.service
    sudo systemctl start kube-apiserver.service
    sudo systemctl status kube-apiserver.service
    curl http://localhost:8080/api/

### 3.安装配置kube-controller-manager
         Kube Controller Manager作为集群内部的管理控制中心,负责集群内的Node、Pod副本、服务端点（Endpoint）、命名空间（Namespace）、服务账号（ServiceAccount）、资源定额（ResourceQuota）的管理，当某个Node意外宕机时，Kube Controller Manager会及时发现并执行自动化修复流程，确保集群始终处于预期的工作状态。
    
        kube-controller-manager的运行脚本在kubernetes-server-linux-amd64.tar.gz 文件中，拷贝kube-controller-manager到/usr/local/bin/目录下。
        然后在/usr/lib/systemd/system/目录下创建kube-controller-manager.service
    在/etc/kubernetes/目录下创建controller-manager配置文件。
    
    sudo systemctl daemon-reload
    sudo systemctl enable kube-controller-manager.service
    sudo systemctl start kube-controller-manager.service
    sudo systemctl status kube-controller-manager.service
    
### 4.安装配置kube-scheduler
            Kube Scheduler是负责调度Pod到具体的Node，它通过API Server提供的接口监听Pods，获取待调度pod，然后根据一系列的预选策略和优选策略给各个Node节点打分排序，然后将Pod调度到得分最高的Node节点上。

        kube-scheduler的运行脚本在kubernetes-server-linux-amd64.tar.gz文件中，拷贝kube-scheduler到/usr/local/bin/目录下。
    然后在/usr/lib/systemd/system/目录下创建kube-scheduler.service
    在/etc/kubernetes/目录下创建scheduler配置文件。

    sudo systemctl daemon-reload
    sudo systemctl enable kube-scheduler.service
    sudo systemctl start kube-scheduler.service
    sudo systemctl status kube-scheduler.service


###### 这样kubernetes的Master节点就搭建完毕了，接下来搭建Node节点，Node节点还是在同样的虚拟机上搭建，一般要求是Master和Node在不同的服务器上，但是K8s官方网站上说master和node在同一台机器上完全是没问题，所以就在同一台服务器上弄就可以了。

#
#
# 二、安装配置NODE节点

安装node之前需要先安装docker，关于安装docker的教程可以查看官方文档，也可以查看我之前写的博客,地址是点击打开链接

### 1.安装配置kubelet
        在k8s集群中，每个Node节点都会启动kubelet进程，用来处理Master节点下发到本节点的任务，管理Pod和pod中的容器。kubelet会在API Server上注册节点信息，定期向Master汇报节点资源使用情况，并通过cAdvisor监控容器和节点资源。
    解压kubernetes-node-linux-amd64.tar.gz 文件，拷贝kubelet到/usr/local/bin/目录下。
    
    然后在/usr/lib/systemd/system/目录下创建kubelet.service
    在/etc/kubernetes/目录下创建配置文件，包括kubelet和kubelet.yaml。
    
    
    sudo systemctl daemon-reload
    sudo systemctl enable kubelet.service
    sudo systemctl start kubelet.service
    sudo systemctl status kubelet.service

### 2.安装配置kube-proxy
        kube-proxy是管理service的访问入口，包括集群内Pod到Service的访问和集群外访问service。关于service和pod的概念可以自行网上查看。
    解压kubernetes-node-linux-amd64.tar.gz 文件，拷贝kube-proxy到/usr/local/bin/目录下。
    然后在/usr/lib/systemd/system/目录下创建kube-proxy.service
    在/etc/kubernetes/目录下创建proxy配置文件。
    
    sudo systemctl daemon-reload
    sudo systemctl enable kube-proxy.service
    sudo systemctl start kube-proxy.service
    sudo systemctl status kube-proxy.service

##### 最后把kubectl复制到/usr/local/bin目录下
