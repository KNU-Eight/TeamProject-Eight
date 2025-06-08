import os
import requests
#PDF 다운로드 함수 
def download_pdf(url,filename, dir ="MOLITpdfs"):
    os.makedirs(dir,exist_ok=True)   #pdf 저장할 폴더 생성 => 폴더있으면 패스
    filepath = os.path.join(dir, filename + ".pdf") #"MOLIZTpdfs/도로교통사망자감소대책.pdf"
    if os.path.exists(filepath):
        return filepath
    
    res = requests.get(url)

    with open(filepath, "wb")as f:
        f.write(res.content)
    return filepath #저장된 파일의 경로
