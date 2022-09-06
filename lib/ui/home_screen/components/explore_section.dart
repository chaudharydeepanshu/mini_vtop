import 'package:flutter/material.dart';
import 'package:mini_vtop/ui/explore_section_screens/academics/academics.dart';
import 'package:mini_vtop/ui/explore_section_screens/student_profile/student_profile.dart';
import 'package:mini_vtop/ui/home_screen/components/grid_view_in_card_view.dart';
import 'package:mini_vtop/route/route.dart' as route;

class ExplorePage extends StatelessWidget {
  const ExplorePage({Key? key, required this.arguments}) : super(key: key);

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

class ExplorePageArguments {
  final List<GridCardDetail> exploreCardsDetails;

  ExplorePageArguments({required this.exploreCardsDetails});
}

class ExploreSection extends StatelessWidget {
  const ExploreSection({Key? key}) : super(key: key);

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
        cardOnTap: null,
        //     () {
        //   Navigator.of(context).push(
        //     MaterialPageRoute(
        //       builder: (BuildContext context) => const Attendance(),
        //     ),
        //   );
        // },
      ),
      GridCardDetail(
        cardIcon: const Icon(Icons.table_chart),
        cardTitle: 'Time-Table',
        cardOnTap: null,
        //     () {
        //   Navigator.of(context).push(
        //     MaterialPageRoute(
        //       builder: (BuildContext context) => const TimeTable(),
        //     ),
        //   );
        // },
      ),
      GridCardDetail(
        cardIcon: const Icon(Icons.schedule),
        cardTitle: 'Exam Schedule',
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
