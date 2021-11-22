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

## Loading Database

To load the database, imort the respective DB using `airlocal` command

Go to the installation of the ness-local-sites and run the command `wp db import /home/johndoe/.airsnapshots/<site_develop.sql>`