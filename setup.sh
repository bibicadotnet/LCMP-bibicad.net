#!/bin/bash

# Set nameserver google, cloudflare
echo -e "nameserver 8.8.8.8\nnameserver 1.1.1.1" > /etc/resolv.conf

# Update
sudo dnf update -y
sudo dnf install epel-release -y
sudo dnf install htop -y
sudo dnf install zip -y
sudo dnf install unzip -y
sudo dnf install screen -y
sudo dnf install wget -y
sudo dnf install nano -y

# Set time Viet Nam
timedatectl set-timezone Asia/Ho_Chi_Minh

# Enable TCP BBR congestion control
cat <<EOF > /etc/sysctl.conf
# TCP BBR congestion control
net.core.default_qdisc=fq
net.ipv4.tcp_congestion_control=bbr
EOF

# swapfile
sudo fallocate -l 2G /swapfile
sudo chmod 600 /swapfile
sudo mkswap /swapfile
sudo swapon /swapfile
sudo cp /etc/fstab /etc/fstab.bak
echo '/swapfile none swap sw 0 0' | sudo tee -a /etc/fstab
sudo sysctl vm.swappiness=10
cat <<EOF > /etc/sysctl.d/99-xs-swappiness.conf
vm.swappiness=10
EOF

# SELINUX=disabled
sed -i 's@^SELINUX.*@SELINUX=disabled@g' /etc/selinux/config
setenforce 0

# Off Firewall
sudo systemctl stop firewalld
sudo systemctl disable firewalld
sudo systemctl mask --now firewalld

# Setup Caddy
dnf install -y dnf-plugins-core
dnf copr enable @caddy/caddy -y && dnf install -y caddy && caddy version
caddy add-package github.com/caddyserver/cache-handler
caddy add-package github.com/caddyserver/replace-response
caddy add-package github.com/sillygod/cdp-cache

mkdir -p /data/www/default
mkdir -p /var/log/caddy/
mkdir -p /etc/caddy/conf.d/
chown -R caddy.caddy /data/www/default
chown -R caddy.caddy /var/log/caddy/
wget --no-check-certificate https://raw.githubusercontent.com/bibicadotnet/LCMP-bibicad.net/main/Caddy/Caddyfile -O /etc/caddy/Caddyfile

# Setup mariadb 10.11
wget -qO mariadb_repo_setup.sh https://downloads.mariadb.com/MariaDB/mariadb_repo_setup
chmod +x mariadb_repo_setup.sh
./mariadb_repo_setup.sh --mariadb-server-version=mariadb-10.11
dnf install -y MariaDB-common MariaDB-server MariaDB-client MariaDB-shared MariaDB-backup
lnum=$(sed -n '/\[mariadb\]/=' /etc/my.cnf.d/server.cnf)
sed -i "${lnum}acharacter-set-server = utf8mb4\n\n\[client-mariadb\]\ndefault-character-set = utf8mb4" /etc/my.cnf.d/server.cnf
systemctl start mariadb
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
systemctl stop mariadb

# Setup php 7.4
dnf config-manager --set-enabled crb
dnf install -y https://dl.fedoraproject.org/pub/epel/epel-release-latest-9.noarch.rpm
dnf install -y https://rpms.remirepo.net/enterprise/remi-release-9.rpm
dnf module reset -y php
dnf module install -y php:remi-7.4
dnf install -y php-cli php-bcmath php-embedded php-gd php-imap php-mysqlnd php-dba php-pdo php-pdo-dblib php-pgsql php-odbc php-enchant php-gmp php-intl php-ldap php-snmp php-soap php-tidy php-opcache php-process php-pspell php-shmop php-sodium php-ffi php-brotli php-lz4 php-xz php-zstd
dnf install -y php-pecl-imagick-im7 php-pecl-zip php-pecl-mongodb php-pecl-grpc php-pecl-yaml php-pecl-uuid php-zip
chown root.caddy /var/lib/php/session
chown root.caddy /var/lib/php/wsdlcache
chown root.caddy /var/lib/php/opcache

