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

printf "\nPlease wait while is the site is being created..."


## Creating the folders required to setup site.

cd $DOCKER_INSTALL_PATH
git clone https://$GITLAB_USER:$GITLAB_TOKEN@$GITSOURCE$SITE_NAME"-docker"
cd $DOCKER_INSTALL_PATH/$SITE_NAME"-docker"
composer install

cd $NESS_LOCAL_SITES
mkdir $SITE_NAME"-test"
cd $SITE_NAME"-test"
mkdir $SITE_NAME"-docker"

## Download WP Core.
cd $SITE_NAME"-docker"
wp core download --version=5.4.2

## Setup links
ln $DOCKER_INSTALL_PATH/$SITE_NAME"-docker"/migrations $NESS_LOCAL_SITES/$SITE_NAME"-test" -s
ln $DOCKER_INSTALL_PATH/$SITE_NAME"-docker"/vendor $NESS_LOCAL_SITES/$SITE_NAME"-test"/$SITE_NAME"-docker/" -s

## Edit config file
sed -i "/define( 'WP_DEBUG'/d" $NESS_LOCAL_SITES/$SITE_NAME"-test"/$SITE_NAME"-docker"/wp-config.php

echo "define( 'WP_DEBUG', true );" >>$NESS_LOCAL_SITES/$SITE_NAME"-test"/$SITE_NAME"-docker"/wp-config.php
echo "require_once 'vendor/tmbi/wp-migrations/src/CLI/Command.php';
require_once 'vendor/tmbi/wp-migrations/src/Database/Migrator.php';" >> $NESS_LOCAL_SITES/$SITE_NAME"-test"/$SITE_NAME"-docker"/wp-config.php