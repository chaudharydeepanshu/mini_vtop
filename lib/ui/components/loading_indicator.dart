import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:minivtop/route/route.dart' as route;
import 'package:minivtop/ui/components/custom_snack_bar.dart';
import 'package:minivtop/ui/components/error_retry_button.dart';
import 'package:minivtop/ui/components/full_body_message.dart';
import 'package:minivtop/ui/components/page_body_indicators.dart';
import 'package:rive/rive.dart';

import '../../state/connection_state.dart';
import '../../state/providers.dart';
import '../../state/user_login_state.dart';
import '../../state/vtop_actions.dart';

class LoadingIndicators extends StatelessWidget {
  const LoadingIndicators(
      {super.key,
      required this.location,
      required this.pageStatus,
      required this.vtopStatus,
      required this.connectionStatus,
      required this.loginResponseStatus});

  final Location location;
  final VTOPPageStatus pageStatus;
  final VTOPStatus vtopStatus;
  final ConnectionStatus connectionStatus;
  final LoginResponseStatus loginResponseStatus;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Flexible(
            flex: 2,
            child: Column(
              children: [
                const Spacer(),
                const Flexible(
                  child: SizedBox(
                    width: 150,
                    height: 150,
                    child: RiveAnimation.asset(
                      'assets/rive/flame_loader.riv',
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
                location == Location.beforeHomeScreen
                    ? BeforeHomeScreenLoaders(
                        pageStatus: pageStatus,
                        vtopStatus: vtopStatus,
                        connectionStatus: connectionStatus,
                        loginResponseStatus: loginResponseStatus)
                    : AfterHomeScreenLoaders(
                        pageStatus: pageStatus,
                        vtopStatus: vtopStatus,
                        connectionStatus: connectionStatus,
                        loginResponseStatus: loginResponseStatus),
              ],
            ),
          ),
          Flexible(
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

class BeforeHomeScreenLoaders extends StatelessWidget {
  const BeforeHomeScreenLoaders(
      {super.key,
      required this.pageStatus,
      required this.vtopStatus,
      required this.connectionStatus,
      required this.loginResponseStatus});

  final VTOPPageStatus pageStatus;
  final VTOPStatus vtopStatus;
  final ConnectionStatus connectionStatus;
  final LoginResponseStatus loginResponseStatus;

  @override
  Widget build(BuildContext context) {
    if (connectionStatus == ConnectionStatus.connecting) {
      return const Column(
        children: [
          FullBodyMessage(
              messageHeadingText: "Connecting!",
              messageBodyText: "App is connecting to VTOP. Please wait"),
        ],
      );
    }
    if (vtopStatus == VTOPStatus.sessionTimedOut) {
      return const Column(
        children: [
          FullBodyMessage(
              messageHeadingText: "Reconnecting!",
              messageBodyText:
                  "Session timed out so reconnecting to VTOP. Please wait"),
        ],
      );
    }
    if (pageStatus == VTOPPageStatus.processing) {
      return const Column(
        children: [
          FullBodyMessage(
              messageHeadingText: "Loading Data!",
              messageBodyText: "Fetching and processing the data. Please wait"),
        ],
      );
    } else {
      return const Column(
        children: [
          FullBodyMessage(
              messageHeadingText: "Unknown Status!",
              messageBodyText: "Unknown Status."),
          ErrorRetryButton(),
        ],
      );
    }
  }
}

class AfterHomeScreenLoaders extends StatelessWidget {
  const AfterHomeScreenLoaders(
      {super.key,
      required this.pageStatus,
      required this.vtopStatus,
      required this.connectionStatus,
      required this.loginResponseStatus});

  final VTOPPageStatus pageStatus;
  final VTOPStatus vtopStatus;
  final ConnectionStatus connectionStatus;
  final LoginResponseStatus loginResponseStatus;

  @override
  Widget build(BuildContext context) {
    if (connectionStatus == ConnectionStatus.connecting) {
      return const Column(
        children: [
          FullBodyMessage(
              messageHeadingText: "Connecting!",
              messageBodyText: "App is connecting to VTOP. Please wait"),
        ],
      );
    }
    if (vtopStatus == VTOPStatus.sessionTimedOut) {
      return const Column(
        children: [
          FullBodyMessage(
              messageHeadingText: "Reconnecting!",
              messageBodyText:
                  "Session timed out so reconnecting to VTOP. Please wait"),
        ],
      );
    }
    if (pageStatus == VTOPPageStatus.processing) {
      return const Column(
        children: [
          FullBodyMessage(
              messageHeadingText: "Loading Data!",
              messageBodyText: "Fetching and processing the data. Please wait"),
        ],
      );
    }
    if (loginResponseStatus == LoginResponseStatus.loggedOut &&
        vtopStatus == VTOPStatus.homepage) {
      return const Column(
        children: [
          FullBodyMessage(
              messageHeadingText: "You Logged Out!",
              messageBodyText:
                  "You logged out due to session timeout. Either re-login or continue with old data"),
          AfterHomeScreenLoginButton(),
          OldDataButton(),
        ],
      );
    } else {
      return const Column(
        children: [
          FullBodyMessage(
              messageHeadingText: "Unknown Status!",
              messageBodyText: "Unknown Status."),
          ErrorRetryButton(),
        ],
      );
    }
  }
}

class AfterHomeScreenLoginButton extends StatelessWidget {
  const AfterHomeScreenLoginButton({super.key});

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
                  foregroundColor: Theme.of(context).colorScheme.onPrimary,
                  backgroundColor: Theme.of(context).colorScheme.primary,
                ).copyWith(elevation: ButtonStyleButton.allOrNull(0.0)),
                onPressed: () {
                  Navigator.pushNamedAndRemoveUntil(
                      context, route.loginPage, ModalRoute.withName('/'));
                  // use ten to refresh the page after the closing of login page
                  // final HeadlessWebView readHeadlessWebViewProviderValue =
                  //     ref.read(headlessWebViewProvider);
                  // readHeadlessWebViewProviderValue.settingSomeVars();
                  // readHeadlessWebViewProviderValue.runHeadlessInAppWebView();
                },
                icon: const Icon(Icons.login),
                label: const Text('Login'),
              ),
            ),
          ],
        );
      },
    );
  }
}

