import requests
from bs4 import BeautifulSoup

url = "https://zirovnica.si/novice-in-obvestila/"

response = requests.get(url)

print(response)