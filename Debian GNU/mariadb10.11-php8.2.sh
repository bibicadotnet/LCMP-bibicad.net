#!/bin/bash
# Set locale
locale-gen en_US.UTF-8
export LANG=en_US.UTF-8
export LC_ALL=en_US.UTF-8

# Set nameserver google, cloudflare
echo -e "nameserver 8.8.8.8\nnameserver 1.1.1.1" > /etc/resolv.conf

# Enable TCP BBR congestion control
cat <<EOF > /etc/sysctl.conf
# TCP BBR congestion control
net.core.default_qdisc=fq
net.ipv4.tcp_congestion_control=bbr
EOF

# update 
sudo apt update -y
sudo apt install htop -y
sudo apt install nano -y
sudo apt install zip -y
sudo apt install unzip -y
sudo apt install screen -y
sudo apt install wget -y
sudo apt install curl -y
sudo apt install gpg -y

# setup swapfile
sudo fallocate -l 1G /swapfile
sudo chmod 600 /swapfile
sudo mkswap /swapfile
sudo swapon /swapfile
sudo cp /etc/fstab /etc/fstab.bak
echo '/swapfile none swap sw 0 0' | sudo tee -a /etc/fstab
cat <<EOF > /etc/sysctl.d/99-xs-swappiness.conf
vm.swappiness=10
EOF

# Set time Viet Nam
timedatectl set-timezone Asia/Ho_Chi_Minh

# setup swapfile
sudo fallocate -l 1G /swapfile
sudo chmod 600 /swapfile
sudo mkswap /swapfile
sudo swapon /swapfile
sudo cp /etc/fstab /etc/fstab.bak
echo '/swapfile none swap sw 0 0' | sudo tee -a /etc/fstab
cat <<EOF > /etc/sysctl.d/99-xs-swappiness.conf
vm.swappiness=10
EOF

# setup caddy
sudo apt install -y debian-keyring debian-archive-keyring apt-transport-https
curl -1sLf 'https://dl.cloudsmith.io/public/caddy/stable/gpg.key' | sudo gpg --dearmor -o /usr/share/keyrings/caddy-stable-archive-keyring.gpg
curl -1sLf 'https://dl.cloudsmith.io/public/caddy/stable/debian.deb.txt' | sudo tee /etc/apt/sources.list.d/caddy-stable.list
sudo apt update && sudo apt install caddy -y
#caddy add-package github.com/sillygod/cdp-cache
mkdir -p /data/www/default
mkdir -p /var/log/caddy/
mkdir -p /etc/caddy/conf.d/
chown -R caddy:caddy /data/www/default
chown -R caddy:caddy /var/log/caddy/
chown -R caddy:caddy /etc/caddy/

# Setup mariadb 10.11
sudo apt install dirmngr ca-certificates software-properties-common apt-transport-https curl -y
curl -fsSL http://mirror.mariadb.org/PublicKey_v2 | sudo gpg --dearmor | sudo tee /usr/share/keyrings/mariadb.gpg > /dev/null
echo "deb [signed-by=/usr/share/keyrings/mariadb.gpg] http://mirror.mariadb.org/repo/10.11/debian/ $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/mariadb.list
sudo apt update && sudo apt install mariadb-server mariadb-client -y
db_pass_root="Thisisdbrootpassword"
mysql -e "grant all privileges on *.* to root@'127.0.0.1' identified by \"${db_pass_root}\" with grant option;"
mysql -e "grant all privileges on *.* to root@'localhost' identified by \"${db_pass_root}\" with grant option;"
mysql -uroot -p${db_pass_root} 2>/dev/null <<EOF
drop database if exists test;
delete from mysql.db where user='';
delete from mysql.db where user='PUBLIC';
delete from mysql.user where user='';
delete from mysql.user where user='mysql';
delete from mysql.user where user='PUBLIC';
flush privileges;
exit
EOF

# Setup php 8.2
sudo apt install -y apt-transport-https lsb-release ca-certificates wget 
wget -O /etc/apt/trusted.gpg.d/php.gpg https://packages.sury.org/php/apt.gpg
echo "deb https://packages.sury.org/php/ $(lsb_release -sc) main" | sudo tee /etc/apt/sources.list.d/php.list 
sudo apt update && sudo apt install php8.2 -y
sudo apt install -y php8.2-cli php8.2-common php8.2-mysql php8.2-zip php8.2-gd php8.2-mbstring php8.2-curl php8.2-xml php8.2-bcmath php8.2-opcache -y
sudo apt install php8.2-fpm -y

# Delete Apache
sudo systemctl disable --now apache2
sudo service apache2 stop
sudo apt remove --autoremove apache2 -y
sudo apt purge apache2 apache2-utils -y
sudo apt remove apache2 apache2-utils -y
sudo apt autoremove apache2 apache2-utils -y
sudo rm -r /usr/sbin/apache2 
sudo rm -r /usr/lib/apache2
sudo rm -r /etc/apache2
sudo rm -r /usr/share/man/man8/apache2.8.gz
sudo rm -r /etc/php/8.2/apache2
systemctl restart php8.2-fpm

# Optimization PHP, MariaDB

