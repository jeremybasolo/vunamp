#!/bin/bash

# Install various stuff
sudo apt-get update
sudo apt-get -y install zip unzip dos2unix shellinabox

# Install apache
sudo apt-get -y install apache2 apache2-bin

# Install mysql
sudo debconf-set-selections <<< 'mysql-server mysql-server/root_password password vagrant'
sudo debconf-set-selections <<< 'mysql-server mysql-server/root_password_again password vagrant'
sudo apt-get -y install mysql-server

# Install php
sudo add-apt-repository -y ppa:ondrej/php
sudo apt-get update
sudo apt-get -y install php7.3-fpm php7.3-cli php7.3-mysql php7.3-gd php7.3-xml php7.3-curl php7.3-mbstring php7.3-opcache php7.3-json
sudo apt-get -y install php5.6-fpm php5.6-cli php5.6-mysql php5.6-gd php5.6-xml php5.6-curl php5.6-mbstring php5.6-opcache php5.6-json

# Configure apache
sudo a2enmod proxy_fcgi
sudo a2enmod rewrite
sudo a2enconf php7.3-fpm 
sudo service apache2 restart
 
# Fix eventual issues with composer and available swamp
sudo /bin/dd if=/dev/zero of=/var/swap.1 bs=1M count=1024
/sbin/mkswap /var/swap.1
/sbin/swapon /var/swap.1

# Install phpmyadmin
sudo debconf-set-selections <<< "phpmyadmin phpmyadmin/reconfigure-webserver multiselect apache2"
sudo debconf-set-selections <<< "phpmyadmin phpmyadmin/dbconfig-install boolean true"
sudo debconf-set-selections <<< "phpmyadmin phpmyadmin/app-password-confirm password vagrant"
sudo debconf-set-selections <<< "phpmyadmin phpmyadmin/mysql/admin-pass password vagrant"
sudo debconf-set-selections <<< "phpmyadmin phpmyadmin/mysql/app-pass password vagrant"
sudo apt-get -y install phpmyadmin
sudo sh -c "sudo echo 'Include /etc/phpmyadmin/apache.conf' >> /etc/apache2/apache2.conf"

# Fix issue with phpmyadmin under php 7.3
sudo sed -i "s/|\s*\((count(\$analyzed_sql_results\['select_expr'\]\)/| (\1)/g" /usr/share/phpmyadmin/libraries/sql.lib.php

# Restart apache2
sudo a2dissite 000-default
sudo a2ensite dev
sed -i "s/Listen 80/Listen 8080/g" /etc/apache2/ports.conf
sudo service apache2 restart

# Install and setup nginx
sudo apt-get -y install nginx
rm /etc/nginx/sites-enabled/default
ln -s /etc/nginx/sites-available/dev /etc/nginx/sites-enabled/dev 
service nginx restart

# Install composer and wp-cli
php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');"
php composer-setup.php
sudo mv composer.phar /usr/local/bin/composer
php -r "copy('https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar', 'wp-cli.phar');"
chmod +x wp-cli.phar
sudo mv wp-cli.phar /usr/local/bin/wp


# Install shellinabox
sudo apt-get -y install shellinabox
echo '#vt100 #cursor.bright{background-color:#fff;color:#000}#vt100 #scrollable{color:#0f0;background-color:#000}#vt100 #scrollable.inverted{color:#000;background-color:#0f0}#vt100 .ansi15{color:#000}#vt100 .bgAnsi0{background-color:#0f0}' >> '/etc/shellinabox/options-available/00+Green on Black.css'
ln -s '/etc/shellinabox/options-available/00+Green on Black.css' '/etc/shellinabox/options-enabled/00+Green on Black.css'
rm /etc/shellinabox/options-enabled/00+Black\ on\ White.css
sed -i "s/--no-beep/--no-beep --disable-ssl -s \/:vagrant:vagrant:\/home\/vagrant:\/bin\/bash/g" /etc/default/shellinabox
sudo service shellinabox restart
