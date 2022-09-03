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
      return const FullBodyError(
          errorHeadingText: "Ohh...SH*T!",
          errorBodyText: "App connection with VTOP got closed");
    }
    if (errorStatus == ErrorStatus.noInternetError) {
      return const FullBodyError(
          errorHeadingText: "No Internet!",
          errorBodyText: "Looks like someone has stolen your router");
    }
    if (errorStatus == ErrorStatus.vtopError) {
      return const FullBodyError(
          errorHeadingText: "Aw, Snap!",
          errorBodyText: "Something is wrong with VTOP");
    }
    if (errorStatus == ErrorStatus.vtopUnknownResponsesError) {
      return const FullBodyError(
          errorHeadingText: "Gibberish Response!",
          errorBodyText: "VTOP sent an unknown response");
    } else {
      return const FullBodyError(
          errorHeadingText: "Unexpected Error!",
          errorBodyText: "Something is wrong but we don't know what & why");
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

class FullBodyError extends StatelessWidget {
  const FullBodyError(
      {Key? key, required this.errorHeadingText, required this.errorBodyText})
      : super(key: key);

  final String errorHeadingText;
  final String errorBodyText;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            errorHeadingText,
            style: Theme.of(context).textTheme.headlineMedium,
            textAlign: TextAlign.center,
          ),
          const Divider(
            indent: 50,
            endIndent: 50,
          ),
          Text(
            errorBodyText,
            style: Theme.of(context).textTheme.labelMedium,
            textAlign: TextAlign.center,
          ),
          const SizedBox(
            height: 15,
          ),
          const ErrorRetryButton(),
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
                  final ErrorStatusState readErrorStatusStateProviderValue =
                      ref.read(errorStatusStateProvider);
                  readErrorStatusStateProviderValue.update(
                      status: ErrorStatus.noError);
                  final HeadlessWebView readHeadlessWebViewProviderValue =
                      ref.read(headlessWebViewProvider);
                  readHeadlessWebViewProviderValue
                      .settingSomeVarsBeforeWebViewRestart();
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
