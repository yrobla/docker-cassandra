#!/usr/bin/env bash

# Get running container's IP
IP=$HOST

# check if we have peers
PEERS=()
if [ ! -z "$MARATHON_ENDPOINT" ]; then
    # curl the url and check if there is a host
    echo "Discovering configuration from $MARATHON_ENDPOINT"
    HOSTS=`curl -X GET -H "Content-Type: application/json" http://$MARATHON_ENDPOINT/v2/apps/yroblanuodbbroker | grep -Po '"host":".*?[^"]"' | sed 's/^.*://' | sed 's/^$/\1/'`
    echo "hosts are $HOSTS"
    for entry in $HOSTS
    do
        if [ "$entry" != "$HOST" ]; then
            echo "I have new peer $entry"
            PEERS+=("$entry")
        fi
    done
fi

# generate seeds entry
SEEDS_STR=$(printf ",%s" "${PEERS[@]}")
SEEDS_STR=${SEEDS_STR:1}

if [ -z "$SEEDS_STR" ]; then
    # be your own seed
    sed -i -e "s/- seeds: #SEEDS#/- seeds: \"$SEEDS\"/" $CASSANDRA_CONFIG/cassandra.yaml
else
    # Configure Cassandra seeds
    sed -i -e "s/- seeds: #SEEDS#/- seeds: \"$SEEDS_STR\"/" $CASSANDRA_CONFIG/cassandra.yaml
fi
