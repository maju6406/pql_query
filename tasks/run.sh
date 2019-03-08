#!/usr/bin/env bash
#if puppet config print server | grep -v -q `puppet config print certname`; then
#  echo "This task can only be run on the master node."; 
#  exit 1
#fi
echo "query:" ${PT_query}
if [[ $PT_query == *"puppet query"* ]];
  echo "You don't need 'puppet query' in front of the query. Just add the query itself. Example: resources[file]{type = 'File'}"
  exit 1
fi
echo 'Results (YAML):'
unixtime_string="$(date +%s)"
json_filename="pqlquery_$unixtime_string.json"
yaml_filename="pqlquery_$unixtime_string.yaml"
/opt/puppetlabs/bin/puppet-query "$PT_query" &>/tmp/$json_filename 2>&1
/opt/puppetlabs/puppet/bin/ruby -e "require 'json'; puts (JSON.pretty_generate JSON.parse(STDIN.read))" < /tmp/$json_filename > /tmp/$yaml_filename
/opt/puppetlabs/puppet/bin/ruby -ryaml -rjson -e 'puts YAML.dump(JSON.parse(STDIN.read))' < /tmp/$json_filename > /tmp/$yaml_filename
cat /tmp/$yaml_filename
if [ "$PT_store_results" == "no" ]; then
  rm -rf /tmp/$json_filename
  rm -rf /tmp/$yaml_filename 
else
  echo
  echo "Query results (YAML) can be found here: /tmp/"${yaml_filename}
  echo "Query results (JSON) can be found here: /tmp/"${json_filename}  
fi