wget --no-check-certificate https://raw.githubusercontent.com/bibicadotnet/LCMP-bibicad.net/main/Debian%20GNU/my.cnf -O /etc/mysql/my.cnf
systemctl restart mariadb
wget --no-check-certificate https://raw.githubusercontent.com/bibicadotnet/LCMP-bibicad.net/main/Debian%20GNU/php8.2-mysql10.11/php.ini -O /etc/php/8.2/fpm/php.ini
wget --no-check-certificate https://raw.githubusercontent.com/bibicadotnet/LCMP-bibicad.net/main/Debian%20GNU/php8.2-mysql10.11/www.conf -O /etc/php/8.2/fpm/pool.d/www.conf
systemctl restart php8.2-fpm
wget --no-check-certificate https://raw.githubusercontent.com/bibicadotnet/LCMP-bibicad.net/main/Debian%20GNU/php8.2-mysql10.11/Caddyfile -O /etc/caddy/Caddyfile
systemctl restart caddy

# Auto start
systemctl enable mariadb
systemctl enable php8.2-fpm
systemctl enable caddy

# setup ssl
mkdir -p /etc/ssl/
chown -R caddy:caddy /etc/ssl/
sudo wget --no-check-certificate https://raw.githubusercontent.com/bibicadotnet/LCMP-bibicad.net/main/ssl/bibica.net.pem -O /etc/ssl/bibica.net.pem
sudo wget --no-check-certificate https://raw.githubusercontent.com/bibicadotnet/LCMP-bibicad.net/main/ssl/bibica.net.key -O /etc/ssl/bibica.net.key

# setup bibica.net, api.bibica.net, i0.bibica.net, i.bibica.net
mkdir -p /var/www/bibica.net/cache
chown -R caddy:caddy /var/www/bibica.net/cache
sudo wget --no-check-certificate https://raw.githubusercontent.com/bibicadotnet/LCMP-bibicad.net/main/Debian%20GNU/php8.2-mysql10.11/bibica.net.conf -O /etc/caddy/conf.d/bibica.net.conf
sudo wget --no-check-certificate https://raw.githubusercontent.com/bibicadotnet/LCMP-bibicad.net/main/Debian%20GNU/php8.2-mysql10.11/api.bibica.net.conf -O /etc/caddy/conf.d/api.bibica.net.conf
systemctl restart caddy

# setup wp-cli
curl -O https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar
chmod +x wp-cli.phar
mv wp-cli.phar /usr/local/bin/wp

# Monitor and restart PHP, Mysql, Caddy
#sudo wget --no-check-certificate https://raw.githubusercontent.com/bibicadotnet/LCMP-bibicad.net/main/monitor_service/lcmp-debian.sh -O /usr/local/bin/monitor_service_restart.sh
#chmod +x /usr/local/bin/monitor_service_restart.sh
#nohup /usr/local/bin/monitor_service_restart.sh >> ./out 2>&1 <&- &
#crontab -l > monitor_service_restart
#echo "@reboot nohup /usr/local/bin/monitor_service_restart.sh >> ./out 2>&1 <&- &" >> monitor_service_restart
#crontab monitor_service_restart

# setup crontab cho wp_cron and simply-static
crontab -l > simply-static
echo "0 3 * * * /usr/local/bin/wp --path='/var/www/bibica.net/htdocs' simply-static run --allow-root" >> simply-static
echo "*/1 * * * * curl https://bibica.net/wp-cron.php?doing_wp_cron > /dev/null 2>&1" >> simply-static
crontab simply-static

# setup releem
# yes y| RELEEM_MYSQL_MEMORY_LIMIT=0 RELEEM_API_KEY=c734e3de-3b21-4c29-96c4-26f3cdaf902f RELEEM_MYSQL_ROOT_PASSWORD='Thisisdbrootpassword' RELEEM_CRON_ENABLE=1 bash -c "$(curl -L https://releem.s3.amazonaws.com/v2/install.sh)"

# setup database
db_pass_root="Thisisdbrootpassword"
db_name="wordpress_database_name_99999"
db_user="wordpress_user_99999"
db_pass="password_pass_99999"
mysql -uroot -p${db_pass_root} -e "CREATE DATABASE ${db_name} DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci"
mysql -uroot -p${db_pass_root} -e "GRANT ALL ON ${db_name}.* TO '${db_user}'@'localhost' IDENTIFIED BY '${db_pass}'"

# make foder bibica.net
mkdir -p /var/www/bibica.net/htdocs
cd /var/www/bibica.net/htdocs
# wp core download --allow-root
# wp core config --dbhost=localhost --dbname=$db_name --dbuser=$db_user --dbpass=$db_pass --allow-root
chown -R caddy:caddy /var/www/bibica.net/htdocs
find . -type d -exec chmod 755 {} \;
find . -type f -exec chmod 644 {} \;

# Create symbolic link
ln -s /var/www /root/
ln -s /etc/caddy /root/

# show info database
green() {
  echo -e '\e[32m'$1'\e[m';
}
green "Database Root Password: $db_pass_root\nDatabase Name: $db_name\nDatabase User: $db_user\nDatabase Pass: $db_pass"
