import 'package:flutter/material.dart';
import 'package:minivtop/ui/home_screen/components/list_view_in_card_view.dart';
import 'package:minivtop/route/route.dart' as route;

class NewsPage extends StatelessWidget {
  const NewsPage({super.key, required this.arguments});

  final NewsPageArguments arguments;

  @override
  Widget build(BuildContext context) {
    final List<ListTileDetail> newsListTilesDetails =
        arguments.newsListTilesDetails;

    return Scaffold(
      appBar: AppBar(
        title: const Text("News"),
        centerTitle: true,
      ),
      body: ListView.separated(
        padding: const EdgeInsets.all(16.0),
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
    );
  }
}

class NewsPageArguments {
  final List<ListTileDetail> newsListTilesDetails;

  NewsPageArguments({required this.newsListTilesDetails});
}

class NewsSection extends StatelessWidget {
  const NewsSection({super.key});

  @override
  Widget build(BuildContext context) {
    final List<ListTileDetail> newsListTilesDetails = [
      // ListTileDetail(
      //   tileIcon: const Icon(Icons.circle),
      //   tileTitle: 'Mid Term Exam Schedule',
      //   tileOnTap: () {
      //     Navigator.of(context).push(
      //       MaterialPageRoute(
      //         builder: (BuildContext context) => NewsScreen(
      //           newsDetail: NewsDetail(
      //               title: 'Mid Term Exam Schedule', markdownBody: ''),
      //         ),
      //       ),
      //     );
      //   },
      // ),
      // ListTileDetail(
      //   tileIcon: const Icon(Icons.circle),
      //   tileTitle: 'VIT-B Experiential Learning ',
      //   tileOnTap: () {},
      // ),
      // ListTileDetail(
      //   tileIcon: const Icon(Icons.circle),
      //   tileTitle: 'Whatsapp Group Sheets',
      //   tileOnTap: () {},
      // ),
    ];

    return ListViewInCardSection(
      sectionTitle: 'News',
      emptySectionText: 'No news available',
      listTilesDetails: newsListTilesDetails,
      cardShowAllOnTap: () {
        Navigator.pushNamed(
          context,
          route.newsPage,
          arguments:
              NewsPageArguments(newsListTilesDetails: newsListTilesDetails),
        );
      },
    );
  }
}
