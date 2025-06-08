import fitz
# pdf 의 내용을 추출 => 그냥 라인별로 추출
def extract_pdf_text(filepath):
    text = ""
    with fitz.open(filepath) as doc:
        for page in doc:
            text += page.get_text() 
    lines = [line.strip() for line in text.splitlines() if line.strip()]
    return lines
