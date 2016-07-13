# Dockerfile
# Dockerfile
FROM centos:centos6
RUN yum install -y epel-release
RUN curl --silent --location https://rpm.nodesource.com/setup_4.x | bash -
RUN yum install -y nodejs
RUN npm install npm -g
RUN npm install -g coffee-script
RUN mv /etc/localtime /etc/localtime.bak
RUN cp /usr/share/zoneinfo/Asia/Taipei /etc/localtime
COPY . ibeAccountEtl
WORKDIR ibeAccountEtl
CMD ["/bin/sh", "-c", "npm start"]