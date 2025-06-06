# pip install cloudflare
import os
from dotenv import load_dotenv
from cloudflare import Cloudflare

load_dotenv()

client = Cloudflare(
    api_email=os.environ.get("CF_API_EMAIL"),
    api_key=os.environ.get("CF_API_KEY")
)

try:
    ipv4_set = client.ips.list().ipv4_cidrs
    ipv6_set = client.ips.list().ipv6_cidrs

    for ip in ipv4_set:
        print(f"\tlist entry '{ip}'")
except Exception as e:
    print(f"Error ocurred: {e}")

