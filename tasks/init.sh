#!/usr/bin/env bash
if puppet config print server | grep -v -q `puppet config print certname`; then
  echo "This task can only be run on the master node."; 
  exit 1
fi
write_report () {
file_contents=$(<"$1")
echo write_report_path $1.html
file_type="json"
if [[ $1 = *"yaml"* ]]; then
  $file_type="yaml"
fi
cat << EOF > "$1.html"
<html>

<head>
    <style type="text/css" media="screen">
        #editor {
            position: absolute;
            top: 0;
            right: 0;
            bottom: 0;
            left: 0;
        }
    </style>
</head>

<body>

    <div id="editor">
<pre>
$file_contents
</pre>
    </div>

    <script src="http://ajaxorg.github.io/ace-builds/src-noconflict/ace.js" type="text/javascript" charset="utf-8"></script>
    <script>
        var editor = ace.edit("editor");
        editor.setTheme("ace/theme/monokai");
        editor.session.setMode("ace/mode/$file_type");
        editor.setHighlightActiveLine(true); 
        editor.setShowPrintMargin(true);       
        editor.setReadOnly(true);
    </script>
</body>

</html>
EOF
}


if [ "$PT_use_reporter" = "yes" ]; then
  web_root="/opt/puppetlabs/server/apps/nginx/share/html"
  nginx_logs="/opt/puppetlabs/server/apps/nginx/logs"
  nginx_config="/etc/puppetlabs/nginx/conf.d/proxy.conf"
  reporter_port="82"

  if [ -z "$PT_reporter_port"]; then
    $reporter_port=$PT_reporter_port
  fi

  if ! grep --quiet "listen ${reporter_port}" ${nginx_config}; then
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
mkdir -p $web_root/$unixtime_string
report_dir=$web_root/$unixtime_string
json_filename="pqlquery_$unixtime_string.json"
yaml_filename="pqlquery_$unixtime_string.yaml"
/opt/puppetlabs/bin/puppet-query "$PT_query" &>/tmp/$json_filename
# pretty print the json
/opt/puppetlabs/puppet/bin/ruby -e "require 'json'; puts (JSON.pretty_generate JSON.parse(STDIN.read))" < /tmp/$json_filename > /tmp/$yaml_filename
# pretty print the yaml
/opt/puppetlabs/puppet/bin/ruby -ryaml -rjson -e 'puts YAML.dump(JSON.parse(STDIN.read))' < /tmp/$json_filename > /tmp/$yaml_filename
cat /tmp/$yaml_filename
if [ "$PT_store_results" != "no" ]; then
  if [ "$PT_use_reporter" = "yes" ]; then
    mv /tmp/$json_filename $report_dir
    mv /tmp/$yaml_filename $report_dir
    write_report $report_dir/$json_filename    
    write_report $report_dir/$yaml_filename        
    echo
    echo "Query results (YAML) can be found here: http://$HOSTNAME:${reporter_port}/${unixtime_string}/${yaml_filename}.html"
    echo "Query results (JSON) can be found here: http://$HOSTNAME:${reporter_port}/${unixtime_string}/${json_filename}.html"       
  else
    echo
    echo "Query results (YAML) can be found here: /tmp/${yaml_filename}"
    echo "Query results (JSON) can be found here: /tmp/${json_filename}"  
  fi  
else
  rm -rf /tmp/$json_filename
  rm -rf /tmp/$yaml_filename 
fi
