#!/usr/bin/env bash

# generate token id based on IP
export CASSANDRA_TOKEN=${HOST//./}

# replace template vars
sed -i "s#HOST#$HOST#g" /etc/cassandra/conf/cassandra.yaml


# enable ssl

