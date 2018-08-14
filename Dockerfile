FROM n3ziniuka5/ubuntu-oracle-jdk
MAINTAINER symagic "80099856@qq.com"
RUN mkdir -p /data/webapp
COPY web-tools-1.0.0-SNAPSHOT.jar /data/webapp/
EXPOSE 80
CMD ["java","-jar","/data/webapp/web-tools-1.0.0-SNAPSHOT.jar"]