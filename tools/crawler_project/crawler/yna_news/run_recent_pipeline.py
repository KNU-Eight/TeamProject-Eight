from fetch_links_recent import fetch_recent_links
from fetch_article_contents import fetch_article_contents
import os

base_dir = os.path.abspath(os.path.join(os.path.dirname(__file__), "..", ".."))
data_dir = os.path.join(base_dir, "data", "yna_news")

urls_path = os.path.join(data_dir, "urls_recent.json")
articles_path = os.path.join(data_dir, "full_articles_recent.json")

# 폴더 없으면 자동 생성
os.makedirs(data_dir, exist_ok=True)
if __name__ == "__main__":
    print("🟢 [최근] 뉴스 링크 수집 시작...")
    fetch_recent_links(
        query="전세사기",
        max_pages=3,
        output_path=urls_path
    )

    print("🟢 [최근] 뉴스 본문 수집 시작...")
    fetch_article_contents(
        input_path=urls_path,
        output_path=articles_path
    )
