import 'package:flutter/material.dart';

class FullBodyMessage extends StatelessWidget {
  const FullBodyMessage(
      {super.key,
      required this.messageHeadingText,
      required this.messageBodyText});

  final String messageHeadingText;
  final String messageBodyText;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            messageHeadingText,
            style: Theme.of(context).textTheme.headlineMedium,
            textAlign: TextAlign.center,
          ),
          const Divider(
            indent: 50,
            endIndent: 50,
          ),
          Text(
            messageBodyText,
            style: Theme.of(context).textTheme.labelMedium,
            textAlign: TextAlign.center,
          ),
          const SizedBox(
            height: 15,
          ),
        ],
      ),
    );
  }
}
