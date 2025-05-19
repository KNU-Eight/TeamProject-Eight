from crawler.list_crawler import crawl_press_list
from crawler.detail_filelink import get_filelink
from crawler.downloader import download_pdf
from extractor.text_extractor import extract_pdf_text
from extractor.paragraph_splitter import make_paragraphs, is_valid_para

import os
import json
import logging

base_dir = os.path.dirname(__file__)  # main.py가 있는 디렉토리
chunk_path = os.path.join(base_dir, "search", "chunks.json")

KEYWORDS = ["전세사기", "깡통전세", "보증금", "피해자", "지원", "공공임대", "임대차", "계약", "%", "공시", "공급"]


if __name__ == "__main__":
    chunks=[]
    for page in range(1, 6):  # 5페이지
        articles=crawl_press_list(page=page)
    for article in articles:
        attachments= get_filelink(article['link'])
        article["attachments"]= attachments
        # print(article)
        # print(json.dumps(article, ensure_ascii=False, indent=2))
        for item in attachments:
            if "file_url" in item:
                # print(item["file_url"], article["title"])
                try:
                    pdf_path = download_pdf(item["file_url"], article["filename"])
                    lines = extract_pdf_text(pdf_path)
                    paragraphs=make_paragraphs(lines)
                    
                  
                    # print("=" * 80)
                    # print(pdf_text)
                    # print("=" * 80)
                    # 키워드 중심으로 문단을 추출하기
                    for para in paragraphs:
                        if is_valid_para(para,KEYWORDS):
                            chunks.append({
                                 "text": para,
                                "title": article["title"],
                                "date": article["date"],
                                "link":item["file_url"]
                                
                            })
    
                     
                except requests.exceptions.RequestException as e:
                    logging.error(f" PDF 다운로드 실패: {item['file_url']} - {e}")

                except (OSError, IOError) as e:
                    logging.error(f" 파일 저장 또는 열기 실패: {article['title']}.pdf - {e}")

                except Exception as e:
                    logging.error(f"Error - {e}")
    os.makedirs(os.path.dirname(chunk_path), exist_ok=True)          
    with open(chunk_path, "w", encoding="utf-8") as f:
        json.dump(chunks, f, ensure_ascii=False, indent=2)
    print(f"\n 완료! 총 {len(chunks)}개 문단 저장 → chunks.json")
                
        