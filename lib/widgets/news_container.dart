import 'package:flutter/material.dart';
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
        widget.linkUrl,
        overflow: TextOverflow.ellipsis,
        style: const TextStyle(
          color: Colors.blue,
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
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (context) {
        return DraggableScrollableSheet(
          expand: false,
          snap: true,
          builder: (_, controller) {
            return SingleChildScrollView(
              controller: controller,
              child: Column(
                children: [
                  Container(
                    margin: const EdgeInsets.only(top: 8.0),
                    width: 30.0,
                    height: 3.0,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(24.0),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 24.0),
                    child: Column(
                      children: [
                        ListView.builder(
                          shrinkWrap: true,
                          itemCount: 50,
                          physics: const ClampingScrollPhysics(),
                          itemBuilder: (context, index) {
                            return ListTile(title: Text('Item $index'));
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );


  }
}