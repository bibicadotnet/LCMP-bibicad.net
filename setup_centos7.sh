#setup for centos7 Oracle
sudo yum update -y
sudo yum install htop -y
sudo yum install zip -y
sudo yum install unzip -y
sudo yum install screen -y
sudo yum install wget -y
# SElinux off
sed -i 's@^SELINUX.*@SELINUX=disabled@g' /etc/selinux/config
setenforce 0
# Firewall Off
sudo systemctl stop firewalld
sudo systemctl disable firewalld
sudo systemctl mask --now firewalld
# setup caddy
yum install -y yum-plugin-copr && yum copr enable @caddy/caddy -y && yum install -y caddy
mkdir -p /data/www/default
mkdir -p /var/log/caddy/
mkdir -p /etc/caddy/conf.d/
chown -R caddy.caddy /data/www/default
chown -R caddy.caddy /var/log/caddy/
wget --no-check-certificate https://raw.githubusercontent.com/bibicadotnet/LCMP/main/Caddyfile -O /etc/caddy/Caddyfile
# setup mariadb 10.11
wget -qO mariadb_repo_setup.sh https://downloads.mariadb.com/MariaDB/mariadb_repo_setup
chmod +x mariadb_repo_setup.sh
./mariadb_repo_setup.sh --mariadb-server-version=mariadb-10.11
yum install -y MariaDB-common MariaDB-server MariaDB-client MariaDB-shared MariaDB-backup
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
# setup php 8.2
yum install -y https://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm
yum install -y https://rpms.remirepo.net/enterprise/remi-release-7.rpm
yum install -y yum-utils
yum-config-manager --disable 'remi-php*'
yum-config-manager --enable remi-php82
yum install -y php-cli php-bcmath php-embedded php-gd php-imap php-mysqlnd php-dba php-pdo php-pdo-dblib php-pgsql php-odbc php-enchant php-gmp php-intl php-ldap php-snmp php-soap php-tidy php-opcache php-process php-pspell php-shmop php-sodium php-ffi php-brotli php-lz4 php-xz php-zstd
yum install -y php-pecl-imagick-im7 php-pecl-zip php-pecl-mongodb php-pecl-swoole5 php-pecl-grpc php-pecl-yaml php-pecl-uuid
chown root.caddy /var/lib/php/session
chown root.caddy /var/lib/php/wsdlcache
chown root.caddy /var/lib/php/opcache
# Optimization
wget --no-check-certificate https://raw.githubusercontent.com/bibicadotnet/LCMP/main/php.ini -O /etc/php.ini
wget --no-check-certificate https://raw.githubusercontent.com/bibicadotnet/LCMP/main/www.conf -O /etc/php-fpm.d/www.conf
wget --no-check-certificate https://raw.githubusercontent.com/bibicadotnet/LCMP/main/my.cnf -O /etc/my.cnf
# start
systemctl enable mariadb
systemctl enable php-fpm
systemctl enable caddy
systemctl start mariadb
systemctl start php-fpm
systemctl start caddy
