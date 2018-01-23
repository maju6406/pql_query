#!/usr/bin/env bash
if puppet config print server | grep -v -q `hostname`; then
  echo "This task can only be run on the master node."; 
  exit 1
fi
echo "query:" ${query}
unixtime_string="$(date +%s)"
puppet-query '$PT_query' &>/tmp/query_$unixtime_string
echo "Query results can be found here: /tmp/query_"${unixtime_string}