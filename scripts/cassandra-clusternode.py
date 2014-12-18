#!/usr/bin/env python

from marathon import MarathonClient
import fileinput
import os
import sys

APP_ID = 'yroblacassandra'

# check if we have the endpoint
endpoint = os.getenv("MARATHON_ENDPOINT")
host = os.getenv("HOST")

peers = []
if endpoint:
    try:
        c = MarathonClient('http://%s' % endpoint)
        tasks = c.list_tasks(APP_ID)
        for task in tasks:
            if task.started_at and task.host != host:
                peers.append(task.host)
    except:
        pass

has_peers = True
if len(peers) == 0:
    has_peers = False
    peers = ['127.0.0.1',]

# generate seeds entry
seeds = ','.join(peers)
print 'seeds are %s' % seeds

for line in fileinput.FileInput('/etc/cassandra/conf/cassandra.yaml', inplace=1):
    if '- seeds' in line:
        line = line.replace('- seeds: CASSANDRA_SEEDS', '- seeds: "%s"' % seeds)
    sys.stdout.write(line)

for line in fileinput.FileInput('/etc/opscenter/clusters/Revisely.conf', inplace=1):
    if 'seed_hosts' in line:
        line = line.replace('seed_hosts = CASSANDRA_SEEDS', 'seed_hosts = %s' % seeds)
    sys.stdout.write(line)

for line in fileinput.FileInput('/etc/opscenter/opscenterd.conf', inplace=1):
    if 'seed_hosts' in line:
        line = line.replace('seed_hosts = CASSANDRA_SEEDS', 'seed_hosts = %s' % seeds)
    sys.stdout.write(line)

# autobootstrap for new nodes
if has_peers:
    for line in fileinput.FileInput('/etc/cassandra/conf/cassandra.yaml', inplace=1):
        if 'auto_bootstrap' in line:
            line = line.replace('false', 'true')
        sys.stdout.write(line)
