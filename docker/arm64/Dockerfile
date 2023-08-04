FROM ubuntu:22.04

USER root

# Add required libraries
RUN apt-get update && apt-get install -y \
        curl \
        libnl-3-200 \
    && rm -rf /var/lib/apt/lists/*

# Set ENV
ENV JAVA_HOME /azul-crac-jdk
ENV PATH $PATH:$JAVA_HOME/bin

# Add CRaC JDK
RUN mkdir $JAVA_HOME \
  && curl https://cdn.azul.com/zulu/bin/zulu17.44.17-ca-crac-jdk17.0.8-linux_aarch64.tar.gz | tar -xz --strip-components 1 -C $JAVA_HOME
WORKDIR /home/app

# Add App
COPY target/hello-world-*.jar /home/app/hello-world.jar
COPY docker/arm64/entrypoint.sh /opt/app/entrypoint.sh
RUN jar -xf hello-world.jar
RUN rm hello-world.jar

CMD ["/opt/app/entrypoint.sh"]
