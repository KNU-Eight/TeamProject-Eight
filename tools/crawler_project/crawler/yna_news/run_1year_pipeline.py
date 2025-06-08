from fetch_links_1year import fetch_links_1year
from fetch_article_contents import fetch_article_contents
import os
base_dir = os.path.abspath(os.path.join(os.path.dirname(__file__), "..", ".."))
data_dir = os.path.join(base_dir, "data", "yna_news")

urls_path = os.path.join(data_dir, "urls_1year.json")
articles_path = os.path.join(data_dir, "full_articles_1year.json")

os.makedirs(data_dir, exist_ok=True)
if __name__ == "__main__":
    print("🟢 1년 치 뉴스 링크 수집 시작...")
    fetch_links_1year(
        keywords=["전세사기", "보증금", "깡통전세", "보증보험", "피해자"],
        max_pages=100,
        output_path=urls_path
    )

    print("🟢 1년 치 뉴스 본문 수집 시작...")
    fetch_article_contents(
        input_path=urls_path,
        output_path=articles_path
    )
