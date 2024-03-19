import 'package:flutter/material.dart';
import 'package:minivtop/state/error_state.dart';
import 'package:minivtop/ui/components/error_retry_button.dart';
import 'package:minivtop/ui/components/full_body_message.dart';
import 'package:minivtop/ui/components/page_body_indicators.dart';
import 'package:rive/rive.dart';

import 'loading_indicator.dart';

class ErrorIndicators extends StatelessWidget {
  const ErrorIndicators(
      {super.key, required this.location, required this.errorStatus});

  final Location location;
  final ErrorStatus errorStatus;

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
                const Flexible(
                  child: SizedBox(
                    width: 150,
                    height: 150,
                    child: RiveAnimation.asset(
                      'assets/rive/flame_and_spark.riv',
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
                location == Location.beforeHomeScreen
                    ? BeforeHomeScreenErrors(errorStatus: errorStatus)
                    : AfterHomeScreenErrors(errorStatus: errorStatus),
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

class BeforeHomeScreenErrors extends StatelessWidget {
  const BeforeHomeScreenErrors({super.key, required this.errorStatus});

  final ErrorStatus errorStatus;

  @override
  Widget build(BuildContext context) {
    if (errorStatus == ErrorStatus.connectionClosedError) {
      return const Column(
        children: [
          FullBodyMessage(
              messageHeadingText: "Ohh...SH*T!",
              messageBodyText: "App connection with VTOP got closed"),
          ErrorRetryButton(),
          OldDataButton(),
        ],
      );
    }
    if (errorStatus == ErrorStatus.noInternetError) {
      return const Column(
        children: [
          FullBodyMessage(
              messageHeadingText: "No Internet!",
              messageBodyText: "Looks like someone has stolen your router"),
          ErrorRetryButton(),
          OldDataButton(),
        ],
      );
    }
    if (errorStatus == ErrorStatus.sslError) {
      return const Column(
        children: [
          FullBodyMessage(
              messageHeadingText: "Woah! SSL Issue.",
              messageBodyText:
                  "Detected SSL issue in VTOP. A secure connection cannot be made."),
          ErrorRetryButton(),
          OldDataButton(),
        ],
      );
    }
    if (errorStatus == ErrorStatus.vtopError) {
      return const Column(
        children: [
          FullBodyMessage(
              messageHeadingText: "Aw, Snap!",
              messageBodyText: "Something is wrong with VTOP"),
          ErrorRetryButton(),
          OldDataButton(),
        ],
      );
    }
    if (errorStatus == ErrorStatus.vtopUnknownResponsesError) {
      return const Column(
        children: [
          FullBodyMessage(
              messageHeadingText: "Gibberish Response!",
              messageBodyText: "VTOP sent an unknown response"),
          ErrorRetryButton(),
          OldDataButton(),
        ],
      );
    }
    if (errorStatus == ErrorStatus.nameNotResolvedError) {
      return const Column(
        children: [
          FullBodyMessage(
              messageHeadingText: "Internet / VTOP Lost!",
              messageBodyText:
                  "Either you are not connected to internet or the VTOP doesn't exist. Please try again."),
          ErrorRetryButton(),
          OldDataButton(),
        ],
      );
    }
    if (errorStatus == ErrorStatus.connectionResetError) {
      return const Column(
        children: [
          FullBodyMessage(
              messageHeadingText: "Connection Reset!",
              messageBodyText:
                  "Looks like the connection was reset. Please try again."),
          ErrorRetryButton(),
          OldDataButton(),
        ],
      );
    }
    if (errorStatus == ErrorStatus.addressUnreachableError) {
      return const Column(
        children: [
          FullBodyMessage(
              messageHeadingText: "Internet / VTOP Lost!",
              messageBodyText:
                  "Either you are not connected to internet or the VTOP doesn't exist. Please try again."),
          ErrorRetryButton(),
          OldDataButton(),
        ],
      );
    }
    if (errorStatus == ErrorStatus.httpTrafficError) {
      return const Column(
        children: [
          FullBodyMessage(
              messageHeadingText: "Found HTTP!",
              messageBodyText:
                  "VTOP sent HTTP request caught. Retry or wait for an app update."),
          ErrorRetryButton(),
          OldDataButton(),
        ],
      );
    }
    if (errorStatus == ErrorStatus.nullDocBeforeAction) {
      return const Column(
        children: [
          FullBodyMessage(
              messageHeadingText: "Got Null Doc!",
              messageBodyText: "VTOP sent a null doc. Please try again."),
          ErrorRetryButton(),
          OldDataButton(),
        ],
      );
    }
    if (errorStatus == ErrorStatus.webpageNotAvailable) {
      return const Column(
        children: [
          FullBodyMessage(
              messageHeadingText: "VTOP Unavailable!",
              messageBodyText: "Unable to access VTOP. Please try again."),
          ErrorRetryButton(),
          OldDataButton(),
        ],
      );
    }
    if (errorStatus == ErrorStatus.docParsingError) {
      return const Column(
        children: [
          FullBodyMessage(
              messageHeadingText: "Parsing Error!",
              messageBodyText:
                  "Unable to parse HTML from VTOP. Please try again."),
          ErrorRetryButton(),
          OldDataButton(),
        ],
      );
    } else {
      return const Column(
        children: [
          FullBodyMessage(
              messageHeadingText: "Error Detected!",
              messageBodyText:
                  "Something is wrong but I don't know what. Please try again."),
          ErrorRetryButton(),
          OldDataButton(),
        ],
      );
    }
  }
}

class AfterHomeScreenErrors extends StatelessWidget {
  const AfterHomeScreenErrors({super.key, required this.errorStatus});

  final ErrorStatus errorStatus;

  @override
  Widget build(BuildContext context) {
    if (errorStatus == ErrorStatus.connectionClosedError) {
      return const Column(
        children: [
          FullBodyMessage(
              messageHeadingText: "Ohh...SH*T!",
              messageBodyText: "App connection with VTOP got closed"),
          ErrorRetryButton(),
          OldDataButton(),
        ],
      );
    }
    if (errorStatus == ErrorStatus.noInternetError) {
      return const Column(
        children: [
          FullBodyMessage(
              messageHeadingText: "No Internet!",
              messageBodyText: "Looks like someone has stolen your router"),
          ErrorRetryButton(),
          OldDataButton(),
        ],
      );
    }
    if (errorStatus == ErrorStatus.sslError) {
      return const Column(
        children: [
          FullBodyMessage(
              messageHeadingText: "Woah! SSL Issue.",
              messageBodyText:
                  "Detected SSL issue in VTOP. A secure connection cannot be made."),
          ErrorRetryButton(),
          OldDataButton(),
        ],
      );
    }
    if (errorStatus == ErrorStatus.vtopError) {
      return const Column(
        children: [
          FullBodyMessage(
              messageHeadingText: "Aw, Snap!",
              messageBodyText: "Something is wrong with VTOP"),
          ErrorRetryButton(),
          OldDataButton(),
        ],
      );
    }
    if (errorStatus == ErrorStatus.vtopUnknownResponsesError) {
      return const Column(
        children: [
          FullBodyMessage(
              messageHeadingText: "Gibberish Response!",
              messageBodyText: "VTOP sent an unknown response"),
          ErrorRetryButton(),
          OldDataButton(),
        ],
      );
    }
    if (errorStatus == ErrorStatus.nameNotResolvedError) {
      return const Column(
        children: [
          FullBodyMessage(
              messageHeadingText: "Internet / VTOP Lost!",
              messageBodyText:
                  "Either you are not connected to internet or the VTOP doesn't exist. Please try again."),
          ErrorRetryButton(),
          OldDataButton(),
        ],
      );
    }
    if (errorStatus == ErrorStatus.connectionResetError) {
      return const Column(
        children: [
          FullBodyMessage(
              messageHeadingText: "Connection Reset!",
              messageBodyText:
                  "Looks like the connection was reset. Please try again."),
          ErrorRetryButton(),
          OldDataButton(),
        ],
      );
    }
    if (errorStatus == ErrorStatus.addressUnreachableError) {
      return const Column(
        children: [
          FullBodyMessage(
              messageHeadingText: "Internet / VTOP Lost!",
              messageBodyText:
                  "Either you are not connected to internet or the VTOP doesn't exist. Please try again."),
          ErrorRetryButton(),
          OldDataButton(),
        ],
      );
    }
    if (errorStatus == ErrorStatus.httpTrafficError) {
      return const Column(
        children: [
          FullBodyMessage(
              messageHeadingText: "Found HTTP!",
              messageBodyText:
                  "VTOP sent HTTP request caught. Retry or wait for an app update."),
          ErrorRetryButton(),
          OldDataButton(),
        ],
      );
    }
    if (errorStatus == ErrorStatus.nullDocBeforeAction) {
      return const Column(
        children: [
          FullBodyMessage(
              messageHeadingText: "Got Null Doc!",
              messageBodyText: "VTOP sent a null doc. Please try again."),
          ErrorRetryButton(),
          OldDataButton(),
        ],
      );
    }
    if (errorStatus == ErrorStatus.webpageNotAvailable) {
      return const Column(
        children: [
          FullBodyMessage(
              messageHeadingText: "VTOP Unavailable!",
              messageBodyText: "Unable to access VTOP. Please try again."),
          ErrorRetryButton(),
          OldDataButton(),
        ],
      );
    }
    if (errorStatus == ErrorStatus.docParsingError) {
      return const Column(
        children: [
          FullBodyMessage(
              messageHeadingText: "Parsing Error!",
              messageBodyText:
                  "Unable to parse HTML from VTOP. Please try again."),
          ErrorRetryButton(),
          OldDataButton(),
        ],
      );
    } else {
      return const Column(
        children: [
          FullBodyMessage(
              messageHeadingText: "Error Detected!",
              messageBodyText:
                  "Something is wrong but I don't know what. Please try again."),
          ErrorRetryButton(),
          OldDataButton(),
        ],
      );
    }
  }
}
