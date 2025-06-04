import requests
from bs4 import BeautifulSoup

#====보도자료 상세에서 pdf파일의 링크를 가져온다====
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