import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:prevent_rental_fraud/global_value_controller.dart';
import 'package:url_launcher/url_launcher.dart';

class NewsContainer extends StatefulWidget{
  const NewsContainer({
    super.key,
    required this.linkUrl,
  });

  final String linkUrl;   //뉴스 링크
  @override
  createState() => _NewsContainerState();
}

class _NewsContainerState extends State<NewsContainer> with SingleTickerProviderStateMixin{
  late AnimationController animationController;
  late double screenHeight;
  var globalValueController = Get.find<GlobalValueController>();
  bool isLinkClicked = false;
  @override
  void initState(){
    super.initState();
    animationController = BottomSheet.createAnimationController(this);
  }
  @override
  Widget build(BuildContext context) {
    print(widget.linkUrl);
    screenHeight = MediaQuery.of(context).size.height;
    return TextButton(
      onPressed: () {
        // launchUrl(Uri.parse(widget.linkUrl));   //뉴스 링크 연결
        _showModalBottomSheet();
      },
      style: TextButton.styleFrom(
        fixedSize: Size(176, 77),
        backgroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 11),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
      child: Text(
        "기사 제목",
        overflow: TextOverflow.ellipsis,
        style: const TextStyle(
          color: Colors.black,
          fontSize: 16,
          fontFamily: 'Inter',
          fontWeight: FontWeight.w600,
          height: 1,
        ),
      ),
    );
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
              height: globalValueController.screenHeight.value * 0.8,
              width: globalValueController.screenWidth.value,
              child: Column(
                  children: [
                    Expanded(
                      child: SingleChildScrollView(
                        child: Column(
                          children: [
                            Container(
                              margin: EdgeInsets.symmetric(vertical: 15),
                              height: 5,
                              width: globalValueController.screenWidth.value * 0.4,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(30),
                                color: Colors.grey,
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 24.0),
                            ),
                            Text("본문 내용")
                          ],
                        ),
                      ),
                    ),
                    TextButton(
                        onPressed: (){
                          setState(() {
                            isLinkClicked = true;
                          });
                          launchUrl(Uri.parse(widget.linkUrl));
                        },
                        child: Text(
                          "본문 링크",
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: isLinkClicked ? Colors.deepPurple : Colors.blue,
                            fontSize: 12,
                            fontFamily: 'Inter',
                            fontWeight: FontWeight.w600,
                            height: 1,
                          ),
                        )
                    )
                  ]
              )
          ),
        );
      },
    );
  }
}