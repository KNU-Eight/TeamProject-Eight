import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:prevent_rental_fraud/global_value_controller.dart';
import 'package:prevent_rental_fraud/widgets/news_list_builder.dart';

class HomePage extends StatefulWidget {
  const HomePage({
    super.key,
    required this.newsLinks,
    required this.onPageChange
  });
  final List<String> newsLinks;
  final Function(int) onPageChange;

  @override
  createState() => _HomePageState();
}
class _HomePageState extends State<HomePage>{
  var valueController = Get.find<GlobalValueController>();
  bool isPressedAIService1 = false;
  bool isTextButtonCloseDelayed = false;
  bool isShowCheckListDelayed = false;

  @override
  void initState(){
    super.initState();
    valueController.initSiDoList();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final double startPosition = 0.06;
    return Scaffold(
      body: Container(
        width: screenWidth, // 동적 너비
        height: screenHeight, // 동적 높이
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
              top: screenHeight * startPosition,
              child: Text(
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
            ),
            Positioned(   //뉴스 컨테이너
              left: screenWidth * startPosition,
              top: screenHeight * startPosition + 110,
              child: NewsListBuilder(
                newsLinks: widget.newsLinks,
              )
            ),
            Positioned(
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
            Positioned.fill(
              left: 0,
              top: screenHeight * startPosition + 200,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                spacing: 10,
                children: [
                  Expanded(
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
                        Divider(
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
                        Expanded(
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
                                                  Obx(() =>
                                                    DropdownButton<String>(
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
                                                  Obx(() => DropdownButton<String>(
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
                                          TextButton(
                                            onPressed: () {
                                              valueController.getDepositAndSellPrice();
                                            },
                                            child: Text(
                                              "지역 위험 매물 확인"
                                            ),
                                          )
                                        ]
                                      ),
                                      Center(child: Text('탭 2 내용')),
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
    );
  }
}
