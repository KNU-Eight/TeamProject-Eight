import tiktoken
import requests
from typing import Dict, Any
import numpy as np
from tqdm import tqdm
from dotenv import load_dotenv
from litellm import embedding
from litellm import completion


load_dotenv()
tokenizer = tiktoken.encoding_for_model("text-embedding-3-small")

OC = "tery95"
query = "전세사기피해자 지원 및 주거안정에 관한 특별법"

#주택임대차보호법 법령ID 가져오기
base_url = (
    f"http://www.law.go.kr/DRF/lawSearch.do?OC={OC}"
    "&target=law"
    f"&query={query}"
    "&type=JSON" 
)

#print(base_url)
res = requests.get(base_url)



#조문 가져오기
ID = res.json()["LawSearch"]["law"][0]["법령ID"]
#print(ID)
base_url = (
    f"http://www.law.go.kr/DRF/lawService.do?OC={OC}"
    "&target=law"
    f"&ID={ID}"
    "&type=JSON" 
)

res = requests.get(base_url)
data = res.json()["법령"]["조문"]["조문단위"]


def build_document_format(input_datum: Dict[str, Any]) -> str:
    result_string = "" 
    
    if "조문제목" in input_datum:
        result_string += f"조문제목: {input_datum['조문제목']}\n"
    result_string += f"조문내용: {input_datum['조문내용']}\n"
                
    if "항" in input_datum:
        for i in input_datum["항"]:
            if "항내용" in i:
                result_string += i["항내용"]+"\n"
                if "호" in i:
                    for j in i["호"]:
                        if "호내용" in j:
                            result_string += j["호내용"]+"\n"
                        if "목" in j:       
                            for k in j["목"]:
                                result_string += k["목내용"]+"\n"
            else:
                for j in input_datum["항"]["호"]:
                    result_string += j["호내용"]+"\n"                               
    return result_string
 

response = embedding("openai/text-embedding-3-large", ["전세 계약을 갱신하지 않고싶어"])
embedding_vector = np.array(response.data[0]["embedding"])

EMBEDDING_MODEL = "text-embedding-3-large"

CHUNK_SIZE = 20
MAX_TOKENS = 8000


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
     

embeddings = np.array([item["embedding"] for item in data])

query = "전세사기피해 지원 절차 알려줘"

query_embedding = embedding(model=EMBEDDING_MODEL, input=query).data[0]["embedding"]
query_embedding = np.array(query_embedding)

TOP_K = 5

cosine_sims = embeddings.dot(query_embedding)
top_indices = np.argsort(cosine_sims)[::-1][:TOP_K]
        
SYSTEM_PROMPT = """

###지시###
너는 주어진 법률을 가지고 질문에 답변하는 AI야.
오직 주어진 법률만을 가지고 답변해. 만약 주어진 법률에 정보가 없다면, "죄송합니다. 질문을 이해하지 못했어요."라고 답변을 해.                                    
""".strip()

document_strings = ""
for i, top_index in enumerate(top_indices):
    document_strings += f"[{i+1}번째 법률]\n"
    document_strings += build_document_format(data[top_index])
    document_strings += "\n\n"

document_strings = document_strings.strip()
    
USER_PROMPT = f"""
{query}

###법률###
{document_strings}

""".strip()    

output = completion(
    model="gpt-4o-mini",
    messages=[
        {"role": "system", "content": SYSTEM_PROMPT},
        {"role": "user", "content": USER_PROMPT},
    ],
    temperature=0.0,
    seed=42,
)
print(output.choices[0].message.content)
  