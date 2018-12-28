# Docker file to build an image with ubuntu 18.04 as OS, with Java 11 and Tomcat 8.5.37
# Process is divided into two parts
#   1. Setup Ubuntu, Java, Tomcat
#   2. Deploy sample app in Tomcat server

# ----------------PART 1: SETUP---------------------
# From base image ubuntu 18.04
FROM ubuntu:18.04

# OPTIONAL: Set auther of Docker file
LABEL "Maintainer"="https://github.com/sanjay-namdeo/"

# Synchronize package index files with their sources and install updates to all packages
# -y option automatic yes to all prompts
RUN apt-get update && apt-get -y upgrade

# Install software-properties-common, 
# It allows you to easily manage your distribution and independent software vendor software sources.
# Without it, you would need to add and remove repositories (such as PPAs) manually by editing /etc/apt/sources.list and/or any subsidiary files in /etc/apt/sources.list.d
RUN apt-get -y install software-properties-common

# Install curl, wget and vim
RUN apt-get -y install curl wget vim

# Install Java 11
RUN cd /opt; \
    wget --no-check-certificate -c --header "Cookie: oraclelicense=accept-securebackup-cookie" https://download.oracle.com/otn-pub/java/jdk/11.0.1+13/90cf5d8f270a4347a95050320eef3fb7/jdk-11.0.1_linux-x64_bin.tar.gz \
    && tar zxf jdk-11.0.1_linux-x64_bin.tar.gz \
    && ln -s jdk-11 java \
    && rm -f jdk-11.0.1_linux-x64_bin.tar.gz

# Set environment path
ENV JAVA_HOME=/opt/jdk-11.0.1
ENV PATH="$PATH:$JAVA_HOME/bin"

# Set TOMCAT_VERSION as environment path
ENV TOMCAT_VERSION 8.5.37

# Download tomcat-8.5.37 which will be in tax.gz
# Unzil tar file inside /opt directory
# Move all tomcat contents from /opt/apache-tomcat-8.5.37 to /opt/tomcat
# Remove zip file as it is not required now
# Remove example folder, as it is not required
# Remove docs folder, as it is not required
# Remove ROOT folder, as it is not required
RUN wget --quiet --no-cookies http://apache.rediris.es/tomcat/tomcat-8/v${TOMCAT_VERSION}/bin/apache-tomcat-${TOMCAT_VERSION}.tar.gz -O /tmp/tomcat.tgz \
    && tar xzvf /tmp/tomcat.tgz -C /opt \
    && mv /opt/apache-tomcat-${TOMCAT_VERSION} /opt/tomcat \
    && rm /tmp/tomcat.tgz \
    && rm -rf /opt/tomcat/webapps/examples \
    && rm -rf /opt/tomcat/webapps/docs \
    && rm -rf /opt/tomcat/webapps/ROOT

# ----------------PART 2: DEPLOYMENT---------------------
# Deploy sample war file to tomcat
COPY /sample-app/ /opt/tomcat/webapps/sample-app/

# Set enviornment paths
ENV CATALINA_HOME /opt/tomcat
ENV PATH $PATH:$CATALINA_HOME/bin
ENV JAVA_OPTS="-Xms1024m -Xmx1024m -Xss8192k -XX:CMSInitiatingOccupancyFraction=50 -XX:+ExplicitGCInvokesConcurrent -XX:+CMSClassUnloadingEnabled -XX:NewRatio=1 -XX:SurvivorRatio=1  -Dorg.apache.cxf.JDKBugHacks.imageIO=false"

# War file and logs can be mounted from host to container using VOLUME. Contents in these directories are not included in images.
# The volumns can be shared by multiple containers.
# VOLUME "/opt/tomcat/webapps"
# VOLUME "/opt/tomcat/logs"

# Export port 8080 to host machine
EXPOSE 8080

# Launch tomcat
CMD [ "/opt/tomcat/bin/catalina.sh", "run" ]