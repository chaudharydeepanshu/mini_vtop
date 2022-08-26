import 'package:flutter/material.dart';
import 'package:mini_vtop/ui/home_screen/components/list_view_in_card_view.dart';

import '../../news_screen/news_screen.dart';

class NewsListScreen extends StatelessWidget {
  const NewsListScreen({Key? key, required this.newsListTilesDetails})
      : super(key: key);

  final List<ListTileDetail> newsListTilesDetails;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("News"),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: newsListTilesDetails.length,
          itemBuilder: (BuildContext context, int index) {
            return ListViewTile(
              listTileDetail: newsListTilesDetails[index],
            );
          },
          separatorBuilder: (BuildContext context, int index) {
            return const Divider(
              color: Colors.transparent,
            );
          },
        ),
      ),
    );
  }
}

class NewsSection extends StatelessWidget {
  const NewsSection({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final List<ListTileDetail> newsListTilesDetails = [
      ListTileDetail(
        tileIcon: const Icon(Icons.circle),
        tileTitle: 'Mid Term Exam Schedule',
        tileOnTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (BuildContext context) => NewsScreen(
                newsDetail: NewsDetail(
                    title: 'Mid Term Exam Schedule', markdownBody: ''),
              ),
            ),
          );
        },
      ),
      ListTileDetail(
        tileIcon: const Icon(Icons.circle),
        tileTitle: 'VIT-B Experiential Learning ',
        tileOnTap: () {},
      ),
      ListTileDetail(
        tileIcon: const Icon(Icons.circle),
        tileTitle: 'Whatsapp Group Sheets',
        tileOnTap: () {},
      ),
    ];

    return ListViewInCardSection(
      sectionTitle: 'News',
      listTilesDetails: newsListTilesDetails,
      cardShowAllOnTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (BuildContext context) => NewsListScreen(
              newsListTilesDetails: newsListTilesDetails,
            ),
          ),
        );
      },
    );
  }
}
