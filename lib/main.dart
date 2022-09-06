import 'dart:async';

import 'package:dynamic_color/dynamic_color.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import 'Theme/app_theme_data.dart';
import 'package:mini_vtop/route/route.dart' as route;

import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

var uuid = const Uuid();

final FirebaseCrashlytics crashlytics = FirebaseCrashlytics.instance;
final FirebaseAnalytics analytics = FirebaseAnalytics.instance;
final FirebaseAnalyticsObserver observer =
    FirebaseAnalyticsObserver(analytics: analytics);

void main() async {
  runZonedGuarded<Future<void>>(() async {
    WidgetsFlutterBinding.ensureInitialized();
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    // The following lines are the same as previously explained in "Handling uncaught errors"
    FlutterError.onError = crashlytics.recordFlutterFatalError;
    // Setting user identifiers
    // crashlytics.setUserIdentifier(uuid.v4());
    // analytics.setUserId(id: uuid.v4());

    runApp(const ProviderScope(child: MyApp()));
  },
      (error, stack) =>
          FirebaseCrashlytics.instance.recordError(error, stack, fatal: true));
}

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
final GlobalKey<ScaffoldMessengerState> rootScaffoldMessengerKey =
    GlobalKey<ScaffoldMessengerState>();

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return DynamicColorBuilder(
      builder: (ColorScheme? lightDynamic, ColorScheme? darkDynamic) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Mini VTOP',
          theme: AppThemeData.lightThemeData(lightDynamic),
          darkTheme: AppThemeData.darkThemeData(darkDynamic),
          themeMode: ThemeMode.system,
          onGenerateRoute: route.controller,
          initialRoute: route.connectionPage,
          navigatorKey: navigatorKey,
          navigatorObservers: [observer],
          scaffoldMessengerKey: rootScaffoldMessengerKey,
        );
      },
    );
  }
}

// Todo: Replace connection screen if error occurs with the error connection state and provide a retry option
// Todo: Load data inside database on 1st run of app.
// Todo: Implement session time out warning banner and provide option to login inside that. Also continue showing old data with this warning if login fails.
// Todo: Integrate the above warning with the connection warning and provide an option to reconnect. Also continue showing old data with this warning if connection fails.
// Todo: If connection fails on app start then provide an option to continue surfing with a warning of no connection. Also provide an option to reconnect in that warning.
// Todo: make requests every few minutes to increase session time.
// Todo: Add vit calendar.
// Todo: Add a resume generator.
