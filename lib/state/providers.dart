import 'package:mini_vtop/state/user_login_state.dart';
import 'package:mini_vtop/state/vtop_actions.dart';
import 'package:mini_vtop/state/vtop_data_state.dart';

import 'connection_state.dart';
import 'error_state.dart';
import 'webview_state.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final userLoginStateProvider =
    ChangeNotifierProvider((ref) => UserLoginState());

final headlessWebViewProvider =
    ChangeNotifierProvider((ref) => HeadlessWebView(ref.read)..init());

final connectionStatusStateProvider =
    ChangeNotifierProvider((ref) => ConnectionStatusState()..init());

final vtopActionsProvider =
    ChangeNotifierProvider((ref) => VTOPActions(ref.read));

final vtopDataProvider = ChangeNotifierProvider((ref) => VTOPData());

final errorStatusStateProvider =
    ChangeNotifierProvider((ref) => ErrorStatusState()..init());
