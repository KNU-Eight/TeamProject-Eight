import tiktoken
import numpy as np
import ujson as json
from litellm import embedding
from module import build_document_format

embeddings = []
EMBEDDING_MODEL = "text-embedding-3-small"
tokenizer = tiktoken.encoding_for_model("text-embedding-3-small")

# 주택임대차보호법 임베딩 후 변수 embeddings에 추가
with open("housing_lease_protection_act.json", "r") as f:
    data = json.load(f)
for i in range(0, len(data), 1):
    input_string = build_document_format(data[i])
    response = embedding(model=EMBEDDING_MODEL, input=input_string)
    embeddings.append({"text": input_string, "embedding": response.data[0]["embedding"]})

# 전세사기피해자 지원 및 주거안정에 관한 특별법 임베딩 후 변수 embeddings에 추가
with open("jeonse_special_act.json", "r") as f:
    data = json.load(f)
for i in range(0, len(data), 1):
    input_string = build_document_format(data[i])
    response = embedding(model=EMBEDDING_MODEL, input=input_string)
    embeddings.append({"text": input_string, "embedding": response.data[0]["embedding"]})
        
    
with open("law_embedding_v2.json", "w", encoding="utf-8") as f:
        json.dump(embeddings, f, ensure_ascii=False, indent=2)
