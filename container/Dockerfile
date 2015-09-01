# This is a comment
FROM ubuntu:14.04
MAINTAINER Nitai Aventaggiato <nitai@razuna.com>

# ADD MULTIVERSE
RUN echo "deb http://archive.ubuntu.com/ubuntu/ trusty multiverse" >> /etc/apt/sources.list
RUN echo "deb-src http://archive.ubuntu.com/ubuntu/ trusty multiverse" >> /etc/apt/sources.list
RUN echo "deb http://archive.ubuntu.com/ubuntu/ trusty-updates multiverse" >> /etc/apt/sources.list
RUN echo "deb-src http://archive.ubuntu.com/ubuntu/ trusty-updates multiverse" >> /etc/apt/sources.list

# For MySQL
# RUN groupadd -r mysql && useradd -r -g mysql mysql
# RUN echo mysql-server mysql-server/root_password password razuna | /usr/bin/debconf-set-selections
# RUN echo mysql-server mysql-server/root_password_again password razuna | /usr/bin/debconf-set-selections

# SET ENV NONINTERACTIVE
ENV DEBIAN_FRONTEND noninteractive

# Update
RUN apt-get update

# INSTALL
RUN apt-get install -y software-properties-common
RUN apt-get install -y python-software-properties

# GIT
RUN apt-get install -y git

# MEMCACHED
RUN apt-get -y install memcached

# MYSQL
# RUN apt-get -y install mysql-server

# IMAGEMAGICK
RUN apt-get -y install imagemagick

# DCRAW / UFRAW
RUN apt-get -y install dcraw
RUN apt-get -y install ufraw

# MP4BOX
RUN apt-get -y install gpac

# SSH
ADD install-ssh /tmp/install-ssh
RUN /tmp/install-ssh

# JAVA 7
ADD install-java /tmp/install-java
RUN /tmp/install-java

# FFMPEG
ADD install-ffmpeg /tmp/install-ffmpeg
RUN /tmp/install-ffmpeg

# EXIFTOOL
ADD install-exiftool /tmp/install-exiftool
RUN /tmp/install-exiftool

# GHOSTSCRIPT
ADD install-ghostscript /tmp/install-ghostscript
RUN /tmp/install-ghostscript

# TOMCAT
ADD install-tomcat /tmp/install-tomcat
RUN /tmp/install-tomcat

# CONFIGURE UBUNTU WITH OUR CONFIG FILES
COPY setenv.sh /opt/tomcat/bin/setenv.sh
COPY permgen.sh /opt/tomcat/bin/permgen.sh
COPY tomcat /etc/init.d/tomcat
COPY razuna-server.xml /opt/tomcat/conf/server.xml
COPY start.sh /opt/start.sh

# SET TOMCAT TO START ON REBOOT
RUN update-rc.d tomcat defaults

# SET PERMISSIONS
RUN chmod +x /opt/tomcat/bin/setenv.sh
RUN chmod +x /opt/tomcat/bin/permgen.sh
RUN chmod +x /etc/init.d/tomcat
RUN chmod +x /opt/start.sh

# CLEAN UP TASKS
RUN apt-get -y autoclean && apt-get -y autoremove
RUN rm -r /tmp/*
RUN rm /opt/*.gz
RUN rm /opt/*.tgz

# START SERVICES
EXPOSE 8080 22
CMD /opt/start.sh

