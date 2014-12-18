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
RUN apt-get install -y curl git htop man software-properties-common unzip vim wget psmisc

# install python and deps
RUN apt-get install -y python python-dev python-pip sysstat
RUN pip install marathon

ENV LANG en_US.UTF-8
ENV LANGUAGE en_US.UTF-8
ENV LC_ALL en_US.UTF-8
ENV HOME /root

# supervisor installation &&
# create directory for child images to store configuration in
RUN apt-get -y install supervisor && \
mkdir -p /var/log/supervisor && \
mkdir -p /etc/supervisor && \
mkdir -p /etc/supervisor/conf.d

# supervisor base configuration
ADD supervisor.conf /etc/supervisor/supervisor.conf
ADD cassandra.conf /etc/supervisor/conf.d/

# Add DataStax sources
ADD datastax_key /tmp/datastax_key
RUN apt-key add /tmp/datastax_key
RUN echo "deb http://debian.datastax.com/community stable main" > /etc/apt/sources.list.d/datastax.list

# Workaround for https://github.com/docker/docker/issues/6345
RUN ln -s -f /bin/true /usr/bin/chfn

# Install Cassandra 2.0.10
RUN apt-get update && \
    apt-get install -y dsc21 cassandra cassandra-tools && \
    apt-get install -y opscenter-free && \
    apt-get install -y datastax-agent && \
    rm -rf /var/lib/apt/lists/*

# Add config files file
RUN mkdir -p /var/log/cassandra
RUN chmod a+w /var/log/cassandra
ENV CASSANDRA_CONFIG /etc/cassandra

RUN mkdir -p /etc/opscenter/clusters
ADD templates/cassandra.yaml /etc/cassandra/conf/cassandra.yaml
RUN ln -sf /etc/cassandra/conf/cassandra.yaml /etc/cassandra/cassandra.yaml
ADD templates/address.yaml /etc/datastax-agent/address.yaml
ADD log4j.properties /etc/cassandra/conf/log4j.properties
ADD templates/opscenter.conf /etc/opscenter/opscenterd.conf
ADD templates/Revisely.conf /etc/opscenter/clusters/Revisely.conf
ADD templates/cassandra-rackdc.properties /etc/cassandra/conf/cassandra-rackdc.properties

# Install extra packages
RUN wget http://snapshot.debian.org/archive/debian/20110406T213352Z/pool/main/o/openssl098/libssl0.9.8_0.9.8o-7_amd64.deb
RUN  dpkg -i libssl0.9.8_0.9.8o-7_amd64.deb

# Run base config script
ADD scripts/config-cassandra-base.sh /usr/local/bin/config-cassandra-base

RUN rm -f /etc/security/limits.d/cassandra.conf

EXPOSE 7199 9700 9701 9160 9042 8012 8082 9702 9703

USER root
ADD scripts/cassandra-clusternode.py /usr/local/bin/cassandra-clusternode.py

# remove files
RUN rm -rf /var/lib/cassandra/data/system/*

# Start Cassandra
CMD ["supervisord", "-c", "/etc/supervisor/supervisor.conf"]
