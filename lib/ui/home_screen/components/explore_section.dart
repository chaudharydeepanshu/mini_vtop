import 'package:flutter/material.dart';
import 'package:minivtop/ui/home_screen/components/grid_view_in_card_view.dart';
import 'package:minivtop/route/route.dart' as route;

class ExplorePage extends StatelessWidget {
  const ExplorePage({super.key, required this.arguments});

  final ExplorePageArguments arguments;

  @override
  Widget build(BuildContext context) {
    final List<GridCardDetail> exploreCardsDetails =
        arguments.exploreCardsDetails;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Explore"),
        centerTitle: true,
      ),
      body: GridView.builder(
        padding: const EdgeInsets.all(16.0),
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
    );
  }
}

class ExplorePageArguments {
  final List<GridCardDetail> exploreCardsDetails;

  ExplorePageArguments({required this.exploreCardsDetails});
}

class ExploreSection extends StatelessWidget {
  const ExploreSection({super.key});

  @override
  Widget build(BuildContext context) {
    final List<GridCardDetail> exploreCardsDetails = [
      GridCardDetail(
        cardIcon: const Icon(Icons.account_circle),
        cardTitle: 'Student Profile',
        cardOnTap: () {
          Navigator.pushNamed(
            context,
            route.studentProfilePage,
          );
        },
      ),
      GridCardDetail(
        cardIcon: const Icon(Icons.school),
        cardTitle: 'Academics',
        cardOnTap: () {
          Navigator.pushNamed(
            context,
            route.academicsPage,
          );
        },
      ),
      GridCardDetail(
        cardIcon: const Icon(Icons.badge),
        cardTitle: 'Attendance',
        cardOnTap: () {
          Navigator.pushNamed(
            context,
            route.attendancePage,
          );
        },
      ),
      GridCardDetail(
        cardIcon: const Icon(Icons.table_chart),
        cardTitle: 'Time-Table',
        cardOnTap: () {
          Navigator.pushNamed(
            context,
            route.timeTablePage,
          );
        },
      ),
      GridCardDetail(
        cardIcon: const Icon(Icons.schedule),
        cardTitle: 'Exam Schedule',
        cardOnTap: null,
        // () {},
      ),
      GridCardDetail(
        cardIcon: const Icon(Icons.calendar_month),
        cardTitle: 'Calendar',
        cardOnTap: null,
        // () {},
      ),
    ];

    return GridViewInCardSection(
      sectionTitle: 'Explore',
      emptySectionText: 'Nothing to explore',
      gridCardsDetails: exploreCardsDetails,
      cardShowAllOnTap: () {
        Navigator.pushNamed(
          context,
          route.explorePage,
          arguments:
              ExplorePageArguments(exploreCardsDetails: exploreCardsDetails),
        );
      },
    );
  }
}
