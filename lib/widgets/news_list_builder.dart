import 'package:flutter/material.dart';
import 'package:prevent_rental_fraud/widgets/news_container.dart'; // 올바른 경로인지 확인
import 'package:prevent_rental_fraud/widgets/news_service.dart'; // 새 서비스 파일 임포트

class NewsListBuilder extends StatefulWidget{
  const NewsListBuilder({
    super.key,
  });

  @override
  createState() => _NewsListBuilderState();
}

class _NewsListBuilderState extends State<NewsListBuilder>{
  late Future<List<News>> futureNews;

  @override
  void initState(){
    super.initState();
    futureNews = NewsService().fetchNews();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    return SizedBox(
      width: screenWidth * 0.94,
      child: FutureBuilder<List<News>>(
        future: futureNews,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('사용 가능한 뉴스가 없습니다.'));
          } else {
            return SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Wrap(
                spacing: 10,
                direction: Axis.horizontal,
                children: snapshot.data!.map((newsItem){
                  return NewsContainer(
                    linkUrl: newsItem.url,
                    title: newsItem.title,
                    summary: newsItem.summary,
                  );
                }).toList(),
              ),
            );
          }
        },
      ),
    );
  }
}
