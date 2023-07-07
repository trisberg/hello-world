FROM ubuntu:22.04

WORKDIR /home/app

USER root

ENV JAVA_HOME /azul-crac-jdk
ENV PATH $PATH:$JAVA_HOME/bin

# Add required libraries
RUN apt-get update && apt-get install -y \
        curl \
        libnl-3-200 \
    && rm -rf /var/lib/apt/lists/*

# Add CRaC JDK
RUN mkdir $JAVA_HOME \
  && curl https://cdn.azul.com/zulu/bin/zulu17.42.21-ca-crac-jdk17.0.7-linux_x64.tar.gz | tar -xz --strip-components 1 -C $JAVA_HOME

# Add App
COPY target/hello-world-0.0.1-SNAPSHOT.jar /home/app/hello-world.jar
COPY src/scripts/entrypoint.sh /opt/app/entrypoint.sh

ENTRYPOINT /opt/app/entrypoint.sh
