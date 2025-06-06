# main.py
from fastapi import FastAPI, HTTPException, Response
from pydantic import BaseModel
import uvicorn
import os
from dotenv import load_dotenv
from fastapi.middleware.cors import CORSMiddleware
from bjd_code_parsing import bjd_code_parsing as BCP
import pandas as pd
import json

# .env 파일에서 환경 변수 로드
load_dotenv()

import openai

try:
    client = openai.OpenAI()
    print("OpenAI client initialized.")
except Exception as e:
    print(f"Error initializing OpenAI client: {e}")
    client = None

OPENAI_MODEL = "gpt-4o-mini"

app = FastAPI()

origins = [
    "http://localhost",
    "http://localhost:8000", # FastAPI 서버 주소 (브라우저에서 직접 접근 시)
    "http://127.0.0.1",
    "http://127.0.0.1:8000",
    "http://localhost:5000",
    "http://127.0.0.1:5000",
]
# origins = [
#     "http://localhost",
#     "http://localhost:8000",
#     "http://10.0.2.2:8000", # Android 에뮬레이터에서 접근 시
# ]

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

class PromptRequest(BaseModel):
    prompt: str # 사용자가 입력한 질문

class LLMResponse(BaseModel):
    response: str # LLM의 응답 텍스트



# LLM과 통신하는 엔드포인트 정의
@app.post("/chat", response_model=LLMResponse)
async def chat_with_llm(request: PromptRequest):
    if client is None:
         raise HTTPException(status_code=500, detail="OpenAI 클라이언트가 초기화되지 않았습니다. API 키 설정을 확인하세요.")

    try:
        print(f"Received prompt: {request.prompt}") # 요청받은 프롬프트 로그 출력

        # OpenAI Chat Completions API 호출
        # 여기서 프롬프트 정의!
        completion = client.chat.completions.create(
            model=OPENAI_MODEL,
            messages=[
                {"role": "user", "content": request.prompt} # 사용자의 프롬프트
            ],
            # max_tokens=150 # 응답 최대 길이 제한 (선택 사항)
        )

        llm_response_text = completion.choices[0].message.content

        print(f"LLM response: {llm_response_text}") # LLM 응답 로그 출력

        # LLM 응답을 Flutter 앱으로 전송할 형식에 맞춰 반환
        return LLMResponse(response=llm_response_text)

    except openai.AuthenticationError as e:
        print(f"OpenAI Authentication Error: {e}")
        raise HTTPException(status_code=401, detail="OpenAI API 인증에 실패했습니다. API 키를 확인하세요.")
    except openai.APIError as e:
         print(f"OpenAI API Error: {e}")
         raise HTTPException(status_code=500, detail=f"OpenAI API 호출 중 에러 발생: {e}")
    except Exception as e:
        # 그 외 예외 처리
        print(f"An unexpected error occurred: {e}")
        raise HTTPException(status_code=500, detail=f"서버 내부 에러 발생: {e}")

@app.get("/sido_code")
async def parse_sido_code():
    try:
        bjd_code_df = pd.read_csv('../assets/config/bjd_code.csv')
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
        bjd_code_df = pd.read_csv('../assets/config/bjd_code.csv')
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


if __name__ == "__main__":
    print("Starting FastAPI server...")
    uvicorn.run(app, host="0.0.0.0", port=8000, reload=True)