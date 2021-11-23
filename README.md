# Ness-Local 
Local site development and deployment tool.

## 

## Prerequisites
- PHP 7.4
- LEMP Stack( Nginx, MySQL, PHP )
- Phpmyadmin
- Composer 1.10.*
- WP CLI
- `sudo` privileges
- PHP extensions( mbstring, php-redis, php-curl, php-zip, php-unzip)
- NPM config set and registry login

## Installation

AFter all the prerequisites are installed on the machine, follow the below steps to setup a local working site for your development.

### Clone repository
Clone this repository and export the repository PATH to `.bashrc` to make the command availble from all the locations.
```
git clone https://github.com/ashwinncj/ness-local.git
```

### Create required directories
Create two directories which are essential for the application -
* `docker-repositories` - This is required to save your docker repositories which are updated regularly using `composer update / composer install`
* `ness-local-sites` - This is the location of your local WordPress sites.

``` 
cd ~
mkdir docker-repositories
mkdir ness-local-sites
```

### Export PATHs 
* In order for the tool to install the sites in the right directory, the PATHs of the directories created in the previous steps needs to be updated in your bash profile(`.bashrc` or `.profile` )
* Along with the location og the directories, the authentication details for 45air needs to be exported to your bash profile.

```
export DOCKER_INSTALL_PATH=/home/johndoe/docker-repositories
export NESS_LOCAL_SITES=/home/johndoe/ness-local-sites
export GITLAB_USER=<your-gitlab-username>
export GITLAB_TOKEN=<your-personal-access-token>
```
## Creating new local site

### Database
Create a new database using phpmyadmin which will be used for the site being created. For e.g., `bnb-db`

### Create site
Use `ness-local` command to create new site.
```
$ ness-local
## Ness Local ##
What is the name of the site? bnb
Enter Database Name: bnb-db
Enter Database User: root
Enter Database Password: password
Media Proxy URL: http://stage.birdsandblooms.com

Please wait while is the site is being created...fatal: destination path 'bnb-docker' already exists and is not an empty directory.
Loading composer repositories with package information
Installing dependencies (including require-dev) from lock file
...

```
## Loading Database

* To load the database, import the respective DB using `airlocal` command

* Go to the installation of the ness-local-sites and run the command `wp db import /home/johndoe/.airsnapshots/<site_develop.sql>`

```
cd /home/johndoe/ness-local-sites/bnb-test/bnb-docker
wp db import /home/johndoe/.airsnapshots/bnb_stage.sql
```

* Update `site_url` and `home` option using `wp option update siteurl bnb.test`

```
wp option update home http://bnb.test
wp option update siteurl http://bnb.test
```