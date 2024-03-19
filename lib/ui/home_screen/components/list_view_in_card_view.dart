import 'package:flutter/material.dart';

class ListTileDetail {
  final Icon tileIcon;
  final String tileTitle;
  final Function()? tileOnTap;

  ListTileDetail({
    required this.tileIcon,
    required this.tileTitle,
    this.tileOnTap,
  });

  // Implement toString to make it easier to see information
  // when using the print statement.
  @override
  String toString() {
    return 'ListTileDetail{tileIcon: $tileIcon, tileTitle: $tileTitle, tileOnTap: $tileOnTap}';
  }
}

class ListViewInCardSection extends StatelessWidget {
  const ListViewInCardSection({
    super.key,
    required this.sectionTitle,
    required this.emptySectionText,
    required this.listTilesDetails,
    this.cardShowAllOnTap,
  });

  final String emptySectionText;
  final String sectionTitle;
  final List<ListTileDetail> listTilesDetails;
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
                child: listTilesDetails.isNotEmpty
                    ? ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: listTilesDetails.length <= 4
                            ? listTilesDetails.length
                            : 4,
                        itemBuilder: (BuildContext context, int index) {
                          return ListViewTile(
                            listTileDetail: listTilesDetails[index],
                          );
                        },
                        separatorBuilder: (BuildContext context, int index) {
                          return const Divider(
                            color: Colors.transparent,
                          );
                        },
                      )
                    : Row(
                        children: [
                          Expanded(child: Text(emptySectionText)),
                        ],
                      ),
              ),
              listTilesDetails.length > 4
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
                                  style: Theme.of(context).textTheme.labelLarge,
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

class ListViewTile extends StatelessWidget {
  const ListViewTile({super.key, required this.listTileDetail});

  final ListTileDetail listTileDetail;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(12)),
      ),
      // clipBehavior: Clip.antiAlias,
      // // margin: EdgeInsets.symmetric(horizontal: 16.0),
      tileColor: Theme.of(context).colorScheme.surfaceVariant,
      onTap: listTileDetail.tileOnTap,
      leading: listTileDetail.tileIcon,
      title: Text(
        listTileDetail.tileTitle,
        overflow: TextOverflow.ellipsis,
        maxLines: 2,
      ),
      trailing: const Icon(Icons.arrow_forward),
    );
  }
}
