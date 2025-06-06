import tiktoken
import numpy as np
import ujson as json
from litellm import embedding
from module import build_document_format

# 주택임대차보호법 임베딩 후 변수 embeddings에 추가
with open("housing_lease_protection_act.json", "r") as f:
    data = json.load(f)
tokenizer = tiktoken.encoding_for_model("text-embedding-3-large")
CHUNK_SIZE = 20
MAX_TOKENS = 8000
EMBEDDING_MODEL = "text-embedding-3-large"

for i in range(0, len(data), CHUNK_SIZE):
    chunk_items = data[i : i + CHUNK_SIZE]
        
    input_strings = []
    for item in chunk_items:
        input_string = build_document_format(item)
        tokens = tokenizer.encode(input_string)[:MAX_TOKENS]
        input_string = tokenizer.decode(tokens)        
        input_strings.append(input_string)
                
    response = embedding(model=EMBEDDING_MODEL, input=input_strings)
        
    for j, item in enumerate(chunk_items):
        item["embedding"] = response.data[j]["embedding"]
     
embeddings = [item["embedding"] for item in data]

# 전세사기피해자 지원 및 주거안정에 관한 특별법 임베딩 후 변수 embeddings에 추가
with open("jeonse_special_act.json", "r") as f:
    data = json.load(f)
for i in range(0, len(data), CHUNK_SIZE):
    chunk_items = data[i : i + CHUNK_SIZE]
        
    input_strings = []
    for item in chunk_items:
        input_string = build_document_format(item)
        tokens = tokenizer.encode(input_string)[:MAX_TOKENS]
        input_string = tokenizer.decode(tokens)        
        input_strings.append(input_string)
                
    response = embedding(model=EMBEDDING_MODEL, input=input_strings)
        
    for j, item in enumerate(chunk_items):
        item["embedding"] = response.data[j]["embedding"]
embeddings += [item["embedding"] for item in data]
embeddings = np.array(embeddings) 
print(embeddings)     
np.savetxt("law_embedding.txt", embeddings, delimiter = " ")
    

