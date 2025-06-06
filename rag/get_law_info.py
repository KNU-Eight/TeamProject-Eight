import requests
import ujson as json

OC = "tery95"
query = "주택임대차보호법"

# 주택임대차보호법 법령ID 가져오기
base_url = (
    f"http://www.law.go.kr/DRF/lawSearch.do?OC={OC}"
    "&target=law"
    f"&query={query}"
    "&type=JSON" 
)
res = requests.get(base_url)


# 조문 가져오기
ID = res.json()["LawSearch"]["law"][0]["법령ID"]
base_url = (
    f"http://www.law.go.kr/DRF/lawService.do?OC={OC}"
    "&target=law"
    f"&ID={ID}"
    "&type=JSON" 
)
res = requests.get(base_url)

# json파일로 저장
data = res.json()["법령"]["조문"]["조문단위"]
with open("housing_lease_protection_act.json", "w", encoding="utf-8") as f:
        json.dump(data, f, ensure_ascii=False, indent=2)
    
        
# 전세사기피해자 지원 및 주거안정에 관한 특별법 법령ID 가져오기
query = "전세사기피해자 지원 및 주거안정에 관한 특별법"
base_url = (
    f"http://www.law.go.kr/DRF/lawSearch.do?OC={OC}"
    "&target=law"
    f"&query={query}"
    "&type=JSON" 
)
res = requests.get(base_url)

# 조문 가져오기
ID = res.json()["LawSearch"]["law"][0]["법령ID"]
base_url = (
    f"http://www.law.go.kr/DRF/lawService.do?OC={OC}"
    "&target=law"
    f"&ID={ID}"
    "&type=JSON" 
)
res = requests.get(base_url)

# json파일로 저장
data = res.json()["법령"]["조문"]["조문단위"]
with open("jeonse_special_act.json", "w", encoding="utf-8") as f:
        json.dump(data, f, ensure_ascii=False, indent=2)

