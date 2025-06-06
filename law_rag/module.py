from typing import Dict, Any

def build_document_format(input_datum: Dict[str, Any]) -> str:
    result_string = "" 
    
    if "조문제목" in input_datum:
        result_string += f"조문제목: {input_datum['조문제목']}\n"
        result_string += f"조문내용: {input_datum['조문내용']}\n"
                
    if "항" in input_datum:
        for i in input_datum["항"]:
            if "항내용" in i:
                result_string += i["항내용"]+"\n"
                if "호" in i:
                    for j in i["호"]:
                        if "호내용" in j:
                            result_string += j["호내용"]+"\n"
                        if "목" in j:       
                            for k in j["목"]:
                                result_string += k["목내용"]+"\n"
            else:
                for j in input_datum["항"]["호"]:
                    result_string += j["호내용"]+"\n" 
                    if "목" in j:       
                                for k in j["목"]:
                                    result_string += k["목내용"]+"\n"      
    result_string += "\n";                                            
    return result_string
 

