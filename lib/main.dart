import 'dart:async';

import 'package:dynamic_color/dynamic_color.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:minivtop/route/route.dart' as route;
import 'package:minivtop/shared_preferences/preferences.dart';
import 'package:minivtop/state/providers.dart';
import 'package:uuid/uuid.dart';

import 'firebase_options.dart';

var uuid = const Uuid();

final FirebaseCrashlytics crashlyticsInstance = FirebaseCrashlytics.instance;
final FirebaseAnalytics analyticsInstance = FirebaseAnalytics.instance;
final FirebaseAnalyticsObserver analyticsObserver =
    FirebaseAnalyticsObserver(analytics: analyticsInstance);

void main() async {
  runZonedGuarded<Future<void>>(() async {
    WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
    FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);
    await initPackageInfo();
    await initSharedPreferences();

    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );

    if (kDebugMode) {
      // Disable Crashlytics collection while doing every day development.
      await crashlyticsInstance.setCrashlyticsCollectionEnabled(false);
      await analyticsInstance.setAnalyticsCollectionEnabled(false);
      await analyticsInstance.setUserId(id: 'debugModeId');
    } else {
      // Enable Crashlytics collection based on user preference in production.
      await crashlyticsInstance.setCrashlyticsCollectionEnabled(
        Preferences.crashlyticsCollectionStatus,
      );
      await analyticsInstance.setAnalyticsCollectionEnabled(
        Preferences.analyticsCollectionStatus,
      );
      await analyticsInstance.setUserId(id: 'prodModeId');
    }

    // This captures errors reported by the Flutter framework.
    FlutterError.onError = crashlyticsInstance.recordFlutterFatalError;

    // To remove the splash screen once everything is initialized.
    FlutterNativeSplash.remove();

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
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return DynamicColorBuilder(
      builder: (ColorScheme? lightDynamic, ColorScheme? darkDynamic) {
        return Consumer(
          builder: (BuildContext context, WidgetRef ref, Widget? child) {
            var appThemeState = ref.read(appThemeStateProvider);
            appThemeState.initTheme(
                lightDynamic: lightDynamic, darkDynamic: darkDynamic);
            // This is needed because DynamicColorBuilder doesn't provide dynamic colorScheme if os is yet to respond.
            // So we just update the color scheme once again when we get the new dynamic colorScheme.
            WidgetsBinding.instance.addPostFrameCallback((_) {
              appThemeState.updateTheme();
            });
            return const App();
          },
        );
      },
    );
  }
}

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (BuildContext context, WidgetRef ref, Widget? child) {
        ThemeData lightThemeData = ref.watch(
            appThemeStateProvider.select((value) => value.lightThemeData));
        ThemeData darkThemeData = ref.watch(
            appThemeStateProvider.select((value) => value.darkThemeData));
        ThemeMode themeMode =
            ref.watch(appThemeStateProvider.select((value) => value.themeMode));
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Mini VTOP',
          theme: lightThemeData,
          darkTheme: darkThemeData,
          themeMode: themeMode,
          onGenerateRoute: route.controller,
          initialRoute: route.connectionPage,
          navigatorKey: navigatorKey,
          navigatorObservers: [analyticsObserver],
          scaffoldMessengerKey: rootScaffoldMessengerKey,
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
