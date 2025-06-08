import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:prevent_rental_fraud/global_value_controller.dart';
import 'package:prevent_rental_fraud/widgets/news_list_builder.dart';

class HomePage extends StatefulWidget {
  const HomePage({
    super.key,
    required this.onPageChange
  });
  final Function(int) onPageChange;

  @override
  createState() => _HomePageState();
}
class _HomePageState extends State<HomePage>{
  var valueController = Get.find<GlobalValueController>();
  bool _essentialFieldFilled = false;
  bool _calcButtonTouched = false;
  bool _isDanger = false;
  final List<TextEditingController> _textEditingController = List.generate(
      3, (index) => TextEditingController()
  );

  @override
  void dispose(){
    super.dispose();
    for(TextEditingController controller in _textEditingController){
      controller.dispose();
    }
  }
  @override
  void initState(){
    super.initState();
    valueController.initSiDoList();
  }

  void _showModalBottomSheet(){
    showModalBottomSheet(
      backgroundColor: Colors.white,
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (context) {
        return SafeArea(
          child: SizedBox(
              height: valueController.screenHeight.value * 0.8,
              width: valueController.screenWidth.value,
              child: Column(
                  children: [
                    Container(
                      margin: EdgeInsets.symmetric(vertical: 15),
                      height: 5,
                      width: valueController.screenWidth.value * 0.4,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(30),
                        color: Colors.grey,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 10.0),
                      child: Text(
                        "전세 계약 주의 사항", // Display title in the modal
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    Expanded(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.symmetric(horizontal: 24.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "1. 매매가격 확인하기",
                              style: TextStyle(
                                fontWeight: FontWeight.w500,
                                fontSize: 18,
                              ),
                            ),
                            Text(
                              "• 주택 시세와 보증금의 규모가 비슷한 ‘깡통주택’은 주택가격이 내려가면 보증금을 돌려받기 어려울 수 있습니다. 주택의 매매가격과 전세보증금을 비교해보고 보증금이 시세의 80%를 넘는다면 그 집은 피하는 게 좋습니다.\n",
                              style: TextStyle(
                                color: Colors.black87,
                                fontSize: 16,
                                fontFamily: 'Inter',
                                height: 1.5,
                              ),
                            ),
                            Text(
                              "2. 등기부등본 확인하기",
                              style: TextStyle(
                                fontWeight: FontWeight.w500,
                                fontSize: 18,
                              ),
                            ),
                            Text(
                              "• 소유주를 확인하고 소유권 외의 권리관계 확인하기\n",
                              style: TextStyle(
                                color: Colors.black87,
                                fontSize: 16,
                                fontFamily: 'Inter',
                                height: 1.5,
                              ),
                            ),
                            Text(
                              "3. 임대인 확인하기",
                              style: TextStyle(
                                fontWeight: FontWeight.w500,
                                fontSize: 18,
                              ),
                            ),
                            Text(
                              "• 눈앞에 있는 사람과, 계약서에 도장 찍는 임대인과 등기부등본에 적힌 주택의 소유자가 모두 동일 인물이 맞는지 확인하기\n"
                              "• 임대인에게 법적인 '행위능력'이 있는지 확인하기\n"
                              "• 만약, 주택의 소유자가 2명 이상이면 소유자 전원과 계약을 맺기를 추천합니다\n",
                              style: TextStyle(
                                color: Colors.black87,
                                fontSize: 16,
                                fontFamily: 'Inter',
                                height: 1.5,
                              ),
                            ),
                            Text(
                              "4. 대리인 확인하기",
                              style: TextStyle(
                                fontWeight: FontWeight.w500,
                                fontSize: 18,
                              ),
                            ),
                            Text(
                              "• 대리인과 계약을 체결하는 경우 위임장을 통해 대리인이 해당 주택의 임대차계약을 체결할 수 있는 권한을 정확히 위임받고 있는지 확인하기\n",
                              style: TextStyle(
                                color: Colors.black87,
                                fontSize: 16,
                                fontFamily: 'Inter',
                                height: 1.5,
                              ),
                            ),
                            Text(
                              "5. 공인중개사 확인하기",
                              style: TextStyle(
                                fontWeight: FontWeight.w500,
                                fontSize: 18,
                              ),
                            ),
                            Text(
                              "• 공인중개사 사무소가 정상적으로 영업 중인 곳이 맞는지 그리고 상대가 그곳의 공인중개사 또는 등록된 중개보조원이 맞는지 확인하기\n",
                              style: TextStyle(
                                color: Colors.black87,
                                fontSize: 16,
                                fontFamily: 'Inter',
                                height: 1.5,
                              ),
                            ),
                            Text(
                              "6. 계약내용 확인하기",
                              style: TextStyle(
                                fontWeight: FontWeight.w500,
                                fontSize: 18,
                              ),
                            ),
                            Text(
                              "• 목적물 주소 및 임차 면적 등이 등기부등본 및 건축물대장과 일치하는지 확인하기\n"
                              "• 임대인, 임차인, 공인중개사의 인적사항이 신분증과 일치 여부 확인하기\n"
                              "• 보증금 및 월세 지급 계좌 및 지급 시기 확인하기\n"
                              "• 계약 체결일 확인하기\n"
                              "• 기타 특약 사항 확인하기",
                              style: TextStyle(
                                color: Colors.black87,
                                fontSize: 16,
                                fontFamily: 'Inter',
                                height: 1.5,
                              ),
                            )
                          ],
                        ),
                      ),
                    ),
                  ]
              )
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;


    final double startPosition = 0.06;
    return GestureDetector(
      onTap: (){
        FocusManager.instance.primaryFocus?.unfocus();
      },
      child: Scaffold(
        body: Container(
          width: screenWidth,
          height: screenHeight,
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(color: const Color(0xFFF0F0F0)),
          child: Stack(
            children: [
              Positioned(   // 상단 노란색 영역
                left: 0,
                top: 0,
                child: Container(
                  width: screenWidth,
                  height: screenHeight * startPosition + 150,
                  decoration: BoxDecoration(color: const Color(0xFFFFDA62)),
                ),
              ),
              Positioned(
                left: screenWidth * startPosition,
                top: screenHeight * startPosition + 90,
                child: Text(
                  '어려운 뉴스도 요약해서 쉽게 알려드려요',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: const Color(0xFF707070),
                    fontSize: 14,
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w700,
                    height: 1,
                  ),
                ),
              ),
              Positioned(
                left: screenWidth * startPosition,
                top: screenHeight * startPosition + 60,
                child: Text(
                  '최근 뉴스 ',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 24,
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w600,
                    height: 1,
                  ),
                ),
              ),
              Positioned(
                left: screenWidth * startPosition,
                right: 10,
                top: screenHeight * startPosition,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '홈',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 36,
                        fontFamily: 'Inter',
                        fontWeight: FontWeight.w600,
                        height: 1,
                      ),
                    ),
                    ActionChip(
                      backgroundColor: const Color(0xFFFFDA62),
                      side: BorderSide(
                        color: const Color(0xFFFFDA62),
                      ),
                      elevation: 0.5,
                      shadowColor: Colors.grey,
                      label: Text(
                          "전세 계약 주의 사항",
                          style: TextStyle(
                              color: Colors.black
                          )
                      ),
                      avatar: Icon(Icons.check, color: Colors.green),
                      onPressed: (){
                        _showModalBottomSheet();
                      },
                    )
                  ],
                )
              ),
              Positioned(   //뉴스 컨테이너
                left: screenWidth * startPosition,
                top: screenHeight * startPosition + 110,
                child: NewsListBuilder(
                )
              ),
              Positioned(   //노란색 영역을 제외한 영역
                left: screenWidth,
                top: screenHeight * startPosition + 150,
                child: Container(
                  width: 162,
                  height: 77,
                  decoration: ShapeDecoration(
                    color: const Color(0xFFD9D9D9),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ),
              Positioned.fill(    //추가적인 서비스를 담는 영역
                left: 0,
                top: screenHeight * startPosition + 200,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  spacing: 10,
                  children: [
                    Expanded(   //서비스 영역 디자인 객체(노란 테두리)
                      child: Container(
                      padding: EdgeInsets.symmetric(vertical: 20),
                      margin: EdgeInsets.only(bottom: 10),
                      width: screenWidth * 0.88,
                      decoration: ShapeDecoration(
                        color: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.all(Radius.circular(30)),
                          side: BorderSide(
                            color:  const Color(0xFFFFDA62),
                            width: 4,
                            // strokeAlign: 1
                          )
                        ),
                      ),
                      child: Column(
                        children: [
                          Text(
                            "AI 서비스",
                            textAlign: TextAlign.start,
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 24,
                              fontFamily: 'Inter',
                              fontWeight: FontWeight.w700,
                              height: 1,
                            ),
                          ),
                          TextButton(
                            onPressed: (){
                              widget.onPageChange(1);
                            },
                            style: ButtonStyle(
                              backgroundColor: WidgetStateProperty.all(Colors.white),
                              fixedSize: WidgetStateProperty.all(Size(screenWidth * 0.5, 60)),
                            ),
                            child: Center(
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    '챗봇 상담 하러 가기',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      color: Colors.black,
                                      fontSize: 16,
                                      fontFamily: 'Inter',
                                      fontWeight: FontWeight.w600,
                                      height: 1,
                                    )
                                  ),
                                  Icon(Icons.arrow_right_alt)
                                ],
                              )
                            )
                          ),
                          Divider(    //AI서비스와 깡통 전세 체크 기능 구분
                            color: const Color(0xFFFFDA62),
                            thickness: 4,
                          ),
                          SizedBox(
                            height: 20,
                          ),
                          Text(
                            "깡통 전세 체크",
                            textAlign: TextAlign.start,
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 24,
                              fontFamily: 'Inter',
                              fontWeight: FontWeight.w700,
                              height: 1,
                            ),
                          ),
                          Expanded(   //지역별, 가격별 기능을 나누기 위한 TabBar 및 TabBarView영역
                            child: DefaultTabController(
                              length: 2,
                              child: Column(
                                children: [
                                  TabBar(
                                    indicatorSize: TabBarIndicatorSize.tab,
                                    indicatorColor: const Color(0xFFFFDA62),
                                    indicatorWeight: 4.0,
                                    tabs: [
                                      Tab(text: '지역별'),
                                      Tab(text: '가격별'),
                                    ],
                                    labelColor: Colors.blue,
                                    unselectedLabelColor: Colors.grey,
                                  ),
                                  Expanded(
                                    child: TabBarView(
                                      children: [
                                        Column(
                                          children: [
                                            Row(
                                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Column(
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  children: [
                                                    Text(
                                                      "시/도"
                                                    ),
                                                    Obx(() => DropdownButton<String>(   //valueController의 특정 변수 변경 시 자동 UI 업데이트. 시/도 드롭다운 버튼
                                                        value: valueController.selectedSiDoValue.keys.first,
                                                        items: valueController.siDoList.keys.map((String value){
                                                          return DropdownMenuItem<String>(
                                                            value: value,
                                                            child: Text(value),
                                                          );
                                                        }).toList(),
                                                        onChanged: (String? selectedValue) async {
                                                          valueController.selectedSiDoValue.value = {selectedValue!: valueController.siDoList[selectedValue]!};
                                                          await valueController.getSggList();
                                                        },
                                                      ),
                                                    )
                                                  ],
                                                ),
                                                Column(
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  children: [
                                                    Text(
                                                      "시/군/구"
                                                    ),
                                                    Obx(() => DropdownButton<String>(   //시/군/구 드롭다운 버튼
                                                      value: valueController.selectedSggValue.keys.first,
                                                      items: valueController.sggList.keys.map((String value){
                                                        return DropdownMenuItem<String>(
                                                          value: value,
                                                          child: Text(value),
                                                        );
                                                      }).toList(),
                                                      onChanged: (String? selectedValue){
                                                        valueController.selectedSggValue.value = {selectedValue!: valueController.sggList[selectedValue]!};
                                                      },
                                                    ),
                                                    )
                                                  ],
                                                )
                                              ]
                                            ),
                                            Obx(() => valueController.isPriceLoading.value    //깡통 전세 위험 매물을 보여줄 ListView
                                            ? CircularProgressIndicator()
                                            : Expanded(child: ListView.builder(
                                              itemCount: valueController.dangerObject.length,
                                              itemBuilder: (BuildContext context, int index) {
                                                return ListTile(
                                                  title: Text(
                                                    valueController.dangerObject[index],
                                                    textAlign: TextAlign.center,
                                                  ),
                                                  );
                                                },
                                                )
                                              )
                                            ),
                                            ElevatedButton(
                                              style: ElevatedButton.styleFrom(
                                                backgroundColor: Colors.white,
                                              ),
                                              onPressed: () {
                                                valueController.getDepositAndSellPrice();
                                              },
                                              child: Text(
                                                  "지역 위험 매물 확인"
                                              ),
                                            ),
                                          ]
                                        ),
                                        Column(
                                          children: [
                                            SizedBox(
                                              width: screenWidth * 0.8,
                                              child: TextField(
                                                controller: _textEditingController[0],
                                                keyboardType: TextInputType.number,
                                                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                                                decoration: InputDecoration(
                                                  errorText: !_essentialFieldFilled ? "" : null,
                                                  labelText: "전세가"
                                                ),
                                              ),
                                            ),
                                            SizedBox(
                                              width: screenWidth * 0.8,
                                              child: TextField(
                                                controller: _textEditingController[1],
                                                keyboardType: TextInputType.number,
                                                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                                                decoration: InputDecoration(
                                                    errorText: !_essentialFieldFilled ? "전세가와 매매가는 필수 입력 항목입니다." : null,
                                                    labelText: "매매가"
                                                ),
                                              ),
                                            ),
                                            SizedBox(
                                              width: screenWidth * 0.8,
                                              child:TextField(
                                                controller: _textEditingController[2],
                                                keyboardType: TextInputType.number,
                                                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                                                decoration: InputDecoration(
                                                    labelText: "근저당"
                                                ),
                                              ),
                                            ),
                                            SizedBox(height: 10),
                                            Visibility(
                                              visible: _calcButtonTouched && _essentialFieldFilled,
                                              child: Text(
                                                _isDanger ? "전세가 (또는 전세가+근저당)가 매매가의 80% 이상입니다." : "전세가 (또는 전세가+근저당)가 매매가의 80% 미만입니다.",
                                                style: TextStyle(
                                                  color: _isDanger ? Colors.red : Colors.blue
                                                ),
                                              )
                                            ),
                                            ElevatedButton(
                                              style: ElevatedButton.styleFrom(
                                                backgroundColor: Colors.white,
                                              ),
                                              onPressed: () {
                                                _calcButtonTouched = true;
                                                if(_textEditingController[0].text != "" && _textEditingController[1].text != ""){
                                                  _essentialFieldFilled = true;
                                                } else{
                                                  _essentialFieldFilled = false;
                                                }
                                                int deposit = int.parse(_textEditingController[0].text);
                                                int sell = int.parse(_textEditingController[1].text);
                                                if(_textEditingController[2].text == ""){
                                                  if(deposit / sell > 0.8){
                                                    _isDanger = true;
                                                  } else {
                                                    _isDanger = false;
                                                  }
                                                } else{
                                                  int guenJeoDang = int.parse(_textEditingController[2].text);
                                                  if((deposit + guenJeoDang) / sell > 0.8){
                                                    _isDanger = true;
                                                  } else {
                                                    _isDanger = false;
                                                  }
                                                }
                                                print(_essentialFieldFilled);
                                                setState(() {

                                                });
                                              },
                                              child: Text(
                                                "계산하기"
                                              )
                                            )
                                          ],
                                        ),
                                      ],
                                    ),
                                  )
                                ],
                              ),
                            )
                          ),
                        ],
                      ),
                    ),
                    )
                  ],
                )
              ),
            ],
          )
        ),
      )
    );
  }
}
