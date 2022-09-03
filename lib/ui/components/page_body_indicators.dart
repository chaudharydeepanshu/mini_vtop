import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mini_vtop/state/providers.dart';
import 'package:mini_vtop/state/vtop_actions.dart';
import 'package:mini_vtop/ui/components/error_indicators.dart';
import 'package:mini_vtop/ui/components/loading_indicator.dart';
import 'package:mini_vtop/state/connection_state.dart';

import '../../state/error_state.dart';

class PageBodyIndicators extends StatelessWidget {
  const PageBodyIndicators(
      {Key? key, required this.pageStatus, required this.errorLocation})
      : super(key: key);

  final VTOPPageStatus pageStatus;
  final ErrorLocation errorLocation;

  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (BuildContext context, WidgetRef ref, Widget? child) {
        // Watching VTOP status.
        final VTOPStatus vtopStatus =
            ref.watch(vtopActionsProvider.select((value) => value.vtopStatus));

        // Watching connection status.
        final ConnectionStatus connectionStatus = ref.watch(
            connectionStatusStateProvider
                .select((value) => value.connectionStatus));

        // Watching error status.
        final ErrorStatus errorStatus = ref.watch(
            errorStatusStateProvider.select((value) => value.errorStatus));

        if (errorStatus != ErrorStatus.noError) {
          //show connection error window with retry option
          return ErrorIndicator(
              errorLocation: errorLocation, errorStatus: errorStatus);
        } else if (connectionStatus == ConnectionStatus.connecting) {
          return const LoadingIndicator(
            loadingBodyText: "App is connecting to VTOP. Please wait",
            loadingHeadingText: 'Connecting!',
          );
        } else if (vtopStatus == VTOPStatus.sessionTimedOut) {
          return const LoadingIndicator(
            loadingBodyText: "Session timed out so reconnecting to VTOP",
            loadingHeadingText: 'Connecting!',
          );
        } else if (pageStatus == VTOPPageStatus.processing) {
          return const LoadingIndicator(
            loadingBodyText: "Fetching and processing the data",
            loadingHeadingText: 'Loading Data!',
          );
        } else {
          return const LoadingIndicator(
            loadingBodyText: "Unknown Status",
            loadingHeadingText: 'Unknown Status!',
          );
        }
      },
    );
  }
}
