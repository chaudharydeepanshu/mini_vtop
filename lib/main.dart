import 'package:dynamic_color/dynamic_color.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mini_vtop/ui/connection_screen/connection_screen.dart';
import 'Theme/app_theme_data.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  runApp(const ProviderScope(child: MyApp()));
}

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
        );
      },
    );
  }
}
