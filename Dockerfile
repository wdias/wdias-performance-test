FROM openjdk:8-jre-slim
ARG JMETER_VERSION

ENV JMETER_VERSION ${JMETER_VERSION:-5.0}
ENV JMETER_HOME /jmeter/apache-jmeter-$JMETER_VERSION/
ENV PATH $JMETER_HOME/bin:$PATH

# INSTALL PRE-REQ
RUN apt-get update && \
    apt-get -y install \
    wget  unzip httpie bash

# INSTALL JMETER BASE 
RUN mkdir /jmeter
WORKDIR /jmeter

RUN wget https://archive.apache.org/dist/jmeter/binaries/apache-jmeter-$JMETER_VERSION.tgz && \
    tar -xzf apache-jmeter-$JMETER_VERSION.tgz && \
    rm apache-jmeter-$JMETER_VERSION.tgz
    # mkdir /jmeter-plugins && \
    # cd /jmeter-plugins/ && \
    # wget https://jmeter-plugins.org/downloads/file/JMeterPlugins-ExtrasLibs-1.4.0.zip && \
    # unzip -o JMeterPlugins-ExtrasLibs-1.4.0.zip -d /jmeter/apache-jmeter-$JMETER_VERSION

WORKDIR $JMETER_HOME 
EXPOSE 6000 1099 50000

COPY bin/user.properties bin/user.properties
COPY jmeter-scripts/install_plugin-manager.sh .
COPY jmeter-scripts/docker-entrypoint.sh /docker-entrypoint.sh

RUN chmod +x install_plugin-manager.sh /docker-entrypoint.sh
RUN ./install_plugin-manager.sh

COPY wdias_performance_test.jmx /jmeter/
# https://jmeter-plugins.org/wiki/PluginsManagerAutomated/
RUN bin/PluginsManagerCMD.sh install-for-jmx /jmeter/wdias_performance_test.jmx

WORKDIR /jmeter 
COPY . .

ENTRYPOINT ["/docker-entrypoint.sh"]
