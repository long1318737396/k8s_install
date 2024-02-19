import requests

url = "https://registry.mtywcloud.com/v2/development/asis-api/tags/list"

payload={}
headers = {
  'Authorization': 'Basic ZGV2OlRvbXRhd0AyMDIy'}

response = requests.request("GET", url, headers=headers, data=payload)

print(response.text)