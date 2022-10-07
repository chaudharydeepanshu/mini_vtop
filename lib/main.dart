import 'dart:async';

import 'package:dynamic_color/dynamic_color.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:minivtop/state/providers.dart';
import 'package:minivtop/ui/theme/app_theme_data.dart';
import 'package:uuid/uuid.dart';
import 'package:minivtop/route/route.dart' as route;

import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

var uuid = const Uuid();

final FirebaseCrashlytics crashlytics = FirebaseCrashlytics.instance;
final FirebaseAnalytics analytics = FirebaseAnalytics.instance;
final FirebaseAnalyticsObserver observer =
    FirebaseAnalyticsObserver(analytics: analytics);

void main() async {
  runZonedGuarded<Future<void>>(() async {
    WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
    FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);
    await initHive();
    await initPackageInfo();
    await initSharedPreferences();

    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );

    // whenever your initialization is completed, remove the splash screen:
    FlutterNativeSplash.remove();

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
        return Consumer(
          builder: (BuildContext context, WidgetRef ref, Widget? child) {
            ref
                .read(appThemeStateProvider)
                .init(lightDynamic: lightDynamic, darkDynamic: darkDynamic);
            ThemeMode themeMode = ref.watch(
                appThemeStateProvider.select((value) => value.themeMode));
            return MaterialApp(
              debugShowCheckedModeBanner: false,
              title: 'Mini VTOP',
              theme: AppThemeData.lightThemeData(lightDynamic),
              darkTheme: AppThemeData.darkThemeData(darkDynamic),
              themeMode: themeMode,
              onGenerateRoute: route.controller,
              initialRoute: route.connectionPage,
              navigatorKey: navigatorKey,
              navigatorObservers: [observer],
              scaffoldMessengerKey: rootScaffoldMessengerKey,
            );
          },
        );
      },
    );
  }
}

// Todo: Force update from firebase or play store data.
// Todo: Look into ajax requests like student record or grade history accepted multiple times.
// Todo: Load data inside database on 1st run of app.
// Todo: Add vit calendar.
// Todo: Add a resume generator.
