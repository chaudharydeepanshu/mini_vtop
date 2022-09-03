import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:rive/rive.dart';

class LoadingIndicator extends StatelessWidget {
  const LoadingIndicator(
      {Key? key,
      required this.loadingBodyText,
      required this.loadingHeadingText})
      : super(key: key);

  final String loadingBodyText;
  final String loadingHeadingText;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(
            width: 150,
            height: 150,
            child: RiveAnimation.asset(
              'assets/rive/flame_loader.riv',
              fit: BoxFit.contain,
            ),
          ),
          // SpinKitThreeBounce(
          //         size: 24,
          //         color: Theme.of(context).colorScheme.onSurface,
          //       ),
          Column(
            children: [
              Text(
                loadingHeadingText,
                style: Theme.of(context).textTheme.headlineMedium,
                textAlign: TextAlign.center,
              ),
              const Divider(
                indent: 50,
                endIndent: 50,
              ),
              Text(
                loadingBodyText,
                style: Theme.of(context).textTheme.labelMedium,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
