#!/bin/bash
set -e

execute_raketask() {
  if [[ -z ${1} ]]; then
    echo "Please specify the rake task to execute."
    return 1
  fi
  echo "Running raketask ${1}..."
  bundle exec rake $@
}

cat > /etc/supervisor/conf.d/nginx.conf <<EOF
[program:nginx]
priority=20
directory=/tmp
command=/usr/sbin/nginx -g "daemon off;"
user=root
autostart=true
autorestart=true
EOF

cat > /etc/supervisor/conf.d/puma.conf <<EOF
[program:puma]
priority=10
directory=/ouadmin
command=bundle exec puma
user=root
autostart=true
autorestart=true
stopsignal=QUIT
EOF

case ${1} in
  app:init|app:start|app:rake|app:backup:create|app:backup:restore)

	sed -i "s|user www-data|user root|" /etc/nginx/nginx.conf

    case ${1} in
      app:start)
		    bundle exec rake db:create db:migrate
				bundle exec rails assets:precompile

				rm -f /ouadmin/tmp/pids/server.pid
        rm -rf /var/run/supervisor.sock

        exec /usr/bin/supervisord -nc /etc/supervisor/supervisord.conf
        ;;
      app:rake)
        shift 1
        execute_raketask $@
        ;;
      app:backup:create)
        #shift 1
        #backup_create $@
        ;;
      app:backup:restore)
        #shift 1
        #backup_restore $@
        ;;
    esac
    ;;
  app:help)
    echo "Available options:"
    echo " app:start          - Starts OUAdmin server (default)"
    echo " app:rake <task>    - Execute a rake task."
    #echo " app:backup:create  - Create a backup."
    #echo " app:backup:restore - Restore an existing backup."
    echo " app:help           - Displays the help"
    echo " [command]          - Execute the specified command, eg. bash."
    ;;
  *)
    exec "$@"
    ;;
esac
