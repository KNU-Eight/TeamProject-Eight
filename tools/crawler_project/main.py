import os
import json
import numpy as np
import uvicorn
import openai
import faiss

from fastapi import FastAPI, HTTPException, Request
from pydantic import BaseModel
from dotenv import load_dotenv
from fastapi.middleware.cors import CORSMiddleware
from crawler.molit.extractor.embedding_service import embed_texts
from contextlib import asynccontextmanager # Lifespan을 위해 추가

# .env 파일에서 환경 변수 로드
load_dotenv()

# OpenAI 클라이언트 초기화
try:
    client = openai.OpenAI(api_key=os.getenv("OPENAI_API_KEY_DEV"))
    print("OpenAI client initialized.")
except Exception as e:
    print(f"Error initializing OpenAI client: {e}")
    client = None

OPENAI_MODEL = "gpt-4o-mini"

base_dir = os.path.abspath(os.path.dirname(__file__))
cache_dir = os.path.join(base_dir, "cache")
# Lifespan 함수 정의
@asynccontextmanager
async def lifespan(app: FastAPI):
    print("🔄 Loading FAISS index and reference data...")
    try:
        faiss_index = faiss.read_index(os.path.join(cache_dir, "faiss.index"))
        with open(os.path.join(cache_dir, "combined_data.json"), encoding="utf-8") as f:
            reference_data = json.load(f)

        app.state.faiss_index = faiss_index
        app.state.reference_data = reference_data
        print(f"Loaded FAISS index ({faiss_index.ntotal} vectors) and reference data.")

    except Exception as e:
        print(f" Failed to load search data: {e}")
        app.state.faiss_index = None
        app.state.reference_data = []

    yield
    print("Server shutdown: Cleaning up resources...")

# FastAPI 앱 인스턴스 생성 시 lifespan 전달
app = FastAPI(lifespan=lifespan)

# CORS 미들웨어 설정
origins = [
    "http://localhost",
    "http://localhost:8000",
    "http://10.0.2.2:8000",
]

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# --- Pydantic 모델 정의 ---
class PromptRequest(BaseModel):
    prompt: str

class LLMResponse(BaseModel):
    response: str

class SearchRequest(BaseModel):
    query: str
    top_k: int = 3
    
    
@app.post("/chat", response_model=LLMResponse)
async def chat_with_llm(request: PromptRequest, http_request: Request):  # ← Request 객체 추가
    if client is None:
        raise HTTPException(status_code=500, detail="OpenAI client is not initialized.")

    try:
        print(f"Received prompt for /chat: {request.prompt}")

        # --- 1. FAISS 검색 로직 포함 ---
        index = app.state.faiss_index 
        search_data_list = app.state.reference_data

        if index is None or not search_data_list:
            raise HTTPException(status_code=503, detail="Search index not available.")

        query_vec = embed_texts([request.prompt])[0]
        query_vec = np.array([query_vec], dtype="float32")
        faiss.normalize_L2(query_vec)

        top_k = 10 # 검색할 문단 수
        distances, indices = index.search(query_vec, top_k)

        context_chunks = []
        for i in indices[0]:
            if i != -1:
                item = search_data_list[i]
                context_chunks.append(item["text"])

        if not context_chunks:
            raise HTTPException(status_code=404, detail="No relevant context found.")

        context_text = "\n\n".join(f"- {chunk}" for chunk in context_chunks)

        messages = [
            {
                "role": "system",
                "content": (
                            "당신은 전세사기 및 임대 정책에 대해 신뢰성 있고 친절하게 설명하는 AI 비서입니다. "
            "다음은 참고 문단입니다. 반드시 이 내용을 기반으로 해요체로 쉽게 설명해주세요.\n\n"
            "사용자의 질문에 대해 이 내용을 바탕으로 정확하고 친절하게 답변해주세요. 이모티콘도 적절히 사용하면서 따뜻하고 친절한 말투로 해주세요. "
            "전세 임대에 대해 잘 모르는 사회초년생이라고 생각하고 답변을 해주세요. 어려운 용어에서는 쉽게 설명을 덧붙여 주세요.\n\n"
            f"{context_text}"
                )
            },
            {
                "role": "user",
                "content": request.prompt
            }
        ]
        
        # --- 3. LLM 호출 ---
        completion = client.chat.completions.create(
            model=OPENAI_MODEL,
            messages=messages
        )

        llm_response_text = completion.choices[0].message.content
        return LLMResponse(response=llm_response_text)

    except openai.AuthenticationError as e:
        raise HTTPException(status_code=401, detail=f"OpenAI Authentication Error: {e}")
    except openai.APIError as e:
        raise HTTPException(status_code=500, detail=f"OpenAI API Error: {e}")
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"An internal server error occurred: {e}")

# @app.post("/search")
# def search(req: SearchRequest, request: Request):
#     index = request.app.state.faiss_index
#     search_data_list = request.app.state.reference_data  

#     if index is None or not search_data_list:
#         raise HTTPException(status_code=503, detail="Search index not available.")

#     query_vec = embed_texts([req.query])[0]
#     query_vec = np.array([query_vec], dtype="float32")
#     faiss.normalize_L2(query_vec)

#     max_search = min(100, index.ntotal)
#     search_k = req.top_k * 2
#     seen_texts = set()
#     results = []

#     while search_k <= max_search:
#         distances, indices = index.search(query_vec, search_k)
#         results.clear()
#         seen_texts.clear()

#         for i, dist in zip(indices[0], distances[0]):
#             item = search_data_list[i]
#             text = item["text"]
#             if text in seen_texts:
#                 continue
#             results.append({
#                 "text": text,
#                 "title": item.get("title", ""),
#                 "date": item.get("date", ""),
#                 "similarity": round(float(dist), 4)
#             })
#             seen_texts.add(text)
#             if len(results) >= req.top_k:
#                 return results

#         search_k *= 2

#     return results


if __name__ == "__main__":
    print("Starting FastAPI server with lifespan events...")
    uvicorn.run("main:app", host="0.0.0.0", port=8000, reload=True)