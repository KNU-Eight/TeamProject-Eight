import requests
import json
from bs4 import BeautifulSoup

# 국토교통부 보도자료 크롤링
BASE_URL = "https://www.molit.go.kr/USR/NEWS/m_71/lst.jsp"
DETAIL_BASE_URL = "https://www.molit.go.kr/USR/NEWS/m_71/"


def crawl_press_list(page=1):
    params = {"page": page}
    res = requests.get(BASE_URL, params=params)
    res.encoding = "utf-8"  
    soup = BeautifulSoup(res.text, "html.parser")

    table = soup.select_one("table.bd_tbl")
    rows = table.select("tbody > tr")

    result = []
    for row in rows:
        number = row.select_one("td.bd_num").text.strip()
        title_tag = row.select_one("td.bd_title a")
        title = title_tag.text.strip()
        link = DETAIL_BASE_URL + title_tag['href'].replace("&amp;", "&")  # 상대 경로 처리
        category = row.select_one("td.bd_field").text.strip()
        date = row.select_one("td.bd_date").text.strip()
        views = row.select_one("td.bd_inquiry").text.strip()

        result.append({
            "number": number,
            "title": title,
            "link": link,
            "category": category,
            "date": date,
            "views": views,
        })

    return result 

if __name__ == "__main__":
    articles = crawl_press_list(page=1)
    print(articles)
       
