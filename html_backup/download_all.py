import json
import urllib.request
import urllib.parse
import os

os.makedirs("/home/john/Documenti/antigravity/ScaleSyncPro-Ecosystem/html_backup/screens", exist_ok=True)
os.makedirs("/home/john/Documenti/antigravity/ScaleSyncPro-Ecosystem/html_backup/components", exist_ok=True)

with open("/home/john/Documenti/antigravity/ScaleSyncPro-Ecosystem/html_backup/flow_screens.json", "r") as f:
    data = json.load(f)

screens = data["result"]["data"]["json"]

for screen in screens:
    screen_id = screen["id"]
    print("Fetching active structure for:", screen_id)
    
    # URL encode the screenId
    param = {"json": {"screenId": screen_id}}
    param_str = json.dumps(param)
    encoded = urllib.parse.quote(param_str)
    
    url = f"https://app.banani.co/api/trpc/screens.getActiveStructure?input={encoded}"
    req = urllib.request.Request(url, headers={'User-Agent': 'Mozilla/5.0'})
    
    try:
        with urllib.request.urlopen(req) as response:
            res_data = json.loads(response.read().decode('utf-8'))
            
        html_css = res_data["result"]["data"]["json"]["htmlCss"]
        
        # Determine output filename
        parts = screen_id.split("/")
        category = parts[-2] # components or screens
        filename = parts[-1].replace(".jsx", ".html")
        
        filepath = os.path.join("/home/john/Documenti/antigravity/ScaleSyncPro-Ecosystem/html_backup", category, filename)
        with open(filepath, "w") as out_f:
            out_f.write(html_css)
            
        print("Saved to:", filepath)
        
    except Exception as e:
        print("Error fetching:", screen_id, e)
