import fitz

path = "https://www.molit.go.kr/LCMS/DWN.jsp?fold=koreaNews/mobile/file&fileName=250507%28%EC%A1%B0%EA%B0%84%29+%EC%8A%A4%EB%A7%88%ED%8A%B8%EA%B1%B4%EC%84%A4%EC%9D%98+%EB%AF%B8%EB%9E%98%EB%A5%BC+%EC%9D%B4%EB%81%8C%EC%96%B4%EB%82%98%EA%B0%88+%EA%B0%95%EC%86%8C%EA%B8%B0%EC%97%85+%EB%AA%A8%EC%A7%91%28%EA%B8%B0%EC%88%A0%EC%A0%95%EC%B1%85%EA%B3%BC%29.pdf"
doc = fitz.open(path)
for page in doc:
    text = page.get_text()
    print(text)

