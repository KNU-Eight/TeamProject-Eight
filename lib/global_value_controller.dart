import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:xml/xml.dart' as xml;

class GlobalValueController extends GetxController{
  var screenHeight = 0.0.obs;
  var screenWidth = 0.0.obs;
  var selectedSiDoValue = {"전체": 0}.obs;
  var selectedSggValue = {"전체": 0}.obs;
  var siDoList = {"전체": 0}.obs;
  var sggList = {"전체": 0}.obs;
  var siDoUpdated = false.obs;
  var dangerObject = [];

  void updateScreenHeight(double screenHeight){
    this.screenHeight.value = screenHeight;
    update();
  }

  void updateScreenWidth(double screenWidth){
    this.screenWidth.value = screenWidth;
    update();
  }

  Future<void> initSiDoList() async {
    final String backendUrl = "http://10.0.2.2:8000/sido_code";
    try{
      var url = Uri.parse(backendUrl);
      final response = await http.get(url, headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },);
      if (response.statusCode == 200) {
        List<Map<String, dynamic>> responseData = List<Map<String, dynamic>>.from(jsonDecode(response.body));
        for(Map<String, dynamic> data in responseData){
          siDoList[data["bjd_name"]] = data["code"];
        }
        siDoUpdated.value = true;
      }
    } catch(e){
      print("bjd_code_parse_error: $e");
    }
    update();
  }

  Future<void> getSggList() async {
    print(selectedSiDoValue);
    final String backendUrl = "http://10.0.2.2:8000/sgg_code?sido_code=${selectedSiDoValue.values.first}";
    sggList.value = {"전체": 0};
    selectedSggValue.value = {"전체": 0};
    try{
      var url = Uri.parse(backendUrl);
      final response = await http.get(url, headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },);
      if (response.statusCode == 200) {
        List<Map<String, dynamic>> responseData = List<Map<String, dynamic>>.from(jsonDecode(response.body));
        for(Map<String, dynamic> data in responseData){
          sggList[data["bjd_name"].replaceAll(selectedSiDoValue.keys.first, "").trim()] = data["code"];
        }
        print(sggList);
      }
    } catch(e){
      print("bjd_code_parse_error: $e");
    }
    update();
  }

  Future<void> getDepositAndSellPrice()async {    //공공데이터 포탈에서 지역의 매매가 및 전세가를 불러오는 함수
    DateTime now = DateTime.now();
    int year = now.year;
    int month = now.month;
    Map<String, int> sell = {};
    Map<String, int> deposit = {};
    for(int i = 0; i < 3; i++){
      month = month - 1;
      if(month <= 0){
        year -= 1;
        month = 12;
      }
      String yearMonth = '';
      if(month < 10){
        yearMonth = '${year}0$month';
      } else{
        yearMonth = '$year$month';
      }
      final int code = (selectedSggValue.values.first / 100000).toInt();
      await dotenv.load(fileName: 'assets/config/.env');
      String? decodeKey = dotenv.env['PUBLIC_DATA_ENCODE_KEY'];
      final String sellPriceUrl = 'https://apis.data.go.kr/1613000/RTMSDataSvcAptTrade/getRTMSDataSvcAptTrade?LAWD_CD=$code&DEAL_YMD=$yearMonth&serviceKey=$decodeKey';
      final String depositUrl = 'https://apis.data.go.kr/1613000/RTMSDataSvcAptRent/getRTMSDataSvcAptRent?LAWD_CD=$code&DEAL_YMD=$yearMonth&serviceKey=$decodeKey';
      print(depositUrl);
      try{
        var depositUri = Uri.parse(depositUrl);
        final depositResponse = await http.get(depositUri);
        if (depositResponse.statusCode == 200){
          final document = xml.XmlDocument.parse(depositResponse.body);
          final items = document.findAllElements('item');

          for (var item in items) {
            String aptName = item.findElements('aptNm').single.innerText;
            String buildYear = item.findElements('buildYear').single.innerText;
            String deposit = item.findElements('deposit').single.innerText;
            String monthlyRent = item.findElements('monthlyRent').single.innerText;
            print('아파트: $aptName, 건축 연도: $buildYear, 전세 보증금: $deposit, 월세: $monthlyRent');
            sell[aptName] = int.parse(deposit.replaceAll(',', ''));
          }
        } else {
          print('데이터를 가져오지 못했습니다.');
        }
        var sellPriceUri = Uri.parse(sellPriceUrl);
        final sellPriceResponse = await http.get(sellPriceUri);
        if (sellPriceResponse.statusCode == 200){
          print(sellPriceResponse.body);
          final document = xml.XmlDocument.parse(sellPriceResponse.body);
          final items = document.findAllElements('item');

          for (var item in items) {
            String aptName = item.findElements('aptNm').single.innerText;
            String buildYear = item.findElements('buildYear').single.innerText;
            String sellPrice = item.findElements('dealAmount').single.innerText;
            print('아파트: $aptName, 건축 연도: $buildYear, 매매가: $sellPrice');
            deposit[aptName] = int.parse(sellPrice.replaceAll(',', ''));
          }
        } else {
          print('데이터를 가져오지 못했습니다.');
        }
      } catch(e){
        print('get deposit err: $e');
      }
    }
    print(sell);
    print(deposit);

  }
}