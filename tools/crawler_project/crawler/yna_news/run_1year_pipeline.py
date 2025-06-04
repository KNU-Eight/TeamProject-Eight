from fetch_links_1year import fetch_links_1year
from fetch_article_contents import fetch_article_contents

if __name__ == "__main__":
    print("🟢 3개월 치 뉴스 링크 수집 시작...")
    fetch_links_1year(
        keywords=["전세사기", "보증금", "깡통전세", "보증보험", "피해자"],
        max_pages=100,
        output_path="data/urls_1year.json"
    )

    print("🟢 3개월 치 뉴스 본문 수집 시작...")
    fetch_article_contents(
        input_path="data/urls_1year.json",
        output_path="data/full_articles_1year.json"
    )
