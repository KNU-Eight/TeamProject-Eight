import 'dart:convert';
import 'package:http/http.dart' as http;

class News {
  final String url;
  final String title;
  final String summary;

  News({required this.url, required this.title, required this.summary});

  factory News.fromJson(Map<String, dynamic> json) {
    return News(
      url: json['url'] ?? '',
      title: json['title'],
      summary: json['summary'],
    );
  }
}

class NewsService {
  final String baseUrl = 'http://10.0.2.2:8000';

  Future<List<News>> fetchNews() async {
    final response = await http.get(Uri.parse('$baseUrl/news'));

    if (response.statusCode == 200) {
      List<dynamic> newsJson = json.decode(utf8.decode(response.bodyBytes));
      return newsJson.map((json) => News.fromJson(json)).toList();
    } else {
      throw Exception('뉴스 로드 실패');
    }
  }
}