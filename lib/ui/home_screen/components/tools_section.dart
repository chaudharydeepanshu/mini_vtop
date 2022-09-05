import 'package:flutter/material.dart';
import 'package:mini_vtop/ui/home_screen/components/grid_view_in_card_view.dart';
import 'package:mini_vtop/route/route.dart' as route;

class ToolsPage extends StatelessWidget {
  const ToolsPage({Key? key, required this.arguments}) : super(key: key);

  final ToolsPageArguments arguments;

  @override
  Widget build(BuildContext context) {
    final List<GridCardDetail> toolsCardsDetails = arguments.toolsCardsDetails;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Tools"),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: GridView.builder(
          gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
            childAspectRatio: 1,
            maxCrossAxisExtent: 200,
            mainAxisExtent: 100,
            mainAxisSpacing: 8,
            crossAxisSpacing: 8,
          ),
          itemCount: toolsCardsDetails.length,
          itemBuilder: (BuildContext context, int index) {
            return GridViewCard(
              gridCardDetail: toolsCardsDetails[index],
            );
          },
        ),
      ),
    );
  }
}

class ToolsPageArguments {
  final List<GridCardDetail> toolsCardsDetails;

  ToolsPageArguments({required this.toolsCardsDetails});
}

class ToolsSection extends StatelessWidget {
  const ToolsSection({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final List<GridCardDetail> toolsCardsDetails = [
      GridCardDetail(
        cardIcon: const Icon(Icons.schedule),
        cardTitle: 'Schedule Generator',
        cardOnTap: null,
      ),
      GridCardDetail(
        cardIcon: const Icon(Icons.notifications),
        cardTitle: 'Auto Reminders',
        cardOnTap: null,
      ),
      GridCardDetail(
        cardIcon: const Icon(Icons.share),
        cardTitle: 'Share Stuff',
        cardOnTap: null,
      ),
    ];

    return GridViewInCardSection(
      sectionTitle: 'Tools',
      emptySectionText: 'No tools available',
      gridCardsDetails: toolsCardsDetails,
      cardShowAllOnTap: () {
        Navigator.pushNamed(
          context,
          route.toolsPage,
          arguments: ToolsPageArguments(toolsCardsDetails: toolsCardsDetails),
        );
      },
    );
  }
}