# Optimization PHP, MariaDB
wget --no-check-certificate https://raw.githubusercontent.com/bibicadotnet/LCMP-bibicad.net/main/PHP/php.ini -O /etc/php.ini
wget --no-check-certificate https://raw.githubusercontent.com/bibicadotnet/LCMP-bibicad.net/main/PHP/www.conf -O /etc/php-fpm.d/www.conf
wget --no-check-certificate https://raw.githubusercontent.com/bibicadotnet/LCMP-bibicad.net/main/MySQL/cloudpanel_my.cnf -O /etc/my.cnf
#wget --no-check-certificate https://raw.githubusercontent.com/bibicadotnet/LCMP-bibicad.net/main/MySQL/my.cnf -O /etc/my.cnf


# Create symbolic link
ln -s /var/www /root/
ln -s /etc/caddy /root/

# start
systemctl enable mariadb
systemctl enable php-fpm
systemctl enable caddy
systemctl start mariadb
systemctl start php-fpm
systemctl start caddy

# setup ssl
mkdir -p /etc/ssl/
sudo wget --no-check-certificate https://raw.githubusercontent.com/bibicadotnet/LCMP-bibicad.net/main/ssl/bibica.net.pem -O /etc/ssl/bibica.net.pem
sudo wget --no-check-certificate https://raw.githubusercontent.com/bibicadotnet/LCMP-bibicad.net/main/ssl/bibica.net.key -O /etc/ssl/bibica.net.key

# setup bibica.net, api.bibica.net, i0.bibica.net, i.bibica.net
mkdir -p /var/www/bibica.net/cache
chown -R caddy:caddy /var/www/bibica.net/cache
sudo wget --no-check-certificate https://raw.githubusercontent.com/bibicadotnet/LCMP-bibicad.net/main/bibica-net-caddy-config/bibica.net.conf -O /etc/caddy/conf.d/bibica.net.conf
sudo wget --no-check-certificate https://raw.githubusercontent.com/bibicadotnet/LCMP-bibicad.net/main/bibica-net-caddy-config/api.bibica.net.conf -O /etc/caddy/conf.d/api.bibica.net.conf
sudo wget --no-check-certificate https://raw.githubusercontent.com/bibicadotnet/LCMP-bibicad.net/main/bibica-net-caddy-config/i0.bibica.net.conf -O /etc/caddy/conf.d/i0.bibica.net.conf
sudo wget --no-check-certificate https://raw.githubusercontent.com/bibicadotnet/LCMP-bibicad.net/main/bibica-net-caddy-config/i.bibica.net.conf -O /etc/caddy/conf.d/i.bibica.net.conf
systemctl restart caddy

# setup wp-cli
curl -O https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar
chmod +x wp-cli.phar
mv wp-cli.phar /usr/local/bin/wp

# setup rclone
sudo -v ; curl https://rclone.org/install.sh | sudo bash

# Monitor and restart PHP, Mysql, Caddy
sudo wget --no-check-certificate https://raw.githubusercontent.com/bibicadotnet/LCMP-bibicad.net/main/monitor_service/monitor_service_restart.sh -O /usr/local/bin/monitor_service_restart.sh
chmod +x /usr/local/bin/monitor_service_restart.sh
nohup /usr/local/bin/monitor_service_restart.sh >> ./out 2>&1 <&- &
crontab -l > monitor_service_restart
echo "@reboot nohup /usr/local/bin/monitor_service_restart.sh >> ./out 2>&1 <&- &" >> monitor_service_restart
crontab monitor_service_restart

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

# show info database
green() {
  echo -e '\e[32m'$1'\e[m';
}
green "Database Root Password: $db_pass_root\nDatabase Name: $db_name\nDatabase User: $db_user\nDatabase Pass: $db_pass"
