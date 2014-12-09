#!/usr/bin/env bash

# Get running container's IP
IP=$HOST

# Setup cluster name
if [ -z "$CASSANDRA_CLUSTERNAME" ]; then
        echo "No cluster name specified, preserving default one"
else
        sed -i -e "s/^cluster_name:.*/cluster_name: $CASSANDRA_CLUSTERNAME/" $CASSANDRA_CONFIG/cassandra.yaml
fi

# Dunno why zeroes here
sed -i -e "s/^rpc_address.*/rpc_address: $IP/" $CASSANDRA_CONFIG/cassandra.yaml

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
    sed -i -e "s/- seeds: \"$HOST\"/- seeds: \"$SEEDS\"/" $CASSANDRA_CONFIG/cassandra.yaml
else
    # Configure Cassandra seeds
    sed -i -e "s/- seeds: \"$HOST\"/- seeds: \"$SEEDS_STR\"/" $CASSANDRA_CONFIG/cassandra.yaml
fi

# Listen on IP:port of the container
sed -i -e "s/^listen_address.*/listen_address: $IP/" $CASSANDRA_CONFIG/cassandra.yaml

# Broadcast on IP:port of the container
sed -i -e "s/^# broadcast_address.*/broadcast_address: $HOST/" $CASSANDRA_CONFIG/cassandra.yaml

# Most likely not needed
echo "JVM_OPTS=\"\$JVM_OPTS -Djava.rmi.server.hostname=$IP\"" >> $CASSANDRA_CONFIG/cassandra-env.sh

echo "Starting Cassandra on $IP..."

cassandra -f
