#!/bin/bash

# Bash script to install all the dependencies to the project.
# Adds curl, node, npm, pm2, nginx and clones the repo.

# UPDATE AND UPGRADE OF THE IMAGE
function updates {
    echo "################################## UPDATE AND UPGRADE OF THE IMAGE ############################"
    sudo apt-get -y update
    sudo apt-get -y upgrade
}

# INSTALL PACKAGES
function packages () {
    echo "################################## INSTALL PACKAGES ###################################"
    sudo apt install curl
    curl -sL https://deb.nodesource.com/setup_10.x | sudo bash -
    sudo apt-get install -y nodejs
    sudo npm install -g npm@latest
    sudo npm install -g pm2@latest --no-optional
}

# CHANGE OWNERSHIP OF THE DIRECTORIES
function changeDirectoriesOwnership () {
    echo "############################## CHANGE OWNERSHIP OF THE DIRECTORIES ###########################"
    sudo chown -R $(whoami) .config .npm
}

# CLONE THE REPO AND CD TO IT
function cloneRepo () {
    echo "################################### CLONE THE REPO AND CD TO IT ###################################"
    git clone https://github.com/andela/ah-bird-box-frontend.git
}

# INSTALL DEPENDENCIES AND ADD ENV VARIABLES
function appSetup () {
    echo "################################# INSTALL DEPENDENCIES AND ADD ENV VARIABLES #############################"
    cd ah-bird-box-frontend
    sudo npm config set user 0
    sudo npm config set unsafe-perm true
    export REACT_APP_API_URL="YOUR API URL"
    export REACT_APP_API_KEY="YOUR API KEY"
    export REACT_APP_AUTH_DOMAIN="YOUR AUTH DOMAIN (FIREBASE)"
    export REACT_APP_IMGUR_CLIENT_ID="IMGUR CLIENT ID"
    export REACT_APP_IMGUR_URL="IMGUR URL"
    sudo npm install --no-optional
    sudo chown -R $(whoami) /node_modules
}

# SET PM2 TO RUN THE APP IN THE BACKGROUND
function pm2Configuration () {
    echo "######################## SET PM2 TO RUN THE APP IN THE BACKGROUND ################################"
    pm2 start npm --name "AH-Birdbox" -- start
    pm2 startup
    sudo env PATH=$PATH:/usr/bin /usr/lib/node_modules/pm2/bin/pm2 startup systemd -u ubuntu --hp /home/ubuntu
    pm2 save
}

# INSTALL AND CONFIGURE NGINX
function nginxConfiguration () {
    echo "################################## INSTALL AND CONFIGURE NGINX #####################################"
    sudo apt-get install nginx -y
    sudo rm /etc/nginx/sites-enabled/default
    sudo touch /etc/nginx/sites-available/packerDemo
    sudo chown -R $(whoami) /etc/nginx/sites-available/packerDemo
    sudo echo 'server { listen 80; server_name localhost; location / { proxy_pass http://127.0.0.1:3000; proxy_http_version 1.1; proxy_set_header Upgrade $http_upgrade; proxy_set_header Connection 'upgrade'; proxy_set_header Host $host; proxy_cache_bypass $http_upgrade; } }' >> /etc/nginx/sites-available/packerDemo
    sudo ln -s /etc/nginx/sites-available/packerDemo /etc/nginx/sites-enabled/packerDemo
    sudo service nginx restart
}

function run () {
    updates
    packages
    changeDirectoriesOwnership
    cloneRepo
    appSetup
    pm2Configuration
    nginxConfiguration
}

run
