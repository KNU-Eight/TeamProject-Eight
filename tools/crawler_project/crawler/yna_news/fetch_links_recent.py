# crawler/fetch_links_recent.py

from selenium import webdriver
from selenium.webdriver.chrome.options import Options
from bs4 import BeautifulSoup
from urllib.parse import quote
from tqdm import tqdm
import json
import os
import time

def fetch_recent_links(query="전세사기", max_pages=3, output_path="data/urls_recent.json"):
    encoded_query = quote(query)
    base_url = "https://www.yna.co.kr/search/index"

    options = Options()
    options.add_argument("--headless")
    options.add_argument("--disable-gpu")
    options.add_argument("--no-sandbox")
    options.add_argument("--window-size=1920x1080")

    driver = webdriver.Chrome(options=options)

    links = set()

    for page in tqdm(range(1, max_pages + 1), desc="최근 뉴스 링크 수집 중"):
        url = f"{base_url}?query={encoded_query}&page={page}&site=default"
        driver.get(url)
        time.sleep(1.5)  # JS 렌더링 대기

        soup = BeautifulSoup(driver.page_source, "lxml")
        anchors = soup.select("div.item-box01 a[href^='https://www.yna.co.kr/view/']")

        if not anchors:
            print(f"⚠️ {page}페이지에 기사 없음. 중단합니다.")
            break

        for a in anchors:
            title = a.get_text(strip=True)
            href = a.get("href")

            # 필터: 제목에 "전세사기" 포함 & 중복 제거
            if href and "전세사기" in title:
                links.add(href)

    driver.quit()

    os.makedirs(os.path.dirname(output_path), exist_ok=True)
    with open(output_path, "w", encoding="utf-8") as f:
        json.dump(list(links), f, ensure_ascii=False, indent=2)

    print(f"✅ 수집된 전세사기 뉴스 링크 수: {len(links)}")

# 테스트 실행
if __name__ == "__main__":
    fetch_recent_links()
