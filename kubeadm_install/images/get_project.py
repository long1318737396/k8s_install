import requests

url = "https://registry.mtywcloud.com/api/v2.0/projects/development/repositories?page_size=100"

response = requests.get(url)
data = response.json()

name_list = []
for item in data:
    name = item["name"]
    name_list.append(name)

print(name_list)
