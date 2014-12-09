# Spotify Cassandra 2.0 Base Image
#
# VERSION               0.1
#
# Installs Cassandra 2.0 package. Does only basic configuration.
# Tokens and seed nodes should be configured by child images.

FROM dockerfile/java:oracle-java7

ENV DEBIAN_FRONTEND noninteractive

# make sure the package repository is up to date and update ubuntu
RUN \
sed -i 's/# \(.*multiverse$\)/\1/g' /etc/apt/sources.list && \
apt-get update && \
apt-get -y upgrade && \
locale-gen en_US.UTF-8

# install supervisor
RUN apt-get install -y curl git htop man software-properties-common unzip vim wget

ENV LANG en_US.UTF-8
ENV LANGUAGE en_US.UTF-8
ENV LC_ALL en_US.UTF-8
ENV HOME /root

# supervisor installation &&
# create directory for child images to store configuration in
RUN apt-get -y install supervisor && \
mkdir -p /var/log/supervisor && \
mkdir -p /etc/supervisor/conf.d

# supervisor base configuration
ADD supervisor.conf /etc/supervisor.conf
ADD cassandra.conf /etc/supervisor.conf.d/

# Add DataStax sources
ADD datastax_key /tmp/datastax_key
RUN apt-key add /tmp/datastax_key
RUN echo "deb http://debian.datastax.com/community stable main" > /etc/apt/sources.list.d/datastax.list

# Workaround for https://github.com/docker/docker/issues/6345
RUN ln -s -f /bin/true /usr/bin/chfn

# Install Cassandra 2.0.10
RUN apt-get update && \
    apt-get install -y cassandra=2.0.10 dsc20=2.0.10-1 && \
    rm -rf /var/lib/apt/lists/*

ENV CASSANDRA_CONFIG /etc/cassandra

# Add yaml file
ADD cassandra.yaml /etc/cassandra/conf/cassandra.yaml

# Run base config script
ADD scripts/config-cassandra-base.sh /usr/local/bin/config-cassandra-base
RUN /usr/local/bin/config-cassandra-base

# Necessary since cassandra is trying to override the system limitations
# See https://groups.google.com/forum/#!msg/docker-dev/8TM_jLGpRKU/dewIQhcs7oAJ
RUN rm -f /etc/security/limits.d/cassandra.conf

EXPOSE 7199 9700 9701 9160 9042 8012 61621

USER root
ADD scripts/cassandra-clusternode.sh /usr/local/bin/cassandra-clusternode

# Start Cassandra
CMD supervisord -c /etc/supervisor.conf
