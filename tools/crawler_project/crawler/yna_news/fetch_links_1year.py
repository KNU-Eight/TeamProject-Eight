from selenium import webdriver
from selenium.webdriver.chrome.options import Options
from selenium.webdriver.common.by import By
from selenium.webdriver.support.ui import WebDriverWait
from selenium.webdriver.support import expected_conditions as EC
from bs4 import BeautifulSoup
from urllib.parse import quote
from datetime import datetime, timedelta
from tqdm import tqdm
import json
import os


def fetch_links_1year(keywords=None, max_pages=100, output_path="data/urls_1year.json"):
    if keywords is None:
        keywords = ["전세사기", "보증금", "깡통전세", "보증보험", "피해자"]

    encoded_query = quote(keywords[0])
    base_url = "https://www.yna.co.kr/search/index"

    today = datetime.today()
    one_year_ago = today - timedelta(days=365)
    to_date = today.strftime("%Y-%m-%d")
    from_date = one_year_ago.strftime("%Y-%m-%d")

    options = Options()
    options.add_argument("--headless")
    options.add_argument("--disable-gpu")
    options.add_argument("--no-sandbox")
    options.add_argument("--window-size=1920x1080")

    driver = webdriver.Chrome(options=options)
    links = set()

    #  기존 링크 로드
    if os.path.exists(output_path):
        with open(output_path, "r", encoding="utf-8") as f:
            existing_links = set(json.load(f))
    else:
        existing_links = set()

    for page in tqdm(range(1, max_pages + 1), desc="1년치 뉴스 링크 수집 중"):
        url = (
            f"{base_url}?query={encoded_query}&ctype=A&scope=title"
            f"&period=1y&from={from_date}&to={to_date}&page_no={page}"
        )
        driver.get(url)

        try:
            WebDriverWait(driver, 10).until(
                EC.presence_of_element_located((By.CSS_SELECTOR, "ul.list01 li div.item-box01"))
            )
        except:
            print(f" {page}페이지: 로딩 실패 또는 뉴스 없음")
            break

        soup = BeautifulSoup(driver.page_source, "lxml")
        items = soup.select("ul.list01 li div.item-box01")

        for item in items:
            a_tag = item.select_one("a[href^='https://www.yna.co.kr/view/']")
            title_tag = item.select_one("div.tit-wrap strong.tit-news")
            if not a_tag or not title_tag:
                continue
            title = title_tag.get_text(strip=True)
            href = a_tag.get("href")
            if any(k in title for k in keywords) and href and href not in existing_links:
                links.add(href)

    driver.quit()

    all_links = existing_links.union(links)
    os.makedirs(os.path.dirname(output_path), exist_ok=True)
    with open(output_path, "w", encoding="utf-8") as f:
        json.dump(list(all_links), f, ensure_ascii=False, indent=2)

    print(f" 1년치 수집 완료: {len(links)}개 추가됨 (총 {len(all_links)}개)")


# 실행 테스트
if __name__ == "__main__":
    fetch_links_1year(
        keywords=["전세사기", "보증금", "깡통전세", "보증보험", "피해자"]
    )
