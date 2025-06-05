#API 서버로 외부 요청을 받을 때 실행하는 진짜 서비스용

# 이제 모듈 import
from fastapi import FastAPI, Request
from pydantic import BaseModel
from crawler.molit.extractor.embedding_service import embed_texts

import faiss
import json
import numpy as np

app = FastAPI()

import os

base_dir = os.path.dirname(__file__)
embedding_path = os.path.join(base_dir, "search", "embedded_chunks.json")

with open(embedding_path, encoding="utf-8") as f:
    data = json.load(f)

texts = [item["text"] for item in data]
vectors = np.array([item["embedding"] for item in data]).astype("float32")
faiss.normalize_L2(vectors)
index = faiss.IndexFlatIP(vectors.shape[1])
index.add(vectors)

class SearchRequest(BaseModel):
    query: str
    top_k: int = 3

@app.post("/search")
def search(req: SearchRequest):
    query_vec = embed_texts([req.query])[0]
    query_vec = np.array([query_vec], dtype="float32")
    faiss.normalize_L2(query_vec)

    distances, indices = index.search(query_vec, req.top_k)
    results = []

    for i, dist in zip(indices[0], distances[0]):
        results.append({
            "text": data[i]["text"],
            "title": data[i].get("title", ""),
            "date": data[i].get("date", ""),
            "similarity": round(float(dist), 4)
        })

    return results
