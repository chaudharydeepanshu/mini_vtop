import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mini_vtop/state/providers.dart';
import 'package:mini_vtop/state/webview_state.dart';

class ErrorRetryButton extends StatelessWidget {
  const ErrorRetryButton({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (BuildContext context, WidgetRef ref, Widget? child) {
        return Row(
          children: [
            Expanded(
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  // Foreground color
                  // ignore: deprecated_member_use
                  onPrimary: Theme.of(context).colorScheme.onPrimary,
                  // Background color
                  // ignore: deprecated_member_use
                  primary: Theme.of(context).colorScheme.primary,
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
