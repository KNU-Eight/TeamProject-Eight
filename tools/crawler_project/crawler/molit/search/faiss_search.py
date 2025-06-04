#로컬에서 테스트할 때 쓰는 스크립트


import json
import numpy as np
import faiss
import sys
import os


from crawler.molit.extractor.embedding_service import embed_texts

# 데이터 로드
with open("crawler/molit/search/embedded_chunks.json", "r", encoding="utf-8") as f:
    data = json.load(f)

texts = [item["text"] for item in data]
vectors = np.array([item["embedding"] for item in data]).astype("float32")

# FAISS 인덱스 생성
embedding_dim = len(vectors[0])
index = faiss.IndexFlatL2(embedding_dim)  # L2 거리 기반
index.add(vectors)
print(f"인덱스 등록 완료: {len(texts)}개 문단")

# 검색 함수
def search_similar_paragraphs(query, top_k=5):
    query_vec = embed_texts([query])[0]
    query_vec = np.array([query_vec], dtype="float32")

    distances, indices = index.search(query_vec, top_k)

    print(f"\n사용자 질문: {query}")
    for rank, (idx, dist) in enumerate(zip(indices[0], distances[0]), 1):
        print(f"[{rank}] 거리: {dist:.4f}")
        print(f"문단: {texts[idx]}\n")

# 테스트
if __name__ == "__main__":
    search_similar_paragraphs("보증금 반환 절차가 궁금해요", top_k=3)
