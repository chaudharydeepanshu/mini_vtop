import 'package:flutter/material.dart';
import 'package:mini_vtop/ui/home_screen/components/grid_view_in_card_view.dart';

class ToolsGridScreen extends StatelessWidget {
  const ToolsGridScreen({Key? key, required this.toolsCardsDetails})
      : super(key: key);

  final List<GridCardDetail> toolsCardsDetails;

  @override
  Widget build(BuildContext context) {
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
      gridCardsDetails: toolsCardsDetails,
      cardShowAllOnTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (BuildContext context) => ToolsGridScreen(
              toolsCardsDetails: toolsCardsDetails,
            ),
          ),
        );
      },
    );
  }
}
