import re
import urllib.request

urls = [
    "https://app.banani.co/assets/Frame-B9nvWsh5.js",
    "https://app.banani.co/assets/flow-CIEQ-E5_.js",
    "https://app.banani.co/assets/componentScreenId-SKrs6JjI.js",
    "https://app.banani.co/assets/ActiveScreenIdProvider-BTKT-iTF.js",
    "https://app.banani.co/assets/exports-CHFAw8Zn.js"
]

for url in urls:
    req = urllib.request.Request(url, headers={'User-Agent': 'Mozilla/5.0'})
    try:
        with urllib.request.urlopen(req) as response:
            content = response.read().decode('utf-8')
        
        matches = re.findall(r'[a-zA-Z0-9_]+\.[a-zA-Z0-9_]+\.useQuery', content)
        if matches:
            print(url, "useQuery:", set(matches))
            
        matches_mut = re.findall(r'[a-zA-Z0-9_]+\.[a-zA-Z0-9_]+\.useMutation', content)
        if matches_mut:
            print(url, "useMutation:", set(matches_mut))
            
        # check if it contains the flow version details or api calls
        matches_flow = re.findall(r'flowVersion\.[a-zA-Z0-9_]+', content)
        if matches_flow:
            print(url, "flowVersion properties:", set(matches_flow))
            
    except Exception as e:
        print(url, "Error:", e)
