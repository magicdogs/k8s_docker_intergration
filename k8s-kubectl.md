Pause容器的坑
Kubernetes为每个Pod都附属于Pause容器，这个容器接管Pod的网络信息，业务容器通过加入网络容器的网络来实现网络共享。此容器随着pod创建而创建，随着Pod删除而删除。

当k8s创建RC的时候，docker会自动去拉取pause容器，但是由于被墙的原因，查看日志的时候会看到pod一直是pulling的状态。

sudo systemctl status docker.service


ReplicationController web-tools-rc.yaml 描述副本信息
创建RC
sudo kubectl create -f web-tools-rc.yaml

查看创建的RC：
sudo kubectl get rc

查看创建的pod：
sudo kubectl get pods

可以查看Pod的启动状态。
查看Pod的启动日志
sudo kubectl describe pod web-tools-****

查看单个pod的日志：
sudo kubectl logs [-f] helloworld-7jpm5

Service web-tools-svc.yaml 服务描述信息
创建Service
sudo kubectl create -f web-tools-svc.yaml


注意，文件里面的nodePort是8008。
创建Service后，这样就可以访问之前创建的Pods了。
sudo kubectl create -f web-tools-svc.yaml
查看创建的结果：
sudo kubectl get services
这样Service就可以访问了，并映射到8008端口。

删除资源
kubectl delete rc[,service][,pod] [rc|service|pod]name





root@ubuntu:~/dockerfile# docker images
REPOSITORY                                            TAG                 IMAGE ID            CREATED             SIZE
registry.cn-shenzhen.aliyuncs.com/symagic/web-tools   1.0.0               685e6aa0f666        7 hours ago         801MB
ubuntu                                                16.04               7aa3602ab41e        2 weeks ago         115MB
k8s.gcr.io/pause                                      3.1                 da86e6ba6ca1        7 months ago        742kB
mirrorgooglecontainers/pause-amd64                    3.1                 da86e6ba6ca1        7 months ago        742kB
k8s.gcr.io/pause-amd64                                3.1                 da86e6ba6ca1        7 months ago        742kB
root@ubuntu:~/dockerfile# 


docker pull mirrorgooglecontainers/pause-amd64:3.1
docker tag mirrorgooglecontainers/pause-amd64:3.1 k8s.gcr.io/pause:3.1
docker pull registry.cn-shenzhen.aliyuncs.com/symagic/web-tools:1.0.0



root@ubuntu:~/dockerfile# kubectl delete service web-tools
service "web-tools" deleted

root@ubuntu:~/dockerfile# kubectl delete rc web-tools
replicationcontroller "web-tools" deleted


root@ubuntu:~/dockerfile# kubectl get rc
No resources found.
root@ubuntu:~/dockerfile# kubectl get pod
No resources found.
root@ubuntu:~/dockerfile# kubectl get service
NAME         TYPE        CLUSTER-IP    EXTERNAL-IP   PORT(S)   AGE
kubernetes   ClusterIP   170.170.0.1   <none>        443/TCP   2d
root@ubuntu:~/dockerfile# 


root@ubuntu:~/dockerfile# ll
total 44212
drwxr-xr-x 2 root root     4096 Aug 15 04:26 ./
drwx------ 8 root root     4096 Aug 15 04:26 ../
-rw-r--r-- 1 root root      220 Aug 14 03:19 Dockerfile
-rw-r--r-- 1 root root 45251470 Aug 14 03:05 web-tools-1.0.0-SNAPSHOT.jar
-rw-r--r-- 1 root root      381 Aug 15 04:23 web-tools-rc.yaml
-rw-r--r-- 1 root root      185 Aug 15 04:26 web-tools-svc.yaml


root@ubuntu:~/dockerfile# kubectl create -f web-tools-rc.yaml 
replicationcontroller/web-tools created

root@ubuntu:~/dockerfile# kubectl get rc
NAME        DESIRED   CURRENT   READY     AGE
web-tools   3         3         3         12s

root@ubuntu:~/dockerfile# kubectl get pod
NAME              READY     STATUS    RESTARTS   AGE
web-tools-fgn6l   1/1       Running   0          21s
web-tools-lwhb5   1/1       Running   0          21s
web-tools-ssws8   1/1       Running   0          21s

