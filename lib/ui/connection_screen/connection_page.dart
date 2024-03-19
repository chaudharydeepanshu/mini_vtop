import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:minivtop/state/connection_state.dart';
import 'package:minivtop/state/providers.dart';
import 'package:minivtop/ui/components/full_body_message.dart';
import 'package:rive/rive.dart';

import '../../state/error_state.dart';
import '../../state/user_login_state.dart';
import '../components/error_indicators.dart';
import 'package:minivtop/route/route.dart' as route;

class ConnectionPage extends ConsumerStatefulWidget {
  const ConnectionPage({super.key});

  @override
  ConsumerState<ConnectionPage> createState() => _ConnectionScreenState();
}

class _ConnectionScreenState extends ConsumerState<ConnectionPage> {
  late Future<bool> initWebViewState;

  Future<bool> initWebViewData() async {
    ref.read(headlessWebViewProvider);
    ref.read(vtopControllerStateProvider);
    return true;
  }

  SMIInput<bool>? _connectingInput;
  SMIInput<bool>? _connectedInput;
  SMIInput<bool>? _errorInput;

  StateMachineController? stateMachineController;

  void onRiveInit(Artboard artboard) {
    stateMachineController =
        StateMachineController.fromArtboard(artboard, 'State Machine');
    StateMachineController? controller = stateMachineController;
    if (controller != null) {
      artboard.addController(controller);
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
    }
  }

  @override
  void initState() {
    super.initState();
    initWebViewState = initWebViewData();
  }

  @override
  void dispose() {
    stateMachineController?.dispose();
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
                  Expanded(
                    flex: 2,
                    child: Column(
                      children: [
                        const Spacer(),
                        SizedBox(
                          width: 150,
                          height: 150,
                          child: RiveAnimation.asset(
                            'assets/rive/connections_state_machine.riv',
                            fit: BoxFit.contain,
                            onInit: onRiveInit,
                          ),
                        ),
                        ConnectionScreenStates(
                            connectionStatus: connectionStatus,
                            errorStatus: errorStatus),
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
                                    style:
                                        Theme.of(context).textTheme.bodySmall,
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
            ),
          ),
        );
      },
    );
  }
}

class ConnectionScreenStates extends StatelessWidget {
  const ConnectionScreenStates(
      {super.key, required this.connectionStatus, required this.errorStatus});

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
