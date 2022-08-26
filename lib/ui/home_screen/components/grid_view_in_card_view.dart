import 'package:flutter/material.dart';

class GridCardDetail {
  final Icon cardIcon;

  final String cardTitle;
  final Function()? cardOnTap;

  GridCardDetail({
    required this.cardIcon,
    required this.cardTitle,
    this.cardOnTap,
  });

  // Implement toString to make it easier to see information
  // when using the print statement.
  @override
  String toString() {
    return 'CardDetail{cardIcon: $cardIcon, cardTitle: $cardTitle, cardOnTap: $cardOnTap}';
  }
}

class GridViewInCardSection extends StatelessWidget {
  const GridViewInCardSection(
      {Key? key,
      required this.sectionTitle,
      required this.gridCardsDetails,
      this.cardShowAllOnTap})
      : super(key: key);

  final String sectionTitle;
  final List<GridCardDetail> gridCardsDetails;
  final Function()? cardShowAllOnTap;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Text(
            sectionTitle,
            style: Theme.of(context).textTheme.titleLarge,
          ),
        ),
        const SizedBox(
          height: 8,
        ),
        Card(
          clipBehavior: Clip.antiAlias,
          margin: const EdgeInsets.symmetric(horizontal: 16.0),
          elevation: 0,
          shape: RoundedRectangleBorder(
            side: BorderSide(
              color: Theme.of(context).colorScheme.outline,
            ),
            borderRadius: const BorderRadius.all(Radius.circular(12)),
          ),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                    childAspectRatio: 1,
                    maxCrossAxisExtent: 200,
                    mainAxisExtent: 100,
                    mainAxisSpacing: 8,
                    crossAxisSpacing: 8,
                  ),
                  itemCount: gridCardsDetails.length <= 4
                      ? gridCardsDetails.length
                      : 4,
                  itemBuilder: (BuildContext context, int index) {
                    return GridViewCard(
                      gridCardDetail: gridCardsDetails[index],
                    );
                  },
                ),
              ),
              gridCardsDetails.length > 4
                  ? Column(
                      children: [
                        const Divider(
                          height: 0,
                        ),
                        InkWell(
                          onTap: cardShowAllOnTap,
                          child: SizedBox(
                            height: 48,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(Icons.arrow_forward),
                                Text(
                                  "Show All",
                                  style: Theme.of(context).textTheme.button,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    )
                  : const SizedBox(),
            ],
          ),
        ),
      ],
    );
  }
}

class GridViewCard extends StatelessWidget {
  const GridViewCard({Key? key, required this.gridCardDetail})
      : super(key: key);

  final GridCardDetail gridCardDetail;

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      // margin: EdgeInsets.symmetric(horizontal: 16.0),
      color: Theme.of(context).colorScheme.surfaceVariant,
      child: InkWell(
        onTap: gridCardDetail.cardOnTap,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            gridCardDetail.cardIcon,
            const SizedBox(
              height: 10,
            ),
            Text(gridCardDetail.cardTitle),
          ],
        ),
      ),
    );
  }
}
