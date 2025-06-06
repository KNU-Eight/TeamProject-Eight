import ujson as json
import numpy as np
from litellm import embedding
from litellm import completion
from module import build_document_format

# 주택임대차보호법 & 특별법 json 
with open("housing_lease_protection_act.json", "r") as f:
    data = json.load(f)
with open("jeonse_special_act.json", "r") as f:
    data += json.load(f)
embeddings = np.loadtxt("law_embedding.txt", delimiter = " ")

query = "전세사기당했어"
EMBEDDING_MODEL = "text-embedding-3-large"


query_embedding = embedding(model=EMBEDDING_MODEL, input=query).data[0]["embedding"]
query_embedding = np.array(query_embedding)


TOP_K = 5

cosine_sims = embeddings.dot(query_embedding)
top_indices = np.argsort(cosine_sims)[::-1][:TOP_K]
        
        
SYSTEM_PROMPT = """

###지시###
너는 주어진 법률을 가지고 사용자를 도와주는 AI야.
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

  