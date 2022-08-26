import 'package:flutter/material.dart';

class NewsDetail {
  final String title;
  final String markdownBody;

  NewsDetail({
    required this.title,
    required this.markdownBody,
  });

  // Implement toString to make it easier to see information
  // when using the print statement.
  @override
  String toString() {
    return 'NewsDetail{title: $title, markdownBody: $markdownBody}';
  }
}

class NewsScreen extends StatelessWidget {
  const NewsScreen({Key? key, required this.newsDetail}) : super(key: key);

  final NewsDetail newsDetail;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("About News"),
        centerTitle: true,
      ),
      body: Text(newsDetail.title),
    );
  }
}
