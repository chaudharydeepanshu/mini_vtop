import 'connection_state.dart';
import 'webview_state.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final headlessWebViewProvider =
    ChangeNotifierProvider((ref) => HeadlessWebView()..init());

final connectionStateProvider =
    ChangeNotifierProvider((ref) => ConnectionStatusState()..init());
