import 'package:flutter/material.dart';
import 'package:minivtop/ui/components/full_body_message.dart';
import 'package:rive/rive.dart';

class EmptyContentIndicator extends StatelessWidget {
  const EmptyContentIndicator({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            flex: 2,
            child: Column(
              children: [
                const Spacer(),
                Transform.scale(
                  scale: 4.0,
                  child: const SizedBox(
                    width: 150,
                    height: 150,
                    child: RiveAnimation.asset(
                      'assets/rive/impatient_placeholder.riv',
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
                const Column(
                  children: [
                    FullBodyMessage(
                        messageHeadingText: "No Content!",
                        messageBodyText:
                            "Sorry no content is available for it"),
                  ],
                ),
              ],
            ),
          ),
          Expanded(
            flex: 1,
            child: Column(
              children: [
                const Spacer(),
                Card(
                  elevation: 0,
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            "If app doesn't work and its urgent then try the official VTOP as it could be an app specific issue.",
                            style: Theme.of(context).textTheme.bodySmall,
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
