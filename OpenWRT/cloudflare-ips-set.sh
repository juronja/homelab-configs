#!/bin/sh

wget "https://www.cloudflare.com/ips-v4" -O ->> /tmp/cloudflareips.txt
fw4 reload-sets

exit 0