# Flutter기반 LLM활용 전세사기 예방 및 도우미 프로젝트 집피티


## 📅만든 기간
- 2025-04-09~2025-06-08

## 💻개발 환경
- **AndroidStudio Version**: 2024.2.2
- **Python Version**: 3.13.3
- **Flutter Version**:  3.29.2
- **IDE**: VisualStudioCode, AndroidStudio

## 시작하기
### 필수 조건
- **AndroidStudio 2024.2.2**: 애플리케이션 설치/실행을 위해 필요합니다.
- **Python 3.13.3**: LLM/RAG/크롤링/서버 실행을 위해 필요합니다.
- **pip**: 필요한 python모듈 설치를 위해 필요합니다. 일반적으로 Python 설치시 함께 설치됩니다
- "AndroidStudio
- **외부 API 키**: 사용을 위해 다음의 API Key가 필요합니다.
  - **OpenAI API Key**
  - **공공 데이터 포탈 Encode API Key**

## 실행하기
**1. Server실행**:  cd TeamProject-Eight\tools\crawler_project
                    uvicorn main:app --host 0.0.0.0 --port 8000 --reload

**2. Apk 파일 생성 및 설치**: AndroidStudio에서 Apk파일을 생성하여 안드로이드 플랫폼에 설치


        
