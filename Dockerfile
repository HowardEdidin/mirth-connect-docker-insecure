FROM openjdk:11-jre-slim

RUN apt-get update --no-install-recommends \
  && apt-get install -y --no-install-recommends ca-certificates wget \
  && apt-get -y install gettext-base iputils-ping iputils-telnet nano \
  && apt-get clean \
  && rm -rf /var/lib/apt/lists/* \
  && update-ca-certificates

VOLUME /opt/mirth-connect/appdata

ARG MIRTH_CONNECT_VERSION=3.7.1.b243
ARG FHIR_CONNECTOR_VERSION=3.7.1
ARG FHIR_CONNECTOR_BUILD=b258

WORKDIR /tmp

# Download Mirth and the FHIR connector
RUN \
  wget http://downloads.mirthcorp.com/connect/$MIRTH_CONNECT_VERSION/mirthconnect-$MIRTH_CONNECT_VERSION-unix.tar.gz && \
  wget http://downloads.mirthcorp.com/fhir/$FHIR_CONNECTOR_VERSION/fhir-$FHIR_CONNECTOR_VERSION.$FHIR_CONNECTOR_BUILD.zip

WORKDIR /opt/mirth-connect/

# Extract Mirth and remove the tarball file
RUN \
  tar xvzf /tmp/mirthconnect-$MIRTH_CONNECT_VERSION-unix.tar.gz --strip-components=1  && \
  rm -f /tmp/mirthconnect-$MIRTH_CONNECT_VERSION-unix.tar.gz

WORKDIR /opt/mirth-connect/extensions

# Extract the FHIR connector and remove the zip file
RUN \
  unzip /tmp/fhir-$FHIR_CONNECTOR_VERSION.$FHIR_CONNECTOR_BUILD.zip && \
  rm -f /tmp/fhir-$FHIR_CONNECTOR_VERSION.$FHIR_CONNECTOR_BUILD.zip

# Switch to the Mirth root directory
WORKDIR /opt/mirth-connect

EXPOSE 8080 8443

COPY docker-entrypoint.sh /
COPY mirth.properties_env /opt/mirth-connect/conf/

ENTRYPOINT ["/docker-entrypoint.sh"]

CMD ["java", "-jar", "mirth-server-launcher.jar"]
