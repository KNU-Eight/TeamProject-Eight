from fetch_links_recent import fetch_recent_links
from fetch_article_contents import fetch_article_contents

if __name__ == "__main__":
    print("🟢 [최근] 뉴스 링크 수집 시작...")
    fetch_recent_links(
        query="전세사기",
        max_pages=3,
        output_path="data/urls_recent.json"
    )

    print("🟢 [최근] 뉴스 본문 수집 시작...")
    fetch_article_contents(
        input_path="data/urls_recent.json",
        output_path="data/full_articles_recent.json"
    )
