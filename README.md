# LCMP: AlmaLinux 9 - Caddy v2.7.4 - PHP 7.4.33 - MariaDB 10.11.5

Note: Phần lớn các câu lệnh cài đặt đều lấy từ bài hướng dẫn của <a href="https://teddysun.com/701.html" target="_blank" rel="noopener">Teddysun</a>

Các câu lệnh được thử nghiệm trên AlmaLinux 9 (không chắc có thể chạy trên các OS khác không)

Đây là các cài đặt và cấu hình mình đang áp dụng cho thèng bibica.net
## Cấu hình sử dụng
VPS 1 GB RAM UpCloud - Singapore
## Cài đặt LCMP
Cài đặt wget
```shell
sudo dnf install wget -y
```
Chạy trên x86_64 và ARM64
```shell
sudo wget https://go.bibica.net/server -O server.sh && sudo chmod +x server.sh && sudo ./server.sh
```
Chạy trên x86_64, ARM64, IPv6 (bản public)
```shell
sudo wget https://raw.githubusercontent.com/bibicadotnet/LCMP-bibicad.net/main/ipv6.sh -O lcmp.sh && sudo chmod +x lcmp.sh && sudo ./lcmp.sh
```
## Releem
Có thể vào releem.com đăng kí 1 tài khoản miễn phí để tự động cấu hình MySQL hàng ngày, giúp hệ thống tối ưu hơn
