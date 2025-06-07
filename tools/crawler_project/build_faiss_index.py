import os
import json
import numpy as np
import faiss

# 🔧 1. 데이터 경로 설정
base_dir = os.path.abspath(os.path.dirname(__file__))
paths = [
    os.path.join(base_dir, "data", "molit", "embedded_chunks.json"),
    os.path.join(base_dir, "data", "yna_news", "embedded_chunks.json"),
    os.path.join(base_dir, "data", "laws","law_embedding_v2.json"),  

]

combined_data = []
for path in paths:
    if os.path.exists(path):
        with open(path, encoding="utf-8") as f:
            combined_data.extend(json.load(f))
            
    else:
        print(f"❗ 파일 없음: {path}")

# 🔧 2. 벡터 추출 및 인덱스 생성
vectors = np.array([item["embedding"] for item in combined_data], dtype="float32")
faiss.normalize_L2(vectors)
index = faiss.IndexFlatIP(vectors.shape[1])
index.add(vectors)

# 🔧 3. 저장할 디렉토리 준비
cache_dir = os.path.join(base_dir, "cache")
os.makedirs(cache_dir, exist_ok=True)


faiss.write_index(index, os.path.join(cache_dir, "faiss.index"))
with open(os.path.join(cache_dir, "combined_data.json"), "w", encoding="utf-8") as f:
    json.dump(combined_data, f, ensure_ascii=False, indent=2)

print("✅ 인덱스 저장 완료! (faiss.index, combined_data.json)")
