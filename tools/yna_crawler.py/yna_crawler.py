import requests
from bs4 import BeautifulSoup
from urllib.parse import quote
from tqdm import tqdm
import time

# 기사 링크만 수집 
def extract_article_links_only(query, max_pages=5):
    encoded_query = quote(query)
    base_url = "https://www.yna.co.kr/search/index"
    headers = {"User-Agent": "Mozilla/5.0"}
    all_urls = set()

    for page in tqdm(range(1, max_pages + 1), desc="페이지 수집 중"):
        url = f"{base_url}?query={encoded_query}&page={page}&site=default"
        res = requests.get(url, headers=headers)
        if res.status_code != 200:
            print(f"❌ {page}페이지 요청 실패: {res.status_code}")
            continue

        soup = BeautifulSoup(res.text, "lxml")

        anchors = soup.select("div.item-box01 a[href^='https://www.yna.co.kr/view/']")
        print(f"[{page}페이지] 기사 수: {len(anchors)}")

        for a in anchors:
            href = a.get("href")
            if href and href.startswith("https://www.yna.co.kr/view/"):
                all_urls.add(href)

        time.sleep(0.5)

    return list(all_urls)

# 테스트 실행
if __name__ == "__main__":
    query = "전세사기"
    links = extract_article_links_only(query, max_pages=5)
    print(f"\n✅ 총 추출된 기사 링크 수: {len(links)}\n")
    for url in links[:10]:
        print(url)
