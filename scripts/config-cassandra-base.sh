#!/usr/bin/env bash

# generate token id based on IP
export CASSANDRA_TOKEN=${HOST//./}

# replace template vars
sed -i "s#CASSANDRA_HOST#$HOST#g" /etc/cassandra/cassandra.yaml
sed -i "s#CASSANDRA_HOST#$HOST#g" /etc/opscenter/opscenterd.conf
echo "stomp_interface: $HOST" | sudo tee -a /etc/datastax-agent/conf/address.yaml
