import 'package:dynamic_color/dynamic_color.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mini_vtop/ui/connection_screen/connection_screen.dart';
import 'Theme/app_theme_data.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  runApp(const ProviderScope(child: MyApp()));
}

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

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
          home: const ConnectionScreen(),
          navigatorKey: navigatorKey,
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
