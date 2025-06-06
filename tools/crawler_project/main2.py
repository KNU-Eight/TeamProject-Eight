import os
import json
import numpy as np
import uvicorn
import openai
import faiss

from fastapi import FastAPI, HTTPException
from pydantic import BaseModel
from dotenv import load_dotenv
from fastapi.middleware.cors import CORSMiddleware
from crawler.molit.extractor.embedding_service import embed_texts
from contextlib import asynccontextmanager # Lifespan을 위해 추가

# .env 파일에서 환경 변수 로드
load_dotenv()

# OpenAI 클라이언트 초기화
try:
    client = openai.OpenAI()
    print("OpenAI client initialized.")
except Exception as e:
    print(f"Error initializing OpenAI client: {e}")
    client = None

OPENAI_MODEL = "gpt-4o-mini"

# Lifespan 함수 정의
@asynccontextmanager
async def lifespan(app: FastAPI):
    print("Server startup: Loading search data and building FAISS index...")
    try:
        with open("search/embedded_chunks.json", "r", encoding="utf-8") as f:
            search_data_list = json.load(f)
        
        texts = [item["text"] for item in search_data_list]
        vectors = np.array([item["emAbedding"] for item in search_data_list]).astype("float32")

        if vectors.size == 0:
            print("Warning: No embeddings found in 'embedded_chunks.json'. Search will not work.")
            app.state.faiss_index = None
            app.state.search_data = []
        else:
            faiss.normalize_L2(vectors)
            index_dim = vectors.shape[1]
            index = faiss.IndexFlatIP(index_dim)
            index.add(vectors)
            
            app.state.faiss_index = index # app.state에 저장
            app.state.search_data = search_data_list # app.state에 저장
            print(f"FAISS index with {index.ntotal} vectors is ready and stored in app.state.")

    except FileNotFoundError:
        print("Warning: 'search/embedded_chunks.json' not found. The /search endpoint will not be available.")
        app.state.faiss_index = None
        app.state.search_data = []
    except Exception as e:
        print(f"An error occurred during search data loading: {e}")
        app.state.faiss_index = None
        app.state.search_data = []
    
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
async def chat_with_llm(request: PromptRequest):
    if client is None:
        raise HTTPException(status_code=500, detail="OpenAI client is not initialized.")
    try:
        print(f"Received prompt for /chat: {request.prompt}")
        completion = client.chat.completions.create(
            model=OPENAI_MODEL,
            messages=[{"role": "user", "content": request.prompt}]
        )
        llm_response_text = completion.choices[0].message.content
        print(f"LLM response: {llm_response_text}")
        return LLMResponse(response=llm_response_text)

    except openai.AuthenticationError as e:
        raise HTTPException(status_code=401, detail=f"OpenAI Authentication Error: {e}")
    except openai.APIError as e:
        raise HTTPException(status_code=500, detail=f"OpenAI API Error: {e}")
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"An internal server error occurred: {e}")

@app.post("/search")
def search(req: SearchRequest, request: Request): # 엔드포인트에서 app.state에 접근하기 위해 Request 객체 주입
    """
    사용자의 쿼리를 임베딩하여 FAISS에서 유사한 문서를 찾는 엔드포인트
    """
    # app.state에서 faiss_index와 search_data를 가져옴
    faiss_index_instance = request.app.state.faiss_index
    search_data_list = request.app.state.search_data

    if faiss_index_instance is None or search_data_list is None:
        raise HTTPException(status_code=503, detail="Search service is not available. Check server logs.")

    print(f"Received query for /search: {req.query}")
    
    query_vec = embed_texts([req.query])[0]
    query_vec = np.array([query_vec], dtype="float32")
    faiss.normalize_L2(query_vec)

    distances, indices = faiss_index_instance.search(query_vec, req.top_k)
    
    results = []
    for i, dist in zip(indices[0], distances[0]):
        if i != -1:
            item = search_data_list[i]
            results.append({
                "text": item["text"],
                "title": item.get("title", ""),
                "date": item.get("date", ""),
                "similarity": round(float(dist), 4)
            })
            
    print(f"Found {len(results)} results for query.")
    return results


if __name__ == "__main__":
    print("Starting FastAPI server with lifespan events...")
    uvicorn.run("main:app", host="0.0.0.0", port=8000, reload=True)