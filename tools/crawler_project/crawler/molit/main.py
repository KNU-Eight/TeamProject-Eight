from crawler.list_crawler import crawl_press_list
from crawler.detail_filelink import get_filelink
from crawler.downloader import download_pdf
from extractor.text_extractor import extract_pdf_text
from extractor.paragraph_splitter import make_paragraphs, is_valid_para
from extractor.embedding_service import embed_texts
import requests
import os
import json
import logging

base_dir = os.path.dirname(__file__)  # main.py가 있는 디렉토리
chunk_path = os.path.join(base_dir, "search", "chunks.json")
embedding_path = os.path.join(base_dir, "search", "embedded_chunks.json")

KEYWORDS = ["전세사기", "깡통전세", "보증금", "피해자", "지원", "공공임대", "임대차", "계약", "%", "공시", "공급"]


if __name__ == "__main__":
    chunks=[]
    #국토부 보도자료 5페이지까지크롤링
    for page in range(1, 6): 
        articles=crawl_press_list(page=page)
    # 각 기사 상세마다 pdf 파일 링크 가져오기
    # __ attatchments에 붙이기
    for article in articles:
        attachments= get_filelink(article['link'])
        article["attachments"]= attachments
       
        for item in attachments:
            if "file_url" in item:
                try:
                    # pdf 파일 다운로드
                    # 라인별로 텍스트 추출
                    # 유효한 문단으로 정제 (불필요한 기호, 끝맺음 정리리)
                    pdf_path = download_pdf(item["file_url"], article["filename"])
                    lines = extract_pdf_text(pdf_path)
                    paragraphs=make_paragraphs(lines)
                    
                
                    # 유효한 문단인지 확인 (문단이 너무 짧지 않은지, 한글로 되어있는지 )
                    for para in paragraphs:
                        if is_valid_para(para,KEYWORDS):
                            chunks.append({
                                 "text": para,
                                "title": article["title"],
                                "date": article["date"],
                                "link":item["file_url"]
                                
                            })
    
                 # 예외처리리    
                except requests.exceptions.RequestException as e:
                    logging.error(f" PDF 다운로드 실패: {item['file_url']} - {e}")

                except (OSError, IOError) as e:
                    logging.error(f" 파일 저장 또는 열기 실패: {article['title']}.pdf - {e}")

                except Exception as e:
                    logging.error(f"Error - {e}")
                    
                    
    #search/chunks.json에 저장
    os.makedirs(os.path.dirname(chunk_path), exist_ok=True)          
    with open(chunk_path, "w", encoding="utf-8") as f:
        json.dump(chunks, f, ensure_ascii=False, indent=2)
    print(f"\n 완료! 총 {len(chunks)}개 문단 저장 → chunks.json")
    
    
    #문단 임베딩
    texts = [item["text"] for item in chunks] #문단 텍스트 리스트를 만든다.
    vectors = embed_texts(texts)

    embedded_chunks = []
    #z zip으로 벡터와 문단을 합쳐서 만든다.
    for item, vector in zip(chunks, vectors):
        item_with_embedding = item.copy()
        item_with_embedding["embedding"] = vector
        embedded_chunks.append(item_with_embedding)

    with open(embedding_path, "w", encoding="utf-8") as f:
        json.dump(embedded_chunks, f, ensure_ascii=False, indent=2)
    print(f"✅ 임베딩 저장 완료 → {embedding_path}")