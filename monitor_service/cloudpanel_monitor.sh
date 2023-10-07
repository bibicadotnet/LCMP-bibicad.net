#!/bin/bash
while true
do

# Set up Telegram bot API and chat ID
BOT_API_KEY="6360723418:AAF1aya50fEi6sVuOwhXp53IV19siP3gqLc"
CHAT_ID="489842337"

# Check if MySQL Mariadb service is running  
if ! systemctl is-active --quiet mariadb.service; then
  # If not running, restart and send message to Telegram
    sudo systemctl restart mariadb 
    MESSAGE="Debian - CloudPanel - MySQL Mariadb v10.11 Service was down. Restarting now"
    curl -s -X POST https://api.telegram.org/bot$BOT_API_KEY/sendMessage -d chat_id=$CHAT_ID -d text="$MESSAGE"
fi

# Check if Nginx web server is running  
if ! systemctl is-active --quiet nginx.service; then
  # If not running, restart and send message to Telegram
    sudo systemctl restart nginx
    MESSAGE="Debian - CloudPanel - Nginx Service was down. Restarting now"
    curl -s -X POST https://api.telegram.org/bot$BOT_API_KEY/sendMessage -d chat_id=$CHAT_ID -d text="$MESSAGE"
fi

# Check if PHP service is running 
if ! systemctl is-active --quiet php7.1-fpm.service; then
  # If not running, restart and send message to Telegram
    sudo systemctl restart php7.1-fpm
    MESSAGE="Debian - CloudPanel - PHP v7.1 Service was down. Restarting now"
    curl -s -X POST https://api.telegram.org/bot$BOT_API_KEY/sendMessage -d chat_id=$CHAT_ID -d text="$MESSAGE"
fi

# Check if PHP service is running 
if ! systemctl is-active --quiet php7.2-fpm.service; then
  # If not running, restart and send message to Telegram
    sudo systemctl restart php7.2-fpm
    MESSAGE="Debian - CloudPanel - PHP v7.2 Service was down. Restarting now"
    curl -s -X POST https://api.telegram.org/bot$BOT_API_KEY/sendMessage -d chat_id=$CHAT_ID -d text="$MESSAGE"
fi

# Check if PHP service is running 
if ! systemctl is-active --quiet php7.3-fpm.service; then
  # If not running, restart and send message to Telegram
    sudo systemctl restart php7.3-fpm
    MESSAGE="Debian - CloudPanel - PHP v7.3 Service was down. Restarting now"
    curl -s -X POST https://api.telegram.org/bot$BOT_API_KEY/sendMessage -d chat_id=$CHAT_ID -d text="$MESSAGE"
fi

# Check if PHP service is running 
if ! systemctl is-active --quiet php7.4-fpm; then
  # If not running, restart and send message to Telegram
    sudo systemctl restart php7.4-fpm
    MESSAGE="Debian - CloudPanel - PHP v7.4 Service was down. Restarting now"
    curl -s -X POST https://api.telegram.org/bot$BOT_API_KEY/sendMessage -d chat_id=$CHAT_ID -d text="$MESSAGE"
fi

# Check if PHP service is running 
if ! systemctl is-active --quiet php8.0-fpm.service; then
  # If not running, restart and send message to Telegram
    sudo systemctl restart php8.0-fpm
    MESSAGE="Debian - CloudPanel - PHP v8.0 Service was down. Restarting now"
    curl -s -X POST https://api.telegram.org/bot$BOT_API_KEY/sendMessage -d chat_id=$CHAT_ID -d text="$MESSAGE"
fi

# Check if PHP service is running 
if ! systemctl is-active --quiet php8.1-fpm.service; then
  # If not running, restart and send message to Telegram
    sudo systemctl restart php8.1-fpm
    MESSAGE="Debian - CloudPanel - PHP v8.1 Service was down. Restarting now"
    curl -s -X POST https://api.telegram.org/bot$BOT_API_KEY/sendMessage -d chat_id=$CHAT_ID -d text="$MESSAGE"
fi

# Check if PHP service is running 
if ! systemctl is-active --quiet php8.2-fpm.service; then
  # If not running, restart and send message to Telegram
    sudo systemctl restart php8.2-fpm
    MESSAGE="Debian - CloudPanel - PHP v8.2 Service was down. Restarting now"
    curl -s -X POST https://api.telegram.org/bot$BOT_API_KEY/sendMessage -d chat_id=$CHAT_ID -d text="$MESSAGE"
fi

sleep 1
done
