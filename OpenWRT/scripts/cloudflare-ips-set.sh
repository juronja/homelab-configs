#!/bin/sh

wget -q "https://www.cloudflare.com/ips-v4" -O - > /tmp/cloudflare-ips.txt

if [ $? -eq 0 ]; then
    logger -t "cloudflare_ip_update_script" "INFO: Cloudflare IPs downloaded successfully to /tmp/cloudflare-ips.txt"
else
    logger -t "cloudflare_ip_update_script" "ERROR: Failed to download Cloudflare IPs. Wget exit code: $?."
    # Exit if wget fails to prevent further commands from running with outdated data
    exit 1
fi

fw4 reload-sets

exit 0