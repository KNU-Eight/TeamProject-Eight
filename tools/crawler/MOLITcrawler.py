import requests
import json
import os
import fitz
import logging

from bs4 import BeautifulSoup
from pdfminer.high_level import extract_text
from pdfminer.layout import LAParams

# 국토교통부 보도자료 크롤링
BASE_URL = "https://www.molit.go.kr/USR/NEWS/m_71/lst.jsp"
DETAIL_BASE_URL = "https://www.molit.go.kr/USR/NEWS/m_71/"


def crawl_press_list(page=1):
    params = {"page": page }
    res = requests.get(BASE_URL, params=params)
    res.encoding = "utf-8"  
    soup = BeautifulSoup(res.text, "html.parser")

    table = soup.select_one("table.bd_tbl")
    rows = table.select("tbody > tr")

    result = []
    for row in rows:
        # number = row.select_one("td.bd_num").text.strip()
        title_tag = row.select_one("td.bd_title a")
        title = title_tag.text.strip()
        link = DETAIL_BASE_URL + title_tag['href'].replace("&amp;", "&")  # 상대 경로 처리
        category = row.select_one("td.bd_field").text.strip()
        date = row.select_one("td.bd_date").text.strip()
        # views = row.select_one("td.bd_inquiry").text.strip()
        if category != "주택토지":
            continue

        result.append({
            # "number": number,
            "title": title,
            "link": link,
            "category": category,
            "date": date,
            # "views": views,
        })

    return result 

#보도자료 상세에서 파일의 링크를 가져온다
def get_filelink(link):
    res = requests.get(link)
    res.encoding = "utf-8"
    soup = BeautifulSoup(res.text, "html.parser")
    attachments = [] # article에 파일제목과 파일링크를 붙일 예정정
   
    # PDF 첨부파일 링크 추출한다. 
    file_tags = soup.select(".file span a[target='_hiddenframe']")    #파일 링크 a 태그
    
    # 각 보도자료 하나 당 하나의 pdf 파일 
    if file_tags:
        tag= file_tags[0]
        file_url = "https://www.molit.go.kr" + tag.get("href")
        attachments.append({
            "file_url": file_url
        })
    return  attachments
#PDF 다운로드 함수 
def download_pdf(url,filename, dir ="MOLITpdfs"):
    os.makedirs(dir,exist_ok=True)   #pdf 저장할 폴더 생성 => 폴더있으면 패스
    filepath = os.path.join(dir, filename + ".pdf") #"MOLIZTpdfs/도로교통사망자감소대책.pdf"
    # headers = {
    #     "User-Agent": (
    #         "Mozilla/5.0 (Windows NT 10.0; Win64; x64) "
    #         "AppleWebKit/537.36 (KHTML, like Gecko) "
    #         "Chrome/123.0.0.0 Safari/537.36"
    #     ),
    #     "Referer": "https://www.molit.go.kr/USR/NEWS/m_71/lst.jsp"
    # }
    res = requests.get(url)

    with open(filepath, "wb")as f:
        f.write(res.content)
    return filepath #저장된 파일의 경로로

def extract_pdf_text(filepath):
    text = ""
    with fitz.open(filepath) as doc:
        for page in doc:
            text += page.get_text() 
    lines = [line.strip() for line in text.splitlines() if line.strip()]
    return lines

def paragraph_join(lines):
    import re
    result = []
    buffer = ""

    for line in lines:
        line = line.strip()
        if re.match(r'^[□ㅇ*\-]', line):  # 문단 기호가 시작되면 새 문단
            if buffer:
                result.append(buffer.strip())
            buffer = line
        else:
            buffer += " " + line

        if line.endswith(("다.", "요.", "니다.", ".", "?")) and len(buffer) > 50:
            result.append(buffer.strip())
            buffer = ""

    if buffer:
        result.append(buffer.strip())

    return "\n\n".join(result)
if __name__ == "__main__":
    articles = crawl_press_list(page=1)
    for article in articles:
        attachments= get_filelink(article['link'])
        article["attachments"]= attachments
        # print(article)
        # print(json.dumps(article, ensure_ascii=False, indent=2))
        for item in attachments:
            if "file_url" in item:
                # print(item["file_url"], article["title"])
                try:
                    pdf_path = download_pdf(item["file_url"], article["title"])
                    lines = extract_pdf_text(pdf_path)
                    pdf_text=paragraph_join(lines)
                  
                    print("=" * 80)
                    print(pdf_text)
                    print("=" * 80)

                     
                except requests.exceptions.RequestException as e:
                    logging.error(f" PDF 다운로드 실패: {item['file_url']} - {e}")

                except (OSError, IOError) as e:
                    logging.error(f" 파일 저장 또는 열기 실패: {article['title']}.pdf - {e}")

                except Exception as e:
                    logging.error(f"Error - {e}")
                break
                    
                
        