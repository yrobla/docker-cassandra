#!/usr/bin/env bash

# generate token id based on IP
export CASSANDRA_TOKEN=${HOST//./}

# replace template vars
sed -i "s#CASSANDRA_HOST#$HOST#g" /etc/cassandra/conf/cassandra.yaml
sed -i "s#PRIVATE_IP#$PRIVATE_IP#g" /etc/cassandra/conf/cassandra.yaml
sed -i "s#PUBLIC_IP#$PUBLIC_IP#g" /etc/cassandra/conf/cassandra.yaml
sed -i "s#CASSANDRA_HOST#$HOST#g" /etc/opscenter/opscenterd.conf
sed -i "s#PRIVATE_IP#$PRIVATE_IP#g" /etc/opscenter/opscenterd.conf
sed -i "s#CASSANDRA_HOST#$HOST#g" /etc/datastax-agent/address.yaml
sed -i "s#PRIVATE_IP#$PRIVATE_IP#g" /etc/datastax-agent/address.yaml
sed -i "s#PUBLIC_IP#$PUBLIC_IP#g" /etc/datastax-agent/address.yaml
sed -i "s#CASSANDRA_HOST#$HOST#g" /etc/opscenter/clusters/Revisely.conf
sed -i "s#PRIVATE_IP#$PRIVATE_IP#g" /etc/opscenter/clusters/Revisely.conf
sed -i "s#PUBLIC_IP#$PUBLIC_IP#g" /etc/opscenter/clusters/Revisely.conf
