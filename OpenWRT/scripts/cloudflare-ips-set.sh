#!/bin/sh

LOG_TAG="cloudflare_ip_update_script"
FILE_NAME="cloudflare-ips.txt"

# rm /tmp/cloudflare-ips.txt

wget -q "https://www.cloudflare.com/ips-v4" -O - > /root/$FILE_NAME

if [ $? -eq 0 ]; then
    logger -p notice -t $LOG_TAG "Cloudflare IPs downloaded successfully to /root/$FILE_NAME"
else
    logger -p err -t $LOG_TAG "ERROR Failed to download Cloudflare IPs. Wget exit code: $?."
    exit 1
fi

fw4 reload-sets

exit 0