
from fetch_links_recent import fetch_recent_links
from fetch_links_1year import fetch_links_1year
from fetch_article_contents import fetch_article_contents
import os
project_root = os.path.abspath(os.path.join(os.path.dirname(__file__), "..", ".."))
data_dir = os.path.join(project_root, "data")
chunk_path = os.path.join(data_dir, "chunks.json")

if __name__ == "__main__":
    print("🟢 최근 뉴스 링크 수집 중...")
    fetch_recent_links()

    print("🟢 3개월 치 뉴스 링크 수집 중...")
    fetch_links_1year()

    print("🟢 본문 수집 중...")
    fetch_article_contents()

    print("✅ 연합뉴스 뉴스탭 수집 완료!")
