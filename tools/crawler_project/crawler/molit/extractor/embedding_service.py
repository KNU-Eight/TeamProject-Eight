from openai import OpenAI
from dotenv import load_dotenv
import os
# 오픈 ai로 문단 리스트 임베딩
load_dotenv()
client = OpenAI(api_key=os.getenv("OPENAI_API_KEY_DEV"))


def embed_texts(texts):
    response = client.embeddings.create(model="text-embedding-3-small", input=texts)
    return [item.embedding for item in response.data]
