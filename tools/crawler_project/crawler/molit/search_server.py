from fastapi import FastAPI
from pydantic import BaseModel
from crawler.molit.extractor.embedding_service import embed_texts

import faiss
import numpy as np
import json
import os

app = FastAPI()

class SearchRequest(BaseModel):
    query: str
    top_k: int = 5

base_dir = os.path.abspath(os.path.join(os.path.dirname(__file__), "..", ".."))
cache_dir = os.path.join(base_dir, "cache")

index = faiss.read_index(os.path.join(cache_dir, "faiss.index"))
with open(os.path.join(cache_dir, "combined_data.json"), encoding="utf-8") as f:
    combined_data = json.load(f)
@app.post("/search")
def search(req: SearchRequest):
    query_vec = embed_texts([req.query])[0]
    query_vec = np.array([query_vec], dtype="float32")
    faiss.normalize_L2(query_vec)

    max_search = min(100, index.ntotal)  # 안전한 최대값
    search_k = req.top_k * 2
    seen_texts = set()
    results = []

    while search_k <= max_search:
        distances, indices = index.search(query_vec, search_k)
        results.clear()
        seen_texts.clear()

        for i, dist in zip(indices[0], distances[0]):
            item = combined_data[i]
            text = item["text"]
            if text in seen_texts:
                continue
            results.append({
                "text": text,
                "title": item.get("title", ""),
                "date": item.get("date", "")
            })
            seen_texts.add(text)
            if len(results) >= req.top_k:
                return results

        search_k *= 2  # 더 많이 검색해보기

    return results  # 최종적으로 부족하더라도 반환
