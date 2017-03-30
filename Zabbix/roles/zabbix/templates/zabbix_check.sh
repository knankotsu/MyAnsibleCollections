#!/usr/bin/env bash

if [ -z $1 ]; then
    echo "Usage: ./zabbix_check.sh <ip address>"
    exit 1
fi

modules=("agent.version" "agent.ping" "mysql.version" "mysql.ping" "mysql.status")
for module in $modules; do
    echo "Check ${module}..."
    zabbix_get -s $1 -k $module
done