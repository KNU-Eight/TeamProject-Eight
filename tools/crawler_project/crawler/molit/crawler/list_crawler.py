import requests
from bs4 import BeautifulSoup

BASE_URL = "https://www.molit.go.kr/USR/NEWS/m_71/lst.jsp"
DETAIL_BASE_URL = "https://www.molit.go.kr/USR/NEWS/m_71/"  
def crawl_press_list(page=1):
    
    params = {"page": page , "search_section": "p_sec_2"}
    res = requests.get(BASE_URL, params=params)
    res.encoding = "utf-8"  
    soup = BeautifulSoup(res.text, "html.parser")

    table = soup.select_one("table.bd_tbl")
    rows = table.select("tbody > tr")

    result = []
    for row in rows:
        title_tag = row.select_one("td.bd_title a")
        title = title_tag.text.strip()
        link = DETAIL_BASE_URL + title_tag['href'].replace("&amp;", "&")  # 상대 경로 처리
        category = row.select_one("td.bd_field").text.strip()
        date = row.select_one("td.bd_date").text.strip()

        result.append({
            "filename":title+date,
            "title": title,
            "link": link,
            "category": category,
            "date": date,
        })

    return result 
