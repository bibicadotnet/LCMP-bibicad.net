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
    MESSAGE="MySQL Mariadb Service was down. Restarting now"
    curl -s -X POST https://api.telegram.org/bot$BOT_API_KEY/sendMessage -d chat_id=$CHAT_ID -d text="$MESSAGE"
fi

# Check if Caddy web server is running  
if ! systemctl is-active --quiet caddy.service; then
  # If not running, restart and send message to Telegram
    sudo systemctl restart caddy
    MESSAGE="Caddy Service was down. Restarting now"
    curl -s -X POST https://api.telegram.org/bot$BOT_API_KEY/sendMessage -d chat_id=$CHAT_ID -d text="$MESSAGE"
fi

# Check if PHP service is running 
if ! systemctl is-active --quiet php-fpm.service; then
  # If not running, restart and send message to Telegram
    sudo systemctl restart php-fpm
    MESSAGE="PHP Service was down. Restarting now"
    curl -s -X POST https://api.telegram.org/bot$BOT_API_KEY/sendMessage -d chat_id=$CHAT_ID -d text="$MESSAGE"
fi

sleep 1
done