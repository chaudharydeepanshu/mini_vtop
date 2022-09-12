import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:minivtop/state/providers.dart';
import 'package:minivtop/route/route.dart' as route;

import '../../constants.dart';
import 'link_button.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Drawer(
      // Add a ListView to the drawer. This ensures the user can scroll
      // through the options in the drawer if there isn't enough vertical
      // space to fit everything.
      child: Stack(
        children: [
          ListView(
            // Important: Remove any padding from the ListView.
            padding: EdgeInsets.zero,
            children: [
              Consumer(
                builder: (BuildContext context, WidgetRef ref, Widget? child) {
                  return DrawerHeader(
                    decoration: const BoxDecoration(
                        // color: Theme.of(context).colorScheme.surfaceVariant,
                        ),
                    child: Column(
                      children: [
                        Flexible(
                          child: Image.asset(
                            'assets/app_icon.png',
                          ),
                        ),
                        Text(ref.read(packageInfoCalcProvider).appName,
                            style: Theme.of(context).textTheme.titleLarge),
                      ],
                    ),
                  );
                },
              ),
              Consumer(
                builder: (BuildContext context, WidgetRef ref, Widget? child) {
                  ThemeMode themeMode = ref.watch(
                      appThemeStateProvider.select((value) => value.themeMode));
                  String buttonText = themeMode == ThemeMode.light
                      ? "Light"
                      : themeMode == ThemeMode.dark
                          ? "Dark"
                          : "System";
                  IconData iconData = themeMode == ThemeMode.light
                      ? Icons.light_mode
                      : themeMode == ThemeMode.dark
                          ? Icons.dark_mode
                          : Icons.android;
                  return ListTile(
                    leading: Icon(iconData),
                    title: Text('Theme - $buttonText'),
                    onTap: () {
                      ref.read(appThemeStateProvider).updateThemeMode();
                    },
                  );
                },
              ),
              const Divider(),
              ListTile(
                leading: const Icon(Icons.home),
                title: const Text("Home"),
                onTap: () {
                  if (Navigator.canPop(context)) {
                    // Popping drawer before popping other page only if it can be popped.
                    Navigator.pop(context);
                    if (Navigator.canPop(context)) {
                      // Popping other page only if it can be popped.
                      Navigator.pop(context);
                    }
                  }
                },
              ),
              // ListTile(
              //   leading: const Icon(Icons.settings),
              //   title: const Text('Settings'),
              //   onTap: () {},
              // ),
              ListTile(
                leading: const Icon(Icons.help),
                title: const Text('About'),
                onTap: () {
                  String? currentRouteName =
                      ModalRoute.of(context)?.settings.name;
                  if (currentRouteName != null &&
                      currentRouteName != route.aboutPage) {
                    // Opening about page only if its not open already.
                    if (Navigator.canPop(context)) {
                      // Popping drawer before opening about page only if it can be popped.
                      Navigator.pop(context);
                    }
                    // Opening about page.
                    Navigator.pushNamed(
                      context,
                      route.aboutPage,
                    );
                  }
                },
              ),
              const SizedBox(
                height: 48,
              ),
            ],
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Container(
                color: Theme.of(context).colorScheme.surface,
                child: Column(
                  children: [
                    const Divider(),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          LinkButton(
                              urlLabel: "Privacy Policy",
                              urlIcon: Icons.privacy_tip,
                              url: privacyPolicyUrl),
                          const Text(
                            ' - ',
                          ),
                          LinkButton(
                              urlLabel: "Terms and Conditions",
                              urlIcon: Icons.gavel,
                              url: termsAndConditionsUrl),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