class OldDataButton extends StatelessWidget {
  const OldDataButton({super.key});

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
                  foregroundColor: Theme.of(context).colorScheme.onPrimary,
                  backgroundColor: Theme.of(context).colorScheme.primary,
                ).copyWith(elevation: ButtonStyleButton.allOrNull(0.0)),
                onPressed: () {
                  final VTOPActions readVTOPActionsProviderValue =
                      ref.read(vtopActionsProvider);

                  readVTOPActionsProviderValue.updateOfflineModeStatus(
                      mode: true);

                  String? currentRouteName =
                      ModalRoute.of(context)?.settings.name;
                  //
                  // late final Preferences readPreferencesProviderValue =
                  //     ref.read(preferencesProvider);
                  //
                  // late final VTOPData readVTOPDataProviderValue =
                  //     ref.read(vtopDataProvider);
                  //
                  switch (currentRouteName) {
                    case route.connectionPage:
                      Navigator.pushReplacementNamed(
                        context,
                        route.dashboardPage,
                      );
                      break;
                    case route.loginPage:
                      Navigator.pushReplacementNamed(
                        context,
                        route.dashboardPage,
                      );
                      break;
                    case route.forgotUserIDPage:
                      Navigator.pushReplacementNamed(
                        context,
                        route.dashboardPage,
                      );
                      break;
                    case null:
                      log('This route name is null.');
                      break;
                    default:
                      log('No action should be taken on this route.');
                  }
                },
                icon: const Icon(Icons.cached),
                label: const Text('Show old data'),
              ),
            ),
          ],
        );
      },
    );
  }
}

noDataAvailableSnackBar(BuildContext context) {
  String? contentText = 'Oh...No! There is no old data available.';
  Color? backgroundColor = Theme.of(context).colorScheme.errorContainer;
  Duration? duration = const Duration(days: 365);
  IconData? iconData = Icons.warning;
  Color? iconAndTextColor = Theme.of(context).colorScheme.error;

  showCustomSnackBar(
    context: context,
    contentText: contentText,
    backgroundColor: backgroundColor,
    duration: duration,
    iconData: iconData,
    iconAndTextColor: iconAndTextColor,
  );
}