root@ubuntu:~/dockerfile# kubectl describe pod web-tools-fgn6l
Name:           web-tools-fgn6l
Namespace:      default
Node:           ubuntu/192.168.150.236
Start Time:     Wed, 15 Aug 2018 04:44:24 -0400
Labels:         name=web-tools
Annotations:    <none>
Status:         Running
IP:             172.17.0.3
Controlled By:  ReplicationController/web-tools
Containers:
  web-tools:
    Container ID:   docker://21904500c160d4eac831692592599e3a740cd9ad19dede739558caf46ca5500f
    Image:          registry.cn-shenzhen.aliyuncs.com/symagic/web-tools:1.0.0
    Image ID:       docker-pullable://registry.cn-shenzhen.aliyuncs.com/symagic/web-tools@sha256:d57c136381bd1b2c805acad16a279db9b4ed48b4ab2e952d0862186aed144a8a
    Port:           8080/TCP
    Host Port:      0/TCP
    State:          Running
      Started:      Wed, 15 Aug 2018 04:44:25 -0400
    Ready:          True
    Restart Count:  0
    Environment:    <none>
    Mounts:         <none>
Conditions:
  Type              Status
  Initialized       True 
  Ready             True 
  ContainersReady   True 
  PodScheduled      True 
Volumes:            <none>
QoS Class:          BestEffort
Node-Selectors:     <none>
Tolerations:        <none>
Events:
  Type     Reason             Age               From               Message
  ----     ------             ----              ----               -------
  Normal   Scheduled          1m                default-scheduler  Successfully assigned default/web-tools-fgn6l to ubuntu
  Normal   Pulled             1m                kubelet, ubuntu    Container image "registry.cn-shenzhen.aliyuncs.com/symagic/web-tools:1.0.0" already present on machine
  Normal   Created            1m                kubelet, ubuntu    Created container
  Normal   Started            1m                kubelet, ubuntu    Started container
  Warning  MissingClusterDNS  10s (x6 over 1m)  kubelet, ubuntu    pod: "web-tools-fgn6l_default(6940ac4b-a067-11e8-b553-0800273b822e)". kubelet does not have ClusterDNS IP configured and cannot create Pod using "ClusterFirst" policy. Falling back to "Default" policy.
  
  
root@ubuntu:~/dockerfile# kubectl logs -f web-tools-fgn6l

  .   ____          _            __ _ _
 /\\ / ___'_ __ _ _(_)_ __  __ _ \ \ \ \
( ( )\___ | '_ | '_| | '_ \/ _` | \ \ \ \
 \\/  ___)| |_)| | | | | || (_| |  ) ) ) )
  '  |____| .__|_| |_|_| |_\__, | / / / /
 =========|_|==============|___/=/_/_/_/
 :: Spring Boot ::        (v2.0.4.RELEASE)

2018-08-15 08:44:33.985  INFO 1 --- [           main] com.web.tools.Application                : Starting Application on web-tools-fgn6l with PID 1 (/data/webapp/web-tools-1.0.0-SNAPSHOT.jar started by root in /)
2018-08-15 08:44:34.039  INFO 1 --- [           main] com.web.tools.Application                : No active profile set, falling back to default profiles: default
2018-08-15 08:44:34.751  INFO 1 --- [           main] ConfigServletWebServerApplicationContext : Refreshing org.springframework.boot.web.servlet.context.AnnotationConfigServletWebServerApplicationContext@60215eee: startup date [Wed Aug 15 08:44:34 UTC 2018]; root of context hierarchy
2018-08-15 08:44:48.268  INFO 1 --- [           main] o.s.b.w.embedded.tomcat.TomcatWebServer  : Tomcat initialized with port(s): 80 (http)
2018-08-15 08:44:48.583  INFO 1 --- [           main] o.apache.catalina.core.StandardService   : Starting service [Tomcat]
2018-08-15 08:44:48.588  INFO 1 --- [           main] org.apache.catalina.core.StandardEngine  : Starting Servlet Engine: Apache Tomcat/8.5.32
2018-08-15 08:44:48.680  INFO 1 --- [ost-startStop-1] o.a.catalina.core.AprLifecycleListener   : The APR based Apache Tomcat Native library which allows optimal performance in production environments was not found on the java.library.path: [/usr/java/packages/lib/amd64:/usr/lib64:/lib64:/lib:/usr/lib]
2018-08-15 08:44:49.410  INFO 1 --- [ost-startStop-1] o.a.c.c.C.[Tomcat].[localhost].[/]       : Initializing Spring embedded WebApplicationContext
2018-08-15 08:44:49.413  INFO 1 --- [ost-startStop-1] o.s.web.context.ContextLoader            : Root WebApplicationContext: initialization completed in 14665 ms
2018-08-15 08:44:50.060  INFO 1 --- [ost-startStop-1] o.s.b.w.servlet.ServletRegistrationBean  : Servlet dispatcherServlet mapped to [/]


