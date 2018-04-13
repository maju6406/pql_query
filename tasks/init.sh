#!/usr/bin/env bash
if puppet config print server | grep -v -q `puppet config print certname`; then
  echo "This task can only be run on the master node."; 
  exit 1
fi

if [ "$PT_use_reporter" == "yes" ]; then
  web_root="/opt/puppetlabs/server/apps/nginx/share/html"
  nginx_logs="/opt/puppetlabs/server/apps/nginx/logs"
  nginx_config="/etc/puppetlabs/nginx/conf.d/proxy.conf"
  reporter_port="82"
  echo "reporter port:" ${PT_reporter_port}

  if [ "$PT_reporter_port" == "" ]; then
    $reporter_port=$PT_reporter_port
  fi

  echo "reporter port:" ${reporter_port}
  if ! grep --quiet "listen $PT_reporter_port" ${nginx_config}; then
    echo "Adding reporter to nginx"
    cp ${nginx_config} ${nginx_config}.old
    echo "server { server_name $HOSTNAME; access_log logs/$HOSTNAME.reports.access.log main; listen ${reporter_port}; root ${web_root};}" >> "${nginx_config}"
    mkdir -p ${nginx_logs}
    service pe-nginx restart
  fi
fi

echo "query:" ${PT_query}
echo 'Results (YAML):'
unixtime_string="$(date +%s)"
json_filename="pqlquery_$unixtime_string.json"
yaml_filename="pqlquery_$unixtime_string.yaml"
/opt/puppetlabs/bin/puppet-query "$PT_query" &>/tmp/$json_filename
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


