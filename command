 
 163: pull images
 
 save image
 docker save -o openjdk.tar openjdk
 
 pwd 找出當前目錄路徑
 
 scp  /home/ebookadm/docker-spring-boot.tar KateWu@172.20.3.177:/home/KateWu/docker-spring-boot.tar
 
 172.16.89.80
 
 
 177:  docker load -i oracle-jdk8.tar

 若要刪除檔案:
 mv 要搬移的檔案 目的地目錄
 進到目錄內 rm -r 檔名 或 rm 檔名
 刪除資料夾:rm -rf 資料夾名 不用加docker
  scp  /home/ebookadm/centos.tar KateWu@172.20.3.177:/home/KateWu/centos.tar
  scp  /home/ebookadm/oracle-jdk8.tar KateWu@172.20.3.177:/home/KateWu/oracle-jdk8.tar


執行image 啟動容器 
docker run -it spring-boot-docker /bin/bash


進入容器內
docker exec -it d2205cc22eee /bin/bash

建立dockerfile
vi dockerfile
按i 開始編輯 編輯結束Esc   :wq儲存並離開   :q是離開

build image
docker build -t spring-boot . -f dockerfile
docker run -p 2838:8080 -t spring-boot1

passwd 更改密碼





163:
pull 別人弄好的image環境 frolvlad/alpine-oraclejdk8:slim
docker save -o oracle-jdk8.tar frolvlad/alpine-oraclejdk8
scp  /home/ebookadm/oracle-jdk8.tar KateWu@172.20.3.177:/home/KateWu/oracle-jdk8.tar

173:
docker load -i oracle-jdk8.tar
查看images 有沒有 frolvlad/alpine-oraclejdk8:slim
打開dockerfile 看From 是不是frolvlad/alpine-oraclejdk8:slim



建Dockerfile  : vi Dockerfile (按i 開始編輯 , ESC + :WQ 儲存並離開)
FROM frolvlad/alpine-oraclejdk8:slim
VOLUME /tmp
ADD myBookStore.jar app.jar
#RUN bash -c 'touch /app.jar'
ENTRYPOINT ["java","-Djava.security.egd=file:/dev/./urandom","-Dspring.profiles.active=uat","-jar","/app.jar"]





Embedeed Tomcat 是run 8081 port 
docker run -p 2893:8081 -t spring-boot2 


http://172.20.3.177:2893/book
