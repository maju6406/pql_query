#!/usr/bin/env bash
if puppet config print server | grep -v -q `hostname`; then
  echo "This task can only be run on the master node."; 
  exit 1
fi
echo "query:" ${PT_query}
echo '---'
unixtime_string="$(date +%s)"
filename="pqlquery_$unixtime_string.json"
/opt/puppetlabs/bin/puppet-query "$PT_query" &>/tmp/$filename
cat /tmp/$filename
echo
echo '---'
echo "Query results can be found here: /tmp/"${filename}