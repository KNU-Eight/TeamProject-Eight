import os
import json
from fastapi import FastAPI, HTTPException
from pydantic import BaseModel
from typing import List
from dotenv import load_dotenv
from openai import OpenAI
from pathlib import Path

# -------------------------
# 환경 변수 및 OpenAI 설정
# -------------------------
load_dotenv()
client = OpenAI(api_key=os.getenv("OPENAI_API_KEY_DEV"))
app = FastAPI()

# -------------------------
# 모델 정의
# -------------------------
class SummaryOutput(BaseModel):
    title: str
    summary: str

# -------------------------
# 요약 함수
# -------------------------
def generate_summary(content: str, max_tokens: int = 300) -> str:
    prompt = f"""다음 뉴스 기사를 친구에게 설명하듯이 쉽게 요약해줘.
어려운 말은 쓰지 말고 쉽고 자연스럽게 알려줘. 반말은 하지마. 친절하고 어려운 단어는 한번 더 친절하게 설명해줘. 전세임대에 대해 모르는 사람도 이해하기기 쉽게 해줘. \n\n{content}\n\n요약:"""
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

# -------------------------
# 서버 시작 시 기사 요약
# -------------------------
summarized_news: List[SummaryOutput] = []

@app.on_event("startup")
async def startup_event():
    try:
        base_dir = Path(__file__).resolve().parent  # summarize_api.py 위치
        file_path = base_dir / "data" / "yna_news" / "full_articles_recent.json"

        with file_path.open("r", encoding="utf-8") as f:
            articles = json.load(f)

        global summarized_news
        summarized_news = [
            SummaryOutput(title=article["title"], summary=generate_summary(article["content"]))
            for article in articles
        ]
    except Exception as e:
        print(f"[시작 중 오류] 기사 요약 실패: {e}")

# -------------------------
# GET /news
# -------------------------
@app.get("/news", response_model=List[SummaryOutput])
async def get_summarized_news():
    if not summarized_news:
        raise HTTPException(status_code=500, detail="요약된 뉴스가 없습니다.")
    return summarized_news
