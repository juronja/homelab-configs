#!/bin/sh

wget -q "https://www.cloudflare.com/ips-v4" -O ->> /tmp/cloudflare-ips.txt
fw4 reload-sets

exit 0