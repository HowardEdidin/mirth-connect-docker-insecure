FROM openjdk:11-jre-slim

RUN apt-get update \
	&& apt-get install -y --no-install-recommends ca-certificates wget \
	&& apt-get -y install gettext-base \
	&& apt-get clean \
  	&& rm -rf /var/lib/apt/lists/* \
	&& update-ca-certificates

# Mirth Connect is run with user `mirth`, uid = 1000
RUN groupadd -g 1000 mirth && \
    useradd -r -u 1000 -g mirth mirth && \
	mkdir -p /opt/mirth-connect/appdata && \
	chown -R mirth:mirth /opt/mirth-connect
USER mirth

VOLUME /opt/mirth-connect/appdata

ARG MIRTH_CONNECT_VERSION=3.7.1.b243

RUN \
  cd /tmp && \
  wget http://downloads.mirthcorp.com/connect/$MIRTH_CONNECT_VERSION/mirthconnect-$MIRTH_CONNECT_VERSION-unix.tar.gz && \
  cd /opt/mirth-connect/ && \
  tar xvzf /tmp/mirthconnect-$MIRTH_CONNECT_VERSION-unix.tar.gz --strip-components=1  && \
  rm -f /tmp/mirthconnect-$MIRTH_CONNECT_VERSION-unix.tar.gz

WORKDIR /opt/mirth-connect

EXPOSE 8080 8443

COPY docker-entrypoint.sh /
COPY mirth.properties_env /opt/mirth-connect/conf/

ENTRYPOINT ["/docker-entrypoint.sh"]

CMD ["java", "-jar", "mirth-server-launcher.jar"]
