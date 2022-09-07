import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mini_vtop/state/providers.dart';
import 'package:mini_vtop/state/vtop_actions.dart';
import 'package:mini_vtop/ui/components/error_indicators.dart';
import 'package:mini_vtop/ui/components/loading_indicator.dart';
import 'package:mini_vtop/state/connection_state.dart';

import '../../state/error_state.dart';
import '../../state/user_login_state.dart';

enum Location { beforeHomeScreen, afterHomeScreen }

class PageBodyIndicators extends StatelessWidget {
  const PageBodyIndicators(
      {Key? key, required this.pageStatus, required this.location})
      : super(key: key);

  final VTOPPageStatus pageStatus;
  final Location location;

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

        // Watching VTOP status.
        final LoginResponseStatus loginResponseStatus = ref.watch(
            userLoginStateProvider
                .select((value) => value.loginResponseStatus));

        if (errorStatus != ErrorStatus.noError) {
          //show connection error window with retry option
          return ErrorIndicators(location: location, errorStatus: errorStatus);
        } else {
          return LoadingIndicators(
              location: location,
              pageStatus: pageStatus,
              vtopStatus: vtopStatus,
              connectionStatus: connectionStatus,
              loginResponseStatus: loginResponseStatus);
        }
      },
    );
  }
}
