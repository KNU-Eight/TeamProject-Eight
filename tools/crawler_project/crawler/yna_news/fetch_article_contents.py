from selenium import webdriver
from selenium.webdriver.chrome.options import Options
from bs4 import BeautifulSoup
from tqdm import tqdm
import json
import os
import time

def create_driver():
    options = Options()
    options.add_argument("--headless")
    options.add_argument("--disable-gpu")
    options.add_argument("--no-sandbox")
    options.add_argument("--window-size=1920x1080")
    return webdriver.Chrome(options=options)

def extract_article_info(url: str):
    driver = create_driver()
    driver.get(url)
    time.sleep(2.0)
    soup = BeautifulSoup(driver.page_source, "lxml")
    driver.quit()

    try:
        # 제목
        title_tag = soup.select_one("h1.tit01")
        title = title_tag.get_text(strip=True) if title_tag else "[제목 없음]"

        # 본문
        content_paragraphs = soup.select("div.article p, div.story-news p")
        if not content_paragraphs:
            raise ValueError("본문 없음")
        content = "\n".join(
            p.get_text(strip=True)
            for p in content_paragraphs
            if p.get_text(strip=True)
        )
                # 본문이 아예 없으면 건너뜀
        if not content.strip():
            print(f"⚠️ 본문 없음: {url}")
            return None


        # 날짜
        published_div = soup.select_one("div#newsUpdateTime01")
        published_time = published_div.get("data-published-time") if published_div else "[날짜 없음]"

        return {
            "url": url,
            "title": title,
            "date": published_time,
            "content": content,
        }

    except Exception as e:
        print(f"❌ 실패: {url} — {e}")
        save_failed_html(url, soup)
        log_failed_url(url)
        return None

def save_failed_html(url: str, soup):
    """실패한 페이지를 HTML로 저장"""
    article_id = url.split("/")[-1].split("?")[0]
    save_path = f"data/failed_html/{article_id}.html"
    os.makedirs(os.path.dirname(save_path), exist_ok=True)
    with open(save_path, "w", encoding="utf-8") as f:
        f.write(str(soup))

def log_failed_url(url: str):
    """실패한 URL을 로그에 기록"""
    with open("data/failed_urls.txt", "a", encoding="utf-8") as f:
        f.write(url + "\n")

def fetch_article_contents(input_path="data/urls_1year.json", output_path="data/full_articles.json"):
    if not os.path.exists(input_path):
        print(f"입력 파일이 존재하지 않습니다: {input_path}")
        return

    with open(input_path, "r", encoding="utf-8") as f:
        urls = json.load(f)

    results = []
    for url in tqdm(urls, desc="본문 수집 중"):
        info = extract_article_info(url)
        if info:
            results.append(info)

    os.makedirs(os.path.dirname(output_path), exist_ok=True)
    with open(output_path, "w", encoding="utf-8") as f:
        json.dump(results, f, ensure_ascii=False, indent=2)

    print(f"✅ 본문 수집 완료: {len(results)}건 저장됨")

