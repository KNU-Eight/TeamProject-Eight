import re

# kiwi 에서 사용가능한 유효한 문단인지 확인 true/false 반환
def is_valid_para(para, KEYWORDS):
    if len(para) < 30 or not re.search(r'[가-힣]', para):
        return False
    return any(k in para for k in KEYWORDS)

# 유효한 문단리스트 만들기
def make_paragraphs(lines):
    result = []
    buffer = ""

    for line in lines:
        line = line.strip()
        if re.match(r'^[□ㅇ*\-△➍①②③④⑤⑥⑦⑧⑨]', line):  # 문단 기호가 시작되면 새 문단
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
# 문단 하나하나가 따로 들어 있는 리스트 그대로 반환
    return result
