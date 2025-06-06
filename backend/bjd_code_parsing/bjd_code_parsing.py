import pandas as pd

def parse_bjd_sido_code():
    try:
        bjd_code_df = pd.read_csv('../assets/config/bjd_code.csv')
        bjd_code_df.columns = [
            "code",
            "bjd_name",
            "is_abolition"
        ]

        if bjd_code_df["code"][0] == "1100000000":
            print("true")
        bjd_code_df = bjd_code_df[bjd_code_df["is_abolition"] != "폐지"]
        sido_df = bjd_code_df[bjd_code_df["code"].apply(lambda x: str(x)[2:] == '0' * (len(str(x)) - 2))]
        print(sido_df)
    except Exception as e:
        print(f'법정동 코드 파싱 에러 {e}')
    return sido_df

def parse_bjd_sgg_code(sido_code):
    try:
        bjd_code_df = pd.read_csv('../assets/config/bjd_code.csv')
        bjd_code_df.columns = [
            "code",
            "bjd_name",
            "is_abolition"
        ]

        bjd_code_df = bjd_code_df[bjd_code_df["is_abolition"] != "폐지"]
        sgg_df = bjd_code_df[bjd_code_df["code"].apply(lambda x: str(x)[2:] != '0' * (len(str(x)) - 2) and str(x)[5:] == '0' * (len(str(x)) - 5) and str(x)[:2] == str(sido_code)[:2])]
        print(sgg_df)
    except Exception as e:
        print(f'법정동 코드 파싱 에러 {e}')
    return sgg_df