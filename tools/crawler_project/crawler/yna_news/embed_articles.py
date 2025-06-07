import json
import os, sys
base_dir = os.path.abspath(os.path.join(os.path.dirname(__file__), "..", ".."))
sys.path.append(base_dir)
from crawler.yna_news.embedding_service import embed_texts
from tqdm import tqdm

# INPUT_PATH = "data/full_articles.json"
# OUTPUT_PATH = "search/embedded_chunks.json"

data_dir = os.path.join(base_dir, "data", "yna_news")

input_path = os.path.join(data_dir, "full_articles_1year.json")
output_path = os.path.join(data_dir, "embedded_chunks.json")

os.makedirs(data_dir, exist_ok=True)

def load_articles(path):
    with open(path, "r", encoding="utf-8") as f:
        return json.load(f)

def save_embedded_data(data, path):
    os.makedirs(os.path.dirname(path), exist_ok=True)
    with open(path, "w", encoding="utf-8") as f:
        json.dump(data, f, ensure_ascii=False, indent=2)

def chunk_text(text, max_length=800):
    # 긴 기사 본문을 적당히 문단 단위로 쪼갬
    paragraphs = text.split("\n")
    chunks = []
    current_chunk = []

    for p in paragraphs:
        if len(" ".join(current_chunk + [p])) > max_length:
            if current_chunk:
                chunks.append("\n".join(current_chunk))
                current_chunk = [p]
            else:
                chunks.append(p)
        else:
            current_chunk.append(p)

    if current_chunk:
        chunks.append("\n".join(current_chunk))

    return chunks

def main():
    articles = load_articles(input_path)
    embedded_results = []

    print(f"총 {len(articles)}개의 기사 처리 중...")

    for article in tqdm(articles):
        content = article.get("content", "").strip()
        if not content:
            continue

        chunks = chunk_text(content)
        embeddings = embed_texts(chunks)

        for chunk, embedding in zip(chunks, embeddings):
            embedded_results.append({
                "text": chunk,
                "embedding": embedding,
                "title": article.get("title", ""),
                "date": article.get("date", ""),
                "url": article.get("url", "")
            })

    save_embedded_data(embedded_results, output_path)
    print(f"✅ 저장 완료: {output_path} ({len(embedded_results)} chunks)")

if __name__ == "__main__":
    main()
