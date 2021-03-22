#!/usr/bin/env bash

set -e

if [[ -n "${DEBUG}" ]]; then
    set -x
fi

nginx_exec() {
    docker-compose exec -T nginx "${@}"
}

docker-compose up -d

nginx_exec make check-ready -f /usr/local/bin/actions.mk

# TODO: check endpoints of installed Drupal

echo "Checking Drupal endpoints"
echo -n "Checking / page... "
nginx_exec curl -I "localhost" | grep '302 Moved Temporarily'
echo -n "cron.php...        "
nginx_exec curl -I "localhost/cron.php" | grep '302 Moved Temporarily'
echo -n "index.php...       "
nginx_exec curl -I "localhost/index.php" | grep '302 Moved Temporarily'
echo -n "install.php...     "
nginx_exec curl -I "localhost/install.php?profile=default" | grep '200 OK'
echo -n "update.php...      "
nginx_exec curl -s -I "localhost/update.php" | grep '200 OK'
echo -n ".htaccess...       "
nginx_exec curl -I "localhost/.htaccess" | grep '403 Forbidden'
echo -n "favicon.ico...     "
nginx_exec curl -I "localhost/favicon.ico" | grep '200 OK'
echo -n "robots.txt...      "
nginx_exec curl -I "localhost/robots.txt" | grep '200 OK'
echo -n "drupal.js...       "
nginx_exec curl -I "localhost/misc/drupal.js" | grep '200 OK'
echo -n "druplicon.png...   "
nginx_exec curl -I "localhost/misc/druplicon.png" | grep '200 OK'

echo -n "Checking non existing php endpoint... "
nginx_exec curl -I "localhost/non-existing.php" | grep '404 Not Found'
echo -n "Checking user-defined internal temporal redirect... "
nginx_exec curl -I "localhost/redirect-internal-temporal" | grep '302 Moved Temporarily'
echo -n "Checking user-defined internal permanent redirect... "
nginx_exec curl -I "localhost/redirect-internal-permanent" | grep '301 Moved Permanently'
echo -n "Checking user-defined external redirect... "
nginx_exec curl -I "localhost/redirect-external" | grep '302 Moved Temporarily'

docker-compose down
