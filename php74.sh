sudo dnf update -y
sudo dnf install epel-release -y
sudo dnf install htop -y
sudo dnf install zip -y
sudo dnf install unzip -y
sudo dnf install screen -y
sudo dnf install wget -y
sudo fallocate -l 2G /swapfile
sudo chmod 600 /swapfile
sudo mkswap /swapfile
sudo swapon /swapfile
sudo cp /etc/fstab /etc/fstab.bak
echo '/swapfile none swap sw 0 0' | sudo tee -a /etc/fstab
sudo sysctl vm.swappiness=10
sed -i 's@^SELINUX.*@SELINUX=disabled@g' /etc/selinux/config
setenforce 0
sudo systemctl stop firewalld
sudo systemctl disable firewalld
sudo systemctl mask --now firewalld

# setup caddy
dnf install -y dnf-plugins-core
dnf copr enable @caddy/caddy -y && dnf install -y caddy && caddy version
mkdir -p /data/www/default
mkdir -p /var/log/caddy/
mkdir -p /etc/caddy/conf.d/
chown -R caddy.caddy /data/www/default
chown -R caddy.caddy /var/log/caddy/
wget https://raw.githubusercontent.com/bibicadotnet/LCMP/main/Caddyfile -O /etc/caddy/Caddyfile

# setup mariadb 10.11
wget -qO mariadb_repo_setup.sh https://downloads.mariadb.com/MariaDB/mariadb_repo_setup
chmod +x mariadb_repo_setup.sh
./mariadb_repo_setup.sh --mariadb-server-version=mariadb-10.11
dnf install -y MariaDB-common MariaDB-server MariaDB-client MariaDB-shared MariaDB-backup
lnum=$(sed -n '/\[mariadb\]/=' /etc/my.cnf.d/server.cnf)
sed -i "${lnum}acharacter-set-server = utf8mb4\n\n\[client-mariadb\]\ndefault-character-set = utf8mb4" /etc/my.cnf.d/server.cnf
systemctl start mariadb
db_pass="Thisisdbrootpassword"
mysql -e "grant all privileges on *.* to root@'127.0.0.1' identified by \"${db_pass}\" with grant option;"
mysql -e "grant all privileges on *.* to root@'localhost' identified by \"${db_pass}\" with grant option;"
mysql -uroot -p${db_pass} 2>/dev/null <<EOF
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

# setup php 7.4
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

# Optimization
wget https://raw.githubusercontent.com/bibicadotnet/LCMP/main/php.ini -O /etc/php.ini
wget https://raw.githubusercontent.com/bibicadotnet/LCMP/main/www.conf -O /etc/php-fpm.d/www.conf
wget https://raw.githubusercontent.com/bibicadotnet/LCMP/main/my.cnf -O /etc/my.cnf

# start
systemctl enable mariadb
systemctl enable php-fpm
systemctl enable caddy
systemctl start mariadb
systemctl start php-fpm
systemctl start caddy

# setup ssl
mkdir -p /etc/ssl/
sudo wget --no-check-certificate https://raw.githubusercontent.com/bibicadotnet/bibica.net/main/bibica.net.pem -O /etc/ssl/bibica.net.pem
sudo wget --no-check-certificate https://raw.githubusercontent.com/bibicadotnet/bibica.net/main/bibica.net.key -O /etc/ssl/bibica.net.key
sudo wget --no-check-certificate https://raw.githubusercontent.com/bibicadotnet/bibica.net/main/bibica.net.crt -O /etc/ssl/bibica.net.crt

# setup bibica.net, api.bibica.net
wget https://raw.githubusercontent.com/bibicadotnet/LCMP/main/domain-config/bibica.net.conf -O /etc/caddy/conf.d/bibica.net.conf
wget https://raw.githubusercontent.com/bibicadotnet/LCMP/main/domain-config/api.bibica.net.conf -O /etc/caddy/conf.d/api.bibica.net.conf
systemctl restart caddy

#setup database
mysql -u root -p'Thisisdbrootpassword'
CREATE DATABASE wordpress_database DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
GRANT ALL ON wordpress_database.* TO 'wordpress_user'@'localhost' IDENTIFIED BY 'password_pass';
FLUSH PRIVILEGES;
EXIT;

# setup wp-cli
curl -O https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar
chmod +x wp-cli.phar
mv wp-cli.phar /usr/local/bin/wp

# make foder bibica.net
mkdir -p /var/www/bibica.net/htdocs
cd /var/www/bibica.net/htdocs
wp core download --allow-root
wp core config --dbhost=localhost --dbname=wordpress_database --dbuser=wordpress_user --dbpass=password_pass --allow-root
chown -R caddy:caddy /var/www/bibica.net/htdocs
find . -type d -exec chmod 755 {} \;
find . -type f -exec chmod 644 {} \;
















