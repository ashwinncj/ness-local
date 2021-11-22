#!/bin/bash

## GitSource location for the sites
GITSOURCE="devops.45air.co/tmbi/sites/"
# Docker Repositories location.
if [ -z $DOCKER_INSTALL_PATH ]; then
    echo "Docker Installation Path NOT Set! Please update the PATH[DOCKER_INSTALL_PATH] and try again."
    exit 1
else
    DOCKER_INSTALL_PATH=$DOCKER_INSTALL_PATH
fi

# Ness Sites location.
if [ -z $NESS_LOCAL_SITES ]; then
    echo "Ness Local Sites Path NOT Set! Please update the PATH[NESS_LOCAL_SITES] and try again."
    exit 1
else
    NESS_LOCAL_SITES=$NESS_LOCAL_SITES
fi

# Gitlab UserName.
if [ -z $GITLAB_USER ]; then
    echo "Gitlab User NOT Set! Please update the [GITLAB_USER] and try again."
    exit 1
else
    GITLAB_USER=$GITLAB_USER
fi

# Personal Access Tokens.
if [ -z $GITLAB_TOKEN ]; then
    echo "Gitlab token NOT Set! Please update the [GITLAB_TOKEN] and try again."
    exit 1
else
    GITLAB_TOKEN=$GITLAB_TOKEN
fi

####################
# CLI Entry here #
####################

echo "## Ness Local ##"
read -p "What is the name of the site? " SITE_NAME
read -p "Enter Database Name: " DB_NAME
read -p "Enter Database User: " DB_USER
read -p "Enter Database Password: " DB_PASSWORD

printf "\nPlease wait while is the site is being created..."


## Creating the folders required to setup site.

cd $DOCKER_INSTALL_PATH
git clone https://$GITLAB_USER:$GITLAB_TOKEN@$GITSOURCE$SITE_NAME"-docker"
cd $DOCKER_INSTALL_PATH/$SITE_NAME"-docker"
composer install

## Run NPM Install for bumblebee theme.
THEME_LOCATION=$DOCKER_INSTALL_PATH/$SITE_NAME"-docker"/web/wp-content/themes
[ -d $THEME_LOCATION/bumblebee ] && cd $THEME_LOCATION/bumblebee && npm install && npm run gulp
[ -d $THEME_LOCATION/bumblebee-toh-child ] && cd $THEME_LOCATION/bumblebee-toh-child && npm install && npm run gulp

cd $NESS_LOCAL_SITES
mkdir $SITE_NAME"-test"
cd $SITE_NAME"-test"
mkdir $SITE_NAME"-docker"

## Download WP Core.
cd $SITE_NAME"-docker"
wp core download --version=5.4.2

## Remove wp-content folder.
rm wp-content -rf

## Setup links
ln $DOCKER_INSTALL_PATH/$SITE_NAME"-docker"/migrations $NESS_LOCAL_SITES/$SITE_NAME"-test" -s
ln $DOCKER_INSTALL_PATH/$SITE_NAME"-docker"/vendor $NESS_LOCAL_SITES/$SITE_NAME"-test"/$SITE_NAME"-docker/" -s
ln $DOCKER_INSTALL_PATH/$SITE_NAME"-docker"/web/wp-content $NESS_LOCAL_SITES/$SITE_NAME"-test"/$SITE_NAME"-docker/" -s

## Edit config file
# sed -i "/define( 'WP_DEBUG'/d" $NESS_LOCAL_SITES/$SITE_NAME"-test"/$SITE_NAME"-docker"/wp-config.php
# echo "define( 'WP_DEBUG', true );" >>$NESS_LOCAL_SITES/$SITE_NAME"-test"/$SITE_NAME"-docker"/wp-config.php

echo "
<?php

require_once 'vendor/autoload.php';
require_once 'vendor/tmbi/wp-migrations/src/CLI/Command.php';
require_once 'vendor/tmbi/wp-migrations/src/Database/Migrator.php';

define( 'DB_NAME', '"$DB_NAME"' );

/** MySQL database username */
define( 'DB_USER', '"$DB_USER"' );

/** MySQL database password */
define( 'DB_PASSWORD', '"$DB_PASSWORD"' );

/** MySQL hostname */
define( 'DB_HOST', 'localhost' );

/** Database Charset to use in creating database tables. */
define( 'DB_CHARSET', 'utf8mb4' );

/** The Database Collate type. Don't change this if in doubt. */
define( 'DB_COLLATE', '' );

\$table_prefix = 'wp_';

/** Absolute path to the WordPress directory. */
if ( ! defined( 'ABSPATH' ) ) {
        define( 'ABSPATH', __DIR__ . '/' );
}

/** Sets up WordPress vars and included files. */
require_once ABSPATH . 'wp-settings.php';

" > $NESS_LOCAL_SITES/$SITE_NAME"-test"/$SITE_NAME"-docker"/wp-config.php

echo""
echo "Copy the below NGinx Configurations to /etc/nginx/sites-available/"$SITE_NAME".conf and enable the site."
echo ""

echo "
server {
    listen 80;
    server_name "$SITE_NAME".test www."$SITE_NAME".test;
    root "$NESS_LOCAL_SITES"/"$SITE_NAME"-test/"$SITE_NAME"-docker;
    index index.html index.htm index.php;

    if (!-e \$request_filename) {
        rewrite /wp-admin\$ \$scheme://\$host\$uri/ permanent;
        rewrite ^(/[^/]+)?(/wp-.*) \$2 last;
        rewrite ^(/[^/]+)?(/.*\.php) \$2 last;
    }
    location / {
        try_files \$uri \$uri/ /index.php?\$args;
    }

    location ~ \.php\$ {
        include snippets/fastcgi-php.conf;
        fastcgi_pass unix:/var/run/php/php7.4-fpm.sock;
     }

    location ~ /\.ht {
        deny all;
    }

}"