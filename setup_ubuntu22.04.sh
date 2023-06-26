# update Ubuntu
sudo apt  update -y
sudo apt  install htop -y
sudo apt  install zip -y
sudo apt  install unzip -y
sudo apt  install screen -y
sudo apt  install wget -y

# setup swapfile
sudo fallocate -l 2G /swapfile
sudo chmod 600 /swapfile
sudo mkswap /swapfile
sudo swapon /swapfile
sudo cp /etc/fstab /etc/fstab.bak
echo '/swapfile none swap sw 0 0' | sudo tee -a /etc/fstab
sudo sysctl vm.swappiness=10

# off firewall
sudo systemctl stop firewalld
sudo systemctl disable firewalld
sudo systemctl mask --now firewalld

# setup caddy
sudo apt install -y debian-keyring debian-archive-keyring apt-transport-https curl
curl -1sLf 'https://dl.cloudsmith.io/public/caddy/stable/gpg.key' | sudo gpg --dearmor -o /usr/share/keyrings/caddy-stable-archive-keyring.gpg
curl -1sLf 'https://dl.cloudsmith.io/public/caddy/stable/debian.deb.txt' | sudo tee /etc/apt/sources.list.d/caddy-stable.list
sudo apt update && sudo apt install caddy -y
mkdir -p /data/www/default
mkdir -p /var/log/caddy/
mkdir -p /etc/caddy/conf.d/
chown -R caddy.caddy /data/www/default
chown -R caddy.caddy /var/log/caddy/
wget https://raw.githubusercontent.com/bibicadotnet/LCMP/main/ubuntu/Caddyfile -O /etc/caddy/Caddyfile

# setup mariadb 10.11 - pass rood Thisisdbrootpassword
wget -qO mariadb_repo_setup.sh https://downloads.mariadb.com/MariaDB/mariadb_repo_setup
chmod +x mariadb_repo_setup.sh
./mariadb_repo_setup.sh --mariadb-server-version=mariadb-10.11
sudo apt install mariadb-server -y
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
sudo apt install -y lsb-release gnupg2 ca-certificates apt-transport-https software-properties-common
sudo add-apt-repository ppa:ondrej/php -y
sudo apt install php8.2 -y
sudo apt install php8.2-fpm -y
sudo apt install php8.2-common php8.2-mysql php8.2-xml php8.2-xmlrpc php8.2-curl php8.2-gd php8.2-imagick php8.2-cli php8.2-dev php8.2-imap php8.2-mbstring php8.2-opcache php8.2-soap php8.2-zip php8.2-intl -y

# Optimization
wget https://raw.githubusercontent.com/bibicadotnet/LCMP/main/ubuntu/php.ini -O /etc/php/8.2/fpm/php.ini
wget https://raw.githubusercontent.com/bibicadotnet/LCMP/main/ubuntu/www.conf -O /etc/php/8.2/fpm/pool.d/www.conf
wget https://raw.githubusercontent.com/bibicadotnet/LCMP/main/ubuntu/my.cnf -O /etc/mysql/my.cnf

# start
systemctl enable mariadb
systemctl enable php8.2-fpm
systemctl enable caddy
systemctl start mariadb
systemctl start php8.2-fpm
systemctl start caddy
systemctl restart mariadb
systemctl restart php8.2-fpm
systemctl restart caddy
