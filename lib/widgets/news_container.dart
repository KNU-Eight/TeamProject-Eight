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

class _NewsContainerState extends State<NewsContainer>{
  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: () {
        launchUrl(Uri.parse(widget.linkUrl));   //뉴스 링크 연결
      },
      style: TextButton.styleFrom(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
      child: Text(
        widget.linkUrl,
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
}