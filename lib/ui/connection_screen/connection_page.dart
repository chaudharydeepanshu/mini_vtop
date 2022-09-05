import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mini_vtop/state/connection_state.dart';
import 'package:mini_vtop/state/providers.dart';
import 'package:rive/rive.dart';

import '../../state/error_state.dart';
import '../../state/user_login_state.dart';
import '../components/error_indicators.dart';
import 'package:mini_vtop/route/route.dart' as route;

class ConnectionPage extends ConsumerStatefulWidget {
  const ConnectionPage({Key? key}) : super(key: key);

  @override
  ConsumerState<ConnectionPage> createState() => _ConnectionScreenState();
}

class _ConnectionScreenState extends ConsumerState<ConnectionPage> {
  late Future<bool> initWebViewState;

  Future<bool> initWebViewData() async {
    Stopwatch stopwatch = Stopwatch()..start();
    ref.read(headlessWebViewProvider);
    log('initWebViewData Executed in ${stopwatch.elapsed}');
    return true;
  }

  /// Tracks if the animation is playing by whether controller is running.
  // bool get isPlaying => controller?.isActive ?? false;

  // Artboard? _riveArtboard;
  // StateMachineController? controller;
  SMIInput<bool>? _connectingInput;
  SMIInput<bool>? _connectedInput;
  SMIInput<bool>? _errorInput;

  void onRiveInit(Artboard artboard) {
    final controller =
        StateMachineController.fromArtboard(artboard, 'State Machine');
    // if (controller != null) {
    artboard.addController(controller!);
    _connectingInput = controller.findInput('Connecting');
    _connectedInput = controller.findInput('Connected');
    _errorInput = controller.findInput('Error');
    controller.isActiveChanged.addListener(() {
      final ConnectionStatusState connectionStatusState =
          ref.read(connectionStatusStateProvider);
      if (connectionStatusState.connectionStatus ==
          ConnectionStatus.connected) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          final UserLoginState readUserLoginStateProviderValue =
              ref.read(userLoginStateProvider);

          if (readUserLoginStateProviderValue.loginResponseStatus ==
              LoginResponseStatus.loggedIn) {
            Navigator.pushReplacementNamed(
              context,
              route.dashboardPage,
            );
          } else {
            Navigator.pushReplacementNamed(
              context,
              route.loginPage,
            );
          }
        });
      }
    });
    // }
  }

  // loadAnimationFile() {
  //   // Load the animation file from the bundle, note that you could also
  //   // download this. The RiveFile just expects a list of bytes.
  //   rootBundle.load('assets/rive/connection_state_machine.riv').then(
  //     (data) async {
  //       // Load the RiveFile from the binary data.
  //       final file = RiveFile.import(data);
  //
  //       // The artboard is the root of the animation and gets drawn in the
  //       // Rive widget.
  //       final artboard = file.mainArtboard;
  //       var controller =
  //           StateMachineController.fromArtboard(artboard, 'State Machine 1');
  //       if (controller != null) {
  //         artboard.addController(controller);
  //
  //
  //
  //         _connectingInput?.value = true;
  //       }
  //       setState(() => _riveArtboard = artboard);
  //     },
  //   );
  // }

  @override
  void initState() {
    super.initState();
    initWebViewState = initWebViewData();

    // loadAnimationFile();
  }

  @override
  void dispose() {
    // controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (BuildContext context, WidgetRef ref, Widget? child) {
        final ErrorStatus errorStatus = ref.watch(
            errorStatusStateProvider.select((value) => value.errorStatus));

        final ConnectionStatus connectionStatus = ref.watch(
            connectionStatusStateProvider
                .select((value) => value.connectionStatus));

        // if (connectionStatus == ConnectionStatus.connecting) {
        //   _connectingInput?.value = true;
        // } else if (connectionStatus == ConnectionStatus.connected) {
        //   _connectedInput?.value = true;
        // }
        //
        // if (errorStatus != ErrorStatus.noError) {
        //   _errorInput?.value = true;
        // }

        ref.listen<ConnectionStatusState>(connectionStatusStateProvider,
            (ConnectionStatusState? previous, ConnectionStatusState next) {
          if (next.connectionStatus == ConnectionStatus.connecting) {
            _connectingInput?.value = true;
          } else if (next.connectionStatus == ConnectionStatus.connected) {
            _connectedInput?.value = true;
          }
        });

        ref.listen<ErrorStatus>(
            errorStatusStateProvider.select((value) => value.errorStatus),
            (ErrorStatus? previous, ErrorStatus next) {
          if (next != ErrorStatus.noError) {
            _errorInput?.value = true;
          }
        });

        return Scaffold(
          body: Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 150,
                    height: 150,
                    child: RiveAnimation.asset(
                      'assets/rive/connections_state_machine.riv',
                      fit: BoxFit.contain,
                      onInit: onRiveInit,
                    ),
                    // Rive(
                    //   artboard: _riveArtboard!,
                    //   fit: BoxFit.contain,
                    // ),
                  ),
                  ConnectionScreenStates(
                      connectionStatus: connectionStatus,
                      errorStatus: errorStatus),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class ConnectionScreenStates extends StatelessWidget {
  const ConnectionScreenStates(
      {Key? key, required this.connectionStatus, required this.errorStatus})
      : super(key: key);

  final ConnectionStatus connectionStatus;

  final ErrorStatus errorStatus;

  @override
  Widget build(BuildContext context) {
    if (errorStatus != ErrorStatus.noError) {
      return BeforeHomeScreenErrors(errorStatus: errorStatus);
    }
    if (connectionStatus == ConnectionStatus.connecting) {
      return const FullBodyMessage(
          messageHeadingText: "Connecting!",
          messageBodyText: "Making connection with VTOP");
    } else {
      return const FullBodyMessage(
          messageHeadingText: "Connected!",
          messageBodyText: "Successfully connected with VTOP");
    }
  }
}
