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
  const GridViewInCardSection({
    super.key,
    required this.sectionTitle,
    required this.emptySectionText,
    required this.gridCardsDetails,
    this.cardShowAllOnTap,
  });

  final String emptySectionText;
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
          // elevation: 0,
          // shape: RoundedRectangleBorder(
          //   side: BorderSide(
          //     color: Theme.of(context).colorScheme.outline,
          //   ),
          //   borderRadius: const BorderRadius.all(Radius.circular(12)),
          // ),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: gridCardsDetails.isNotEmpty
                    ? GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate:
                            const SliverGridDelegateWithMaxCrossAxisExtent(
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
                      )
                    : Row(
                        children: [
                          Expanded(child: Text(emptySectionText)),
                        ],
                      ),
              ),
              gridCardsDetails.length > 4
                  ? Column(
                      children: [
                        const Divider(
                          height: 0,
                        ),
                        Row(
                          children: [
                            Expanded(
                              child: TextButton.icon(
                                style: TextButton.styleFrom(
                                  minimumSize: const Size(double.infinity, 48),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(0),
                                  ),
                                  tapTargetSize:
                                      MaterialTapTargetSize.shrinkWrap,
                                ),
                                onPressed: cardShowAllOnTap,
                                icon: const Icon(Icons.arrow_forward),
                                label: const Text("Show All"),
                              ),
                            ),
                          ],
                        ),
                        // InkWell(
                        //   onTap: cardShowAllOnTap,
                        //   child: SizedBox(
                        //     height: 48,
                        //     child: Row(
                        //       children: [
                        //         const Icon(Icons.arrow_forward),
                        //         Text(
                        //           "Show All",
                        //           style: Theme.of(context).textTheme.labelLarge,
                        //         ),
                        //       ],
                        //     ),
                        //   ),
                        // ),
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
  const GridViewCard({super.key, required this.gridCardDetail});

  final GridCardDetail gridCardDetail;

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      clipBehavior: Clip.antiAlias,
      style: ElevatedButton.styleFrom(
        foregroundColor: Theme.of(context).colorScheme.onSecondaryContainer,
        backgroundColor: Theme.of(context).colorScheme.secondaryContainer,
      ).copyWith(elevation: ButtonStyleButton.allOrNull(0.0)),
      onPressed: gridCardDetail.cardOnTap,
      child: Stack(
        alignment: AlignmentDirectional.topCenter,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surfaceVariant,
                  ),
                  child: gridCardDetail.cardOnTap == null
                      ? Text(
                          "Coming Soon",
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.labelSmall,
                        )
                      : const SizedBox(),
                ),
              ),
            ],
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              gridCardDetail.cardIcon,
              const SizedBox(
                height: 5,
              ),
              Text(
                gridCardDetail.cardTitle,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ],
      ),
    );
    //   Card(
    //   clipBehavior: Clip.antiAlias,
    //   // margin: EdgeInsets.symmetric(horizontal: 16.0),
    //   color: Theme.of(context).colorScheme.surfaceVariant,
    //   child: InkWell(
    //     onTap: gridCardDetail.cardOnTap,
    //     child: Column(
    //       mainAxisAlignment: MainAxisAlignment.center,
    //       children: [
    //         gridCardDetail.cardIcon,
    //         const SizedBox(
    //           height: 10,
    //         ),
    //         Text(gridCardDetail.cardTitle),
    //       ],
    //     ),
    //   ),
    // );
  }
}
