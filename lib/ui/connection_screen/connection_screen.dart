import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mini_vtop/state/connection_state.dart';
import 'package:mini_vtop/state/providers.dart';
import 'package:mini_vtop/ui/login_screen/login.dart';
import 'package:rive/rive.dart';

class ConnectionScreen extends ConsumerStatefulWidget {
  const ConnectionScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<ConnectionScreen> createState() => _ConnectionScreenState();
}

class _ConnectionScreenState extends ConsumerState<ConnectionScreen> {
  /// Tracks if the animation is playing by whether controller is running.
  bool get isPlaying => controller?.isActive ?? false;

  Artboard? _riveArtboard;
  StateMachineController? controller;
  SMIInput<bool>? _connectingInput;
  SMIInput<bool>? _connectedInput;
  SMIInput<bool>? _errorInput;

  @override
  void initState() {
    super.initState();

    // Load the animation file from the bundle, note that you could also
    // download this. The RiveFile just expects a list of bytes.
    rootBundle.load('assets/rive/connection_state_machine.riv').then(
      (data) async {
        // Load the RiveFile from the binary data.
        final file = RiveFile.import(data);

        // The artboard is the root of the animation and gets drawn in the
        // Rive widget.
        final artboard = file.mainArtboard;
        var controller =
            StateMachineController.fromArtboard(artboard, 'State Machine 1');
        if (controller != null) {
          artboard.addController(controller);
          _connectingInput = controller.findInput('Connecting');
          _connectedInput = controller.findInput('Connected');
          _errorInput = controller.findInput('Error');

          controller.isActiveChanged.addListener(() {
            final ConnectionStatusState connectionStatusState =
                ref.read(connectionStateProvider);
            if (connectionStatusState.connectionStatus ==
                ConnectionStatus.connected) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => const Login()),
                );
              });
            }
          });
        }
        setState(() => _riveArtboard = artboard);
      },
    );
  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (BuildContext context, WidgetRef ref, Widget? child) {
        final ConnectionStatus connectionStatus = ref.watch(
            connectionStateProvider.select((value) => value.connectionStatus));

        ref.listen<ConnectionStatus>(
            connectionStateProvider.select((value) => value.connectionStatus),
            (ConnectionStatus? previousConnectionStatus,
                ConnectionStatus newConnectionStatus) {
          if (newConnectionStatus == ConnectionStatus.connecting) {
            _connectingInput?.value = true;
          } else if (newConnectionStatus == ConnectionStatus.connected) {
            _connectedInput?.value = true;
          } else {
            _errorInput?.value = true;
          }
        });

        return Scaffold(
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                _riveArtboard == null
                    ? const SizedBox()
                    : SizedBox(
                        width: 250,
                        height: 250,
                        child: Rive(
                          artboard: _riveArtboard!,
                        ),
                      ),
                Text(
                  connectionStatus.name == "connecting"
                      ? "Connecting"
                      : connectionStatus.name == "connected"
                          ? "Connected"
                          : "Error",
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
