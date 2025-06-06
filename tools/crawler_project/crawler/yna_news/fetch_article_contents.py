import requests
from bs4 import BeautifulSoup
import json
import os
from tqdm import tqdm

def extract_article_info(url: str):
    try:
        headers = {
            "User-Agent": "Mozilla/5.0 (Windows NT 10.0; Win64; x64)"
        }
        response = requests.get(url, headers=headers, timeout=10)
        response.raise_for_status()

        soup = BeautifulSoup(response.text, "lxml")

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
        save_failed_html(url, soup if 'soup' in locals() else "")
        log_failed_url(url)
        return None


def save_failed_html(url: str, soup):
    article_id = url.split("/")[-1].split("?")[0]
    save_path = f"data/failed_html/{article_id}.html"
    os.makedirs(os.path.dirname(save_path), exist_ok=True)
    with open(save_path, "w", encoding="utf-8") as f:
        f.write(str(soup))


def log_failed_url(url: str):
    with open("data/failed_urls.txt", "a", encoding="utf-8") as f:
        f.write(url + "\n")


def fetch_article_contents(input_path, output_path):
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

    print(f"📄 본문 수집 완료: {len(results)}건 저장됨")
