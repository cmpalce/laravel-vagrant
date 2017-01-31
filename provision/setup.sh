#! /bin/bash

echo "Create Swap File"
sudo fallocate -l 4G /swapfile
sudo chmod 600 /swapfile
sudo mkswap /swapfile
sudo swapon /swapfile

echo "Installing Git"
sudo apt-get install git -y > /dev/null

echo "Installing Nginx"
echo 'deb http://nginx.org/packages/mainline/ubuntu/ trusty nginx' >> /etc/apt/sources.list
echo 'deb-src http://nginx.org/packages/mainline/ubuntu/ trusty nginx' >> /etc/apt/sources.list
wget -q -O- http://nginx.org/keys/nginx_signing.key | sudo apt-key add -
sudo apt-get install nginx -y > /dev/null

echo "Installing MySQL"
debconf-set-selections <<< "mysql-server mysql-server/root_password password 1234"
debconf-set-selections <<< "mysql-server mysql-server/root_password_again password 1234"

sudo apt-get install mysql-server mysql-client -y > /dev/null

mysql -uroot -p1234 -e "CREATE DATABASE alpha"

echo "Installing PHP"
sudo apt-get install software-properties-common
sudo apt-get install python-software-properties
sudo apt-get -y install zip php7.0 php7.0-zip php7.0-mysql php7.0-fpm php7.0-mbstring php7.0-xml php7.0-curl

echo "Setting up proper ownership"
sudo sed -i 's/user = www-data/user = ubuntu/g' /etc/php/7.0/fpm/pool.d/www.conf
sudo sed -i 's/group = www-data/group = ubuntu/g' /etc/php/7.0/fpm/pool.d/www.conf

echo "Installing composer"
php -r "readfile('https://getcomposer.org/installer');" > composer-setup.php
php composer-setup.php
php -r "unlink('composer-setup.php');"
mv composer.phar /usr/local/bin/composer
composer global require "laravel/installer"
echo 'export PATH="$PATH:$HOME/.config/composer/vendor/bin"' >> ~/.bashrc
source ~/.bashrc
cd /var/www && laravel new alpha

echo "Installing composer files"
cd /var/www/alpha && sudo composer install

echo "Create log file"
touch /var/www/alpha/storage/logs/laravel.log
ln -s /var/www/alpha/storage/app/public/images/gen /var/www/laravel_env/public/images/gen
chmod ugo+w /var/www/alpha/storage/logs/laravel.log
chmod -R ugo+rwx /var/www/alpha/vendor

echo "Running migration"
#cd /var/www/lravel_env && php artisan migrate
#cd /var/www/laravel_env && php artisan db:seed

echo "Configuring Nginx"
sudo cp /var/www/provision/config/nginx_vhost /etc/nginx/sites-available/nginx_vhost > /dev/null
sudo ln -s /etc/nginx/sites-available/nginx_vhost /etc/nginx/sites-enabled/
sudo rm -rf /etc/nginx/sites-available/default
sudo service nginx restart > /dev/null

echo "Install NodeJS and libraries"
#curl -o- https://raw.githubusercontent.com/creationix/nvm/v0.33.0/install.sh | bash
#sudo cp -r /root/.nvm /home/ubuntu/
#sudo chown -R ubuntu:ubuntu /home/ubuntu/.nvm
#source ~/.nvm/nvm.sh
#nvm install 7
#nvm use 7
#npm install
#npm install webpack -g

echo "Generate public files"
