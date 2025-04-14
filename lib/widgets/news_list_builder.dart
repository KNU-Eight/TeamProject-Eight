import 'package:flutter/material.dart';
import 'package:prevent_rental_fraud/widgets/news_container.dart';

class NewsListBuilder extends StatefulWidget{
  const NewsListBuilder({
    super.key,
    required this.newsLinks,
  });
  final List<String> newsLinks;

  @override
  createState() => _NewsListBuilderState();
}

class _NewsListBuilderState extends State<NewsListBuilder>{
  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    return SizedBox(
      width: screenWidth * 0.94,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Wrap(
          spacing: 10,
          direction: Axis.horizontal,
          children: widget.newsLinks.map((linkUrl){
            return NewsContainer(linkUrl: linkUrl);
          }).toList(),
        ),
      ),
    );
  }
}

