#!/usr/bin/env bash
if puppet config print server | grep -v -q `puppet config print certname`; then
  echo "This task can only be run on the master node."; 
  exit 1
fi
echo "query:" ${PT_query}
echo 'Results (YAML):'

web_root="/opt/puppetlabs/server/apps/nginx/share/html"
nginx_logs="/opt/puppetlabs/server/apps/nginx/logs"
nginx_config="/etc/puppetlabs/nginx/conf.d/proxy.conf"
unixtime_string="$(date +%s)"
json_filename="pqlquery_$unixtime_string.json"
json_loc="${web_root}/${json_filename}"
yaml_filename="pqlquery_$unixtime_string.yaml"
yaml_loc="${web_root}/${yaml_filename}"

/opt/puppetlabs/bin/puppet-query "$PT_query" &>"${json_loc}"
/opt/puppetlabs/puppet/bin/ruby -e "require 'json'; puts (JSON.pretty_generate JSON.parse(STDIN.read))" < "${json_loc}" > "${yaml_loc}"
/opt/puppetlabs/puppet/bin/ruby -ryaml -rjson -e 'puts YAML.dump(JSON.parse(STDIN.read))' < "${json_loc}" > "${yaml_loc}"
if ! grep --quiet "listen 81" $; then
  cp $nginx_config ${nginx_config}.old
  echo "server { server_name $HOSTNAME; access_log logs/$HOSTNAME.reports.access.log main; listen 81; root ${web_root};}" >> "${nginx_config}"
  mkdir -p ${nginx_logs}
  service pe-nginx restart
fi
cat ${yaml_loc}
if [ "$PT_store_results" == "no" ]; then
  rm -rf "${yaml_loc}"
  rm -rf "${json_loc}" 
else
  echo
  echo "Query results (YAML) can be found here: http://$HOSTNAME:81/${yaml_filename}"
  echo "Query results (JSON) can be found here: http://$HOSTNAME:81/${json_filename}" 
fi

