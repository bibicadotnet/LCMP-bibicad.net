# LCMP: Debian GNU/Linux 12 (Bookworm) - Caddy v2.7.4 - PHP 7.4.33 - MariaDB 10.11.5
Đây là các cài đặt và cấu hình mình đang áp dụng cho thèng bibica.net
## Cấu hình sử dụng
OS: Debian GNU/Linux 12 (Bookworm) 

UpCloud 1 GB RAM - Singapore
## Cài đặt LCMP
### Cập nhập OS
```shell
sudo apt update && sudo apt upgrade -y && sudo reboot
```
### Chạy trên x86_64, ARM64
```shell
sudo wget https://go.bibica.net/debian -O server.sh && sudo chmod +x server.sh && sudo ./server.sh
```
# LCMP: Debian 11 - Caddy v2.7.4 - PHP 7.4 - MariaDB 10.5
```shell
sudo wget https://raw.githubusercontent.com/bibicadotnet/LCMP-bibicad.net/main/Debian%20GNU/mariadb10.5-php7.4.sh -O server.sh && sudo chmod +x server.sh && sudo ./server.sh
```
## Releem
Có thể vào releem.com đăng kí 1 tài khoản miễn phí để tự động cấu hình MySQL hàng ngày, giúp hệ thống tối ưu hơn
## Update
08/10/2023: sử dụng cấu hình MySQL từ CloudPanel (hiệu năng liên quan tới database tốt hơn)
