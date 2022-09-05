import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mini_vtop/state/error_state.dart';
import 'package:mini_vtop/state/providers.dart';
import 'package:rive/rive.dart';

import '../../state/webview_state.dart';

enum ErrorLocation { beforeHomeScreen, afterHomeScreen }

class ErrorIndicator extends StatelessWidget {
  const ErrorIndicator(
      {Key? key, required this.errorLocation, required this.errorStatus})
      : super(key: key);

  final ErrorLocation errorLocation;
  final ErrorStatus errorStatus;

  @override
  Widget build(BuildContext context) {
    if (errorLocation == ErrorLocation.beforeHomeScreen) {
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
                  const SizedBox(
                    width: 150,
                    height: 150,
                    child: RiveAnimation.asset(
                      'assets/rive/flame_and_spark.riv',
                      fit: BoxFit.contain,
                    ),
                  ),
                  BeforeHomeScreenErrors(errorStatus: errorStatus),
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
                    // shape: RoundedRectangleBorder(
                    //   side: BorderSide(
                    //     color: Theme.of(context).colorScheme.outline,
                    //   ),
                    //   borderRadius: const BorderRadius.all(Radius.circular(12)),
                    // ),
                    // color: Theme.of(context).colorScheme.surfaceVariant,
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              "If retry is doesn't work and its urgent then try the official VTOP as it could be an app specific issue.",
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
    } else {
      return AfterHomeScreenErrors(errorStatus: errorStatus);
    }
  }
}

// Full body errors
class BeforeHomeScreenErrors extends StatelessWidget {
  const BeforeHomeScreenErrors({Key? key, required this.errorStatus})
      : super(key: key);

  final ErrorStatus errorStatus;

  @override
  Widget build(BuildContext context) {
    if (errorStatus == ErrorStatus.connectionClosedError) {
      return Column(
        children: const [
          FullBodyMessage(
              messageHeadingText: "Ohh...SH*T!",
              messageBodyText: "App connection with VTOP got closed"),
          ErrorRetryButton(),
        ],
      );
    }
    if (errorStatus == ErrorStatus.noInternetError) {
      return Column(
        children: const [
          FullBodyMessage(
              messageHeadingText: "No Internet!",
              messageBodyText: "Looks like someone has stolen your router"),
          ErrorRetryButton(),
        ],
      );
    }
    if (errorStatus == ErrorStatus.sslError) {
      return Column(
        children: const [
          FullBodyMessage(
              messageHeadingText: "Woah! SSL Issue.",
              messageBodyText:
                  "Detected SSL issue in VTOP. A secure connection cannot be made."),
          ErrorRetryButton(),
        ],
      );
    }
    if (errorStatus == ErrorStatus.vtopError) {
      return Column(
        children: const [
          FullBodyMessage(
              messageHeadingText: "Aw, Snap!",
              messageBodyText: "Something is wrong with VTOP"),
          ErrorRetryButton(),
        ],
      );
    }
    if (errorStatus == ErrorStatus.vtopUnknownResponsesError) {
      return Column(
        children: const [
          FullBodyMessage(
              messageHeadingText: "Gibberish Response!",
              messageBodyText: "VTOP sent an unknown response"),
          ErrorRetryButton(),
        ],
      );
    }
    if (errorStatus == ErrorStatus.internetOrDnsError) {
      return Column(
        children: const [
          FullBodyMessage(
              messageHeadingText: "DNS Issue!",
              messageBodyText:
                  "Looks like a DNS issue. Try disabling the private DNS in your device settings."),
          ErrorRetryButton(),
        ],
      );
    }
    if (errorStatus == ErrorStatus.httpTrafficError) {
      return Column(
        children: const [
          FullBodyMessage(
              messageHeadingText: "Found HTTP!",
              messageBodyText:
                  "VTOP sent HTTP request caught. Retry or wait for an app update."),
          ErrorRetryButton(),
        ],
      );
    }
    if (errorStatus == ErrorStatus.nullDocBeforeAction) {
      return Column(
        children: const [
          FullBodyMessage(
              messageHeadingText: "Got Null Doc!",
              messageBodyText: "VTOP sent a null doc. Please try again."),
          ErrorRetryButton(),
        ],
      );
    } else {
      return Column(
        children: const [
          FullBodyMessage(
              messageHeadingText: "Unexpected Error!",
              messageBodyText:
                  "Something is wrong but we don't know what & why"),
          ErrorRetryButton(),
        ],
      );
    }
  }
}

// Banner errors
class AfterHomeScreenErrors extends StatelessWidget {
  const AfterHomeScreenErrors({Key? key, required this.errorStatus})
      : super(key: key);

  final ErrorStatus errorStatus;

  @override
  Widget build(BuildContext context) {
    if (errorStatus == ErrorStatus.connectionClosedError) {
      return Container();
    }
    if (errorStatus == ErrorStatus.noInternetError) {
      return Container();
    }
    if (errorStatus == ErrorStatus.vtopError) {
      return Container();
    }
    if (errorStatus == ErrorStatus.vtopUnknownResponsesError) {
      return Container();
    } else {
      return Container();
    }
  }
}

class FullBodyMessage extends StatelessWidget {
  const FullBodyMessage(
      {Key? key,
      required this.messageHeadingText,
      required this.messageBodyText})
      : super(key: key);

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
