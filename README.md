## tomcat-docker-github-automation

- It generates an image built on Ubuntu 18.04 and installs
  - Tomcat 8
  - Java 11 with JAVA_HOME configured
- Then it deploys [tomcat sample app](https://tomcat.apache.org/tomcat-5.5-doc/appdev/sample/sample.war) in tomcat 8 server.
- Docker file is divided into two parts
  - Setup
  - Deployment
- On each git push, a new image build is triggered in [Docker hub](https://cloud.docker.com/repository/docker/sanjaynamdeo/tomcat-docker-github-automation/general)

### Steps to pull image and run the sample-app on tomcat 8

1. Pull the deployment image from [Docker hub](https://cloud.docker.com/repository/docker/sanjaynamdeo/ubuntu18.04-tomcat8-jdk8/general)

   `docker pull sanjaynamdeo/tomcat-docker-github-automation:latest`

2. Get the image repository and version
   `docker images`

3. Spwan a container and map its 8080 port to any available port on your server or local machine
   `docker run -itd --name tomcat-container -p <port>:8080 <repository-name>:latest`
   With volumns external volume mounted for webapps and logs directory(Before using this option, please uncomment VOLUME commands in Dockerfile)
   `docker run -itd --name tomcat-container -v C:/tomcat/logs:/opt/tomcat/logs -v C:/tomcat/webapps:/opt/tomcat/webapps -p <port>:8080 <repository-name>:latest`

4. Test application on localhost
   `http://localhost:<port_number>/sample-app/`

### Setup steps description

1. Use base image ubuntu 18.04 for underlying OS
   `FROM ubuntu:18.04`

2. OPTIONAL: Set auther of the docker file
   `LABEL "Maintainer"="https://github.com/sanjay-namdeo/"`

3. Synchronize package index files with their sources and install updates to all packages. '-y' option automatic yes to all prompts
   `RUN apt-get -y update && apt-get -y upgrade`

4. Install software-properties-common which allows you to easily manage your distribution and independent software vendor software sources. Without it, you would need to add and remove repositories (such as PPAs) manually by editing /etc/apt/sources.list and/or any subsidiary files in /etc/apt/sources.list.d
   `RUN apt-get -y install software-properties-common`

5. Install curl, wget and vim
   `RUN apt-get -y install curl wget vim`

6. Install Java 11

   ```RUN cd /opt; \
   wget --no-check-certificate -c --header "Cookie: oraclelicense=accept-securebackup-cookie" https://download.oracle.com/otn-pub/java/jdk/11.0.1+13/90cf5d8f270a4347a95050320eef3fb7/jdk-11.0.1_linux-x64_bin.tar.gz \
   && tar zxf jdk-11.0.1_linux-x64_bin.tar.gz \
   && ln -s jdk-11 java \
   && rm -f jdk-11.0.1_linux-x64_bin.tar.gz```

   ````

7. Set JAVA_HOME
   `ENV JAVA_HOME=/opt/jdk-11.0.1`

8. Add JAVA_HOME to PATH
   `ENV PATH="$PATH:$JAVA_HOME/bin"`

9. Set TOMCAT_VERSION as environment path
   `ENV TOMCAT_VERSION 8.5.37`

10. Following are done in this step:

    - Download tomcat-8.5.37 which will be in tax.gz.
    - Unzil tar file inside /opt directory
    - Move all tomcat contents from /opt/apache-tomcat-8.5.37 to /opt/tomcat
    - Remove zip file as it is not required now
    - Remove example folder, as it is not required
    - Remove docs folder, as it is not required
    - Remove ROOT folder, as it is not required

    ````RUN wget --quiet --no-cookies http://apache.rediris.es/tomcat/tomcat-8/v${TOMCAT_VERSION}/bin/apache-tomcat-${TOMCAT_VERSION}.tar.gz -O /tmp/tomcat.tgz \
        && tar xzvf /tmp/tomcat.tgz -C /opt \
        && mv /opt/apache-tomcat-${TOMCAT_VERSION} /opt/tomcat \
        && rm /tmp/tomcat.tgz \
        && rm -rf /opt/tomcat/webapps/examples \
        && rm -rf /opt/tomcat/webapps/docs \
        && rm -rf /opt/tomcat/webapps/ROOT```

    ````

11. Deploy sample app to tomcat
    `COPY /sample-app/ /opt/tomcat/webapps/sample-app/`

12. Set enviornment paths
    `ENV CATALINA_HOME /opt/tomcat`

`ENV PATH $PATH:$CATALINA_HOME/bin`

`ENV JAVA_OPTS="-Xms1024m -Xmx1024m -Xss8192k -XX:CMSInitiatingOccupancyFraction=50 -XX:+ExplicitGCInvokesConcurrent -XX:+CMSClassUnloadingEnabled -XX:NewRatio=1 -XX:SurvivorRatio=1 -Dorg.apache.cxf.JDKBugHacks.imageIO=false"`

4. Export port 8080 to host machine
   `EXPOSE 8080`

5. Launch tomcat
   `CMD [ "/opt/tomcat/bin/catalina.sh", "run" ]`

6. Test application on localhost:
   `http://localhost:8080:/sample-app/`
