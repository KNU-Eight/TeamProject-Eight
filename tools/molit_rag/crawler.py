from selenium import webdriver
from selenium.webdriver.chrome.service import Service
from selenium.webdriver.common.by import By
from webdriver_manager.chrome import ChromeDriverManager
from selenium.webdriver.chrome.options import Options

from trafilatura import fetch_url, extract
from trafilatura.settings import use_config
from bs4 import BeautifulSoup
from pandas import date_range
from urllib.parse import quote
from tqdm import tqdm
import argparse
import ujson as json
import time
import os


# 설정
config = use_config()
config.set("DEFAULT", "MIN_OUTPUT_SIZE", "50")
config.set("DEFAULT", "DOWNLOAD_TIMEOUT", "5")

# 예시 URL => 이 URL은 실제로 존재하는 기사 URL입니다.
# 이 URL은 실제 링크 예시로 테스트용입니다. 
url = "https://www.chosun.com/economy/real_estate/2025/05/26/RU5SPV4NCFGY5PJEUQOPAZYGO4/?utm_source=naver&utm_medium=referral&utm_campaign=naver-news"

downloaded = fetch_url(url)
extracted = extract(downloaded, config=config, output_format="json")

if extracted:
    article_json = json.loads(extracted)
    print(article_json["title"])
    print(article_json["text"][:500])
else:
    print("트라필라투라 실패!!!")
# 
# 크롬 드라이버 설정 함수
def setup_driver(headless=True):
    options = Options()
    if headless:
        options.add_argument("--headless=new") # 브라우저 화면 없이 백그라운드 실행
    options.add_argument("--disable-gpu")
    options.add_argument("--no-sandbox")
    driver = webdriver.Chrome(service=Service(ChromeDriverManager().install()), options=options)
    return driver

# 네이버 뉴스에서 기사 URL 수집하는 함수
def get_news_urls(driver, query, date):
    encoded_query = quote(query)
    search_url = (
        f"https://search.naver.com/search.naver?where=news&query={encoded_query}"
        f"&nso=so:r,p:from{date}to{date},a:all"
    )

    driver.get(search_url)
    time.sleep(2) #렌더링 대기

    soup = BeautifulSoup(driver.page_source, "lxml")
    article_links = []

    # 각 기사 박스(div)마다 하나의 a태그만 추출
    for box in soup.select("div.ReYy3VL54WHrWUymgceQ"):
        a_tag = box.find("a", href=True)  # 가장 먼저 나오는 <a> 하나만 가져옴
        span_tag = box.find("span", class_="sds-comps-text-type-headline1") # 제목 텍스트
        if a_tag:
            href = a_tag["href"]
            if href.startswith("http") and "media.naver.com/press" not in href:
                title = span_tag.get_text(strip=True) if span_tag else "제목 없음"
                article_links.append((href, title))

    return list(set(article_links))  # 중복 제거
# 기사 본문 추출하는는 함수 =>  t
def get_article_content(url: str):
    try:
        print(f"\n URL 요청 중: {url}")
        downloaded = fetch_url(url)
        if not downloaded:
            print(" fetch_url 실패: HTML을 가져오지 못함")
            return None

        extracted = extract(downloaded, config=config, output_format="json")
        if not extracted:
            print(" extract 실패: 본문 추출 안 됨")
            return None

        article = json.loads(extracted)
        
        print(" 추출 성공! 제목:", article.get("query_title", "없음"))
        print("본문 일부:", article)
        return article

    except Exception as e:
        print(f" 예외 발생: {e}")
        return None

# 전체 뉴스 수집 파이프라인
def crawl_news(query: str, start_date: str, end_date: str, output_path: str):
    dates = date_range(start=start_date, end=end_date, freq="D")
    driver = setup_driver()

    crawled_articles = []
    visited_urls = set()

    for date in tqdm(dates, desc="날짜별 수집 중"):
        date_str = date.strftime("%Y%m%d")
        urls = get_news_urls(driver, query, date_str)
        print(f"[{date_str}] 수집된 뉴스 URL 개수: {len(urls)}")
        print(urls[:5]) 
        for url,title in urls:
            if url not in visited_urls:
                article = get_article_content(url)
                if article:
                    article["query_title"] = title
                    crawled_articles.append(article)
                visited_urls.add(url)
        time.sleep(1)

    driver.quit()

    with open(output_path, "w", encoding="utf-8") as f:
        json.dump(crawled_articles, f, ensure_ascii=False)
if __name__ == "__main__":
    parser = argparse.ArgumentParser()
    parser.add_argument("--query", type=str, default="전세사기기")
    parser.add_argument("--start-date", type=str, default="2025.01.10")
    parser.add_argument("--end-date", type=str, default="2025.05.12")
    parser.add_argument("--output-path", type=str, default="naver_news.json")
    args = parser.parse_args()

    crawl_news(args.query, args.start_date, args.end_date, args.output_path)
