import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:minivtop/state/providers.dart';
import 'package:minivtop/state/webview_state.dart';

class ErrorRetryButton extends StatelessWidget {
  const ErrorRetryButton({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (BuildContext context, WidgetRef ref, Widget? child) {
        return Row(
          children: [
            Expanded(
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  foregroundColor: Theme.of(context).colorScheme.onPrimary,
                  backgroundColor: Theme.of(context).colorScheme.primary,
                ).copyWith(elevation: ButtonStyleButton.allOrNull(0.0)),
                onPressed: () {
                  final HeadlessWebView readHeadlessWebViewProviderValue =
                      ref.read(headlessWebViewProvider);
                  readHeadlessWebViewProviderValue.runHeadlessInAppWebView();
                },
                icon: const Icon(Icons.refresh),
                label: const Text('Retry'),
              ),
            ),
          ],
        );
      },
    );
  }
}
