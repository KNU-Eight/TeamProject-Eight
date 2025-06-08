import os
import json
import numpy as np
import pandas as pd
import uvicorn
import openai
import faiss
from pathlib import Path

from fastapi import FastAPI, HTTPException, Request, Response
from pydantic import BaseModel
from dotenv import load_dotenv
from fastapi.middleware.cors import CORSMiddleware
from crawler.molit.extractor.embedding_service import embed_texts
from contextlib import asynccontextmanager
from typing import List
from pathlib import Path

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

# --- 뉴스 요약을 위한 전역 변수 ---
summarized_news: List['SummaryOutput'] = []

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

    # --- 뉴스 요약 로직을 lifespan에 포함 ---
    print("🔄 Summarizing news articles...")
    try:
        base_dir = Path(__file__).resolve().parent  # summarize_api.py 위치
        file_path = base_dir / "data" / "yna_news" / "full_articles_recent.json"
        with Path(file_path).open("r", encoding="utf-8") as f:
            articles = json.load(f)

        global summarized_news
        summarized_news = [
            SummaryOutput(title=article["title"], summary=generate_summary(article["content"]), url=article["url"])
            for article in articles
        ]
        print(f"Summarized {len(summarized_news)} news articles.")
    except Exception as e:
        print(f"[시작 중 오류] 기사 요약 실패: {e}")


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

class SummaryOutput(BaseModel):
    title: str
    summary: str
    url: str

# 뉴스 요약 함수
def generate_summary(content: str, max_tokens: int = 300) -> str:
    prompt = f"""다음 뉴스 기사를 친구에게 설명하듯이 쉽게 요약해줘.
어려운 말은 쓰지 말고 쉽고 자연스럽게 알려줘. 반말은 하지마. 친절하고 어려운 부분엔 부연설명을 달아서 해줘\n\n{content}\n\n요약:"""
    try:
        response = client.chat.completions.create(
            model="gpt-4o-mini",
            messages=[{"role": "user", "content": prompt}],
            max_tokens=max_tokens,
            temperature=0.7,
        )
        return response.choices[0].message.content.strip()
    except Exception as e:
        raise RuntimeError(f"요약 실패: {e}")

@app.post("/chat", response_model=LLMResponse)
async def chat_with_llm(request: PromptRequest, http_request: Request):
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

base_dir = Path(__file__).resolve().parent.parent
bjd_code_path = base_dir.parent / 'assets' / 'config' / 'bjd_code.csv'

@app.get("/sido_code")
async def parse_sido_code():
    try:
        bjd_code_df = pd.read_csv(bjd_code_path)
        bjd_code_df.columns = [
            "code",
            "bjd_name",
            "is_abolition"
        ]

        if bjd_code_df["code"][0] == "1100000000":
            print("true")
        bjd_code_df = bjd_code_df[bjd_code_df["is_abolition"] != "폐지"]
        sido_df = bjd_code_df[bjd_code_df["code"].apply(lambda x: str(x)[2:] == '0' * (len(str(x)) - 2))]
        sido_json = sido_df.to_json(orient="records")
        sido_json = json.dumps(json.loads(sido_json), ensure_ascii=False)
        print(sido_json)
    except Exception as e:
        print(f'법정동 코드 파싱 에러 {e}')
    return Response(content=sido_json, media_type="application/json")

@app.get("/sgg_code")
async def parse_bjd_sgg_code(sido_code: int):
    try:
        bjd_code_df = pd.read_csv(bjd_code_path)
        bjd_code_df.columns = [
            "code",
            "bjd_name",
            "is_abolition"
        ]

        bjd_code_df = bjd_code_df[bjd_code_df["is_abolition"] != "폐지"]
        sgg_df = bjd_code_df[bjd_code_df["code"].apply(lambda x: str(x)[2:] != '0' * (len(str(x)) - 2) and str(x)[5:] == '0' * (len(str(x)) - 5) and str(x)[:2] == str(sido_code)[:2])]
        sgg_json = sgg_df.to_json(orient="records")
        sgg_json = json.dumps(json.loads(sgg_json), ensure_ascii=False)
    except Exception as e:
        print(f'법정동 코드 파싱 에러 {e}')
    return Response(content=sgg_json, media_type="application/json")

@app.get("/news", response_model=List[SummaryOutput])
async def get_summarized_news():
    if not summarized_news:
        raise HTTPException(status_code=500, detail="요약된 뉴스가 없습니다.")
    return summarized_news

if __name__ == "__main__":
    print("Starting FastAPI server with lifespan events...")
    uvicorn.run("main:app", host="0.0.0.0", port=8000, reload=True)