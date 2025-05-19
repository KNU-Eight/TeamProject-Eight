# import requests
# import os
# import fitz
# import logging
# import re
# import json
# from kiwipiepy import Kiwi
# from typing import List

# from bs4 import BeautifulSoup
# # from pdfminer.high_level import extract_text
# # from pdfminer.layout import LAParams



# # 국토교통부 보도자료 크롤링
# BASE_URL = "https://www.molit.go.kr/USR/NEWS/m_71/lst.jsp"
# DETAIL_BASE_URL = "https://www.molit.go.kr/USR/NEWS/m_71/"
# KEYWORDS = ["전세사기", "깡통전세", "보증금", "피해자", "지원", "공공임대", "임대차", "계약", "%", "공시", "공급"]


# if __name__ == "__main__":
#     chunks=[]
#     for page in range(1, 6):  # 5페이지
#         articles=crawl_press_list(page=page)
#     for article in articles:
#         attachments= get_filelink(article['link'])
#         article["attachments"]= attachments
#         # print(article)
#         # print(json.dumps(article, ensure_ascii=False, indent=2))
#         for item in attachments:
#             if "file_url" in item:
#                 # print(item["file_url"], article["title"])
#                 try:
#                     pdf_path = download_pdf(item["file_url"], article["filename"])
#                     lines = extract_pdf_text(pdf_path)
#                     paragraphs=make_paragraphs(lines)
                    
                  
#                     # print("=" * 80)
#                     # print(pdf_text)
#                     # print("=" * 80)
#                     # 키워드 중심으로 문단을 추출하기
#                     for para in paragraphs:
#                         if is_valid_para(para):
#                             chunks.append({
#                                  "text": para,
#                                 "title": article["title"],
#                                 "date": article["date"],
#                                 "link":item["file_url"]
                                
#                             })
    
                     
#                 except requests.exceptions.RequestException as e:
#                     logging.error(f" PDF 다운로드 실패: {item['file_url']} - {e}")

#                 except (OSError, IOError) as e:
#                     logging.error(f" 파일 저장 또는 열기 실패: {article['title']}.pdf - {e}")

#                 except Exception as e:
#                     logging.error(f"Error - {e}")
                    
#     with open("chunks.json", "w", encoding="utf-8") as f:
#         json.dump(chunks, f, ensure_ascii=False, indent=2)
#     print(f"\n 완료! 총 {len(chunks)}개 문단 저장 → chunks.json")
                
        