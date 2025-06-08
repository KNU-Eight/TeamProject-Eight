# import os
# import json
# import logging
# import requests
# import uvicorn
# from tqdm import tqdm

# from crawler.list_crawler import crawl_press_list
# from crawler.detail_filelink import get_filelink
# from crawler.downloader import download_pdf
# from extractor.text_extractor import extract_pdf_text
# from extractor.paragraph_splitter import make_paragraphs, is_valid_para
# from extractor.embedding_service import embed_texts


# base_dir = os.path.dirname(__file__)
# chunk_path = os.path.join(base_dir, "search", "chunks.json")
# embedding_path = os.path.join(base_dir, "search", "embedded_chunks.json")

# KEYWORDS = ["전세사기", "깡통전세", "보증금", "피해자", "지원", "공공임대", "임대차", "계약", "%", "공시", "공급"]

# def run_crawling_and_embedding():
#     chunks = []

#     print("📄 국토부 보도자료 크롤링 시작")
#     for page in range(1, 6):  # 1~5 페이지 크롤링
#         articles = crawl_press_list(page=page)
#         for article in articles:
#             attachments = get_filelink(article['link'])
#             article["attachments"] = attachments
#             for item in attachments:
#                 if "file_url" in item:
#                     try:
#                         pdf_path = download_pdf(item["file_url"], article["filename"])
#                         lines = extract_pdf_text(pdf_path)
#                         paragraphs = make_paragraphs(lines)

#                         for para in paragraphs:
#                             if is_valid_para(para, KEYWORDS):
#                                 chunks.append({
#                                     "text": para.strip(),
#                                     "title": article["title"],
#                                     "date": article["date"],
#                                     "link": item["file_url"]
#                                 })

#                     except requests.exceptions.RequestException as e:
#                         logging.error(f"PDF 다운로드 실패: {item['file_url']} - {e}")
#                     except (OSError, IOError) as e:
#                         logging.error(f"파일 저장 실패: {article['title']}.pdf - {e}")
#                     except Exception as e:
#                         logging.error(f"기타 에러: {e}")

#     os.makedirs(os.path.dirname(chunk_path), exist_ok=True)
#     with open(chunk_path, "w", encoding="utf-8") as f:
#         json.dump(chunks, f, ensure_ascii=False, indent=2)
#     print(f"\n📦 완료! 총 {len(chunks)}개 문단 저장 → {chunk_path}")

#     # 임베딩 전 필터링
#     texts = [item["text"] for item in chunks if isinstance(item["text"], str) and item["text"].strip()]
#     vectors = batch_embed_texts(texts, batch_size=50)

#     embedded_chunks = []
#     for item, vector in zip(chunks, vectors):
#         item_with_embedding = item.copy()
#         item_with_embedding["embedding"] = vector
#         embedded_chunks.append(item_with_embedding)

#     with open(embedding_path, "w", encoding="utf-8") as f:
#         json.dump(embedded_chunks, f, ensure_ascii=False, indent=2)
#     print(f"✅ 임베딩 저장 완료 → {embedding_path}")

# def batch_embed_texts(texts, batch_size=50):
#     all_vectors = []
#     print(f"\n🔄 문단 {len(texts)}개 임베딩 중...")
#     for i in tqdm(range(0, len(texts), batch_size), desc="Embedding"):
#         batch = texts[i:i + batch_size]
#         batch = [t for t in batch if isinstance(t, str) and t.strip()]
#         try:
#             vectors = embed_texts(batch)
#             all_vectors.extend(vectors)
#         except Exception as e:
#             logging.error(f"❌ 임베딩 실패 (index {i}): {e}")
#     return all_vectors

# if __name__ == "__main__":
#     run_crawling_and_embedding()
#     uvicorn.run("crawler.molit.search.search_server:app", host="0.0.0.0", port=8000, reload=True)
