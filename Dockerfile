# Generated by IBM TransformationAdvisor
# Sun Nov 01 02:59:30 UTC 2020


FROM adoptopenjdk/openjdk8-openj9 AS build-stage

RUN apt-get update && \
    apt-get install -y maven unzip

COPY . /project
WORKDIR /project

#RUN mvn -X initialize process-resources verify => to get dependencies from maven
#RUN mvn clean package	
#RUN mvn --version
RUN mvn --version

RUN mkdir -p /config/apps && \
    mkdir -p /sharedlibs && \
    cp ./src/main/liberty/config/server.xml /config && \
    cp ./target/*.*ar /config/apps/ && \
    if [ ! -z "$(ls ./src/main/liberty/lib)" ]; then \
    cp ./src/main/liberty/lib/* /sharedlibs; \
    fi

FROM open-liberty:kernel-java8-openj9

ARG SSL=false

ARG MP_MONITORING=false
ARG HTTP_ENDPOINT=false

RUN mkdir -p /opt/ol/wlp/usr/shared/config/lib/global
COPY --chown=1001:0 .src/main/liberty/config/server.xml /config/server.xml
COPY --chown=1001:0 --from=build-stage /config/ /config/
COPY --chown=1001:0 --from=build-stage /sharedlibs/ /opt/ol/wlp/usr/shared/config/lib/global

USER root
RUN configure.sh
USER 1001

# Upgrade to production license if URL to JAR provided
ARG LICENSE_JAR_URL
RUN \
    if [ $LICENSE_JAR_URL ]; then \
    wget $LICENSE_JAR_URL -O /tmp/license.jar \
    && java -jar /tmp/license.jar -acceptLicense /opt/ibm \
    && rm /tmp/license.jar; \
    fi