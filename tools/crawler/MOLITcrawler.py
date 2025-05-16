import requests
import json
import os
from bs4 import BeautifulSoup


# 국토교통부 보도자료 크롤링
BASE_URL = "https://www.molit.go.kr/USR/NEWS/m_71/lst.jsp"
DETAIL_BASE_URL = "https://www.molit.go.kr/USR/NEWS/m_71/"


def crawl_press_list(page=1):
    params = {"page": page}
    res = requests.get(BASE_URL, params=params)
    res.encoding = "utf-8"  
    soup = BeautifulSoup(res.text, "html.parser")

    table = soup.select_one("table.bd_tbl")
    rows = table.select("tbody > tr")

    result = []
    for row in rows:
        number = row.select_one("td.bd_num").text.strip()
        title_tag = row.select_one("td.bd_title a")
        title = title_tag.text.strip()
        link = DETAIL_BASE_URL + title_tag['href'].replace("&amp;", "&")  # 상대 경로 처리
        category = row.select_one("td.bd_field").text.strip()
        date = row.select_one("td.bd_date").text.strip()
        views = row.select_one("td.bd_inquiry").text.strip()

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
   
    # PDF 첨부파일 링크 추출출
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
                    print(pdf_path)
                except :
                    print("다운로드 중 에러 발생")
                break
                    
                
        