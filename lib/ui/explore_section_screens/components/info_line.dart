import 'package:flutter/material.dart';

class InfoLine extends StatelessWidget {
  const InfoLine({super.key, required this.detailName, required this.detail});

  final String detailName;
  final String detail;

  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Expanded(
            flex: 4,
            child: Text(
              detailName,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
          const VerticalDivider(),
          Expanded(
            flex: 10,
            child: Text(
              detail,
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ),
        ],
      ),
    );
  }
}
