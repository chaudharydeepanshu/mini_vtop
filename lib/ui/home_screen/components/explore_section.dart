import 'package:flutter/material.dart';
import 'package:mini_vtop/ui/explore_section_screens/time_table/time_table.dart';
import 'package:mini_vtop/ui/home_screen/components/grid_view_in_card_view.dart';

class ExploreGridScreen extends StatelessWidget {
  const ExploreGridScreen({Key? key, required this.exploreCardsDetails})
      : super(key: key);

  final List<GridCardDetail> exploreCardsDetails;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Explore"),
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
          itemCount: exploreCardsDetails.length,
          itemBuilder: (BuildContext context, int index) {
            return GridViewCard(
              gridCardDetail: exploreCardsDetails[index],
            );
          },
        ),
      ),
    );
  }
}

class ExploreSection extends StatelessWidget {
  const ExploreSection({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final List<GridCardDetail> exploreCardsDetails = [
      GridCardDetail(
        cardIcon: const Icon(Icons.account_circle),
        cardTitle: 'Student Profile',
        cardOnTap: () {},
      ),
      GridCardDetail(
        cardIcon: const Icon(Icons.school),
        cardTitle: 'Academics',
        cardOnTap: () {},
      ),
      GridCardDetail(
        cardIcon: const Icon(Icons.badge),
        cardTitle: 'Attendance',
        cardOnTap: () {},
      ),
      GridCardDetail(
        cardIcon: const Icon(Icons.table_chart),
        cardTitle: 'Time-Table',
        cardOnTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (BuildContext context) => const TimeTable(),
            ),
          );
        },
      ),
      GridCardDetail(
        cardIcon: const Icon(Icons.schedule),
        cardTitle: 'Exam Schedule',
        cardOnTap: () {},
      ),
    ];

    return GridViewInCardSection(
      sectionTitle: 'Explore',
      gridCardsDetails: exploreCardsDetails,
      cardShowAllOnTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (BuildContext context) => ExploreGridScreen(
              exploreCardsDetails: exploreCardsDetails,
            ),
          ),
        );
      },
    );
  }
}
