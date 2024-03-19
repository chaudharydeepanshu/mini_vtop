import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:minivtop/state/providers.dart';
import 'package:minivtop/route/route.dart' as route;
import 'package:minivtop/ui/components/theme_mode_switcher.dart';

import 'package:minivtop/constants.dart';
import 'link_button.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Stack(
        children: [
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Flexible(
                child: Consumer(
                  builder:
                      (BuildContext context, WidgetRef ref, Widget? child) {
                    return DrawerHeader(
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.surface,
                        border: const Border(
                          bottom: BorderSide.none,
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Column(
                            children: [
                              Flexible(
                                child: Image.asset(
                                  'assets/app_icon.png',
                                ),
                              ),
                              Text(ref.read(packageInfoCalcProvider).appName,
                                  style:
                                      Theme.of(context).textTheme.titleLarge),
                            ],
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
              Expanded(
                child: ListView(
                  // Important: Remove any padding from the ListView.
                  padding: EdgeInsets.zero,
                  children: [
                    const ThemeModeSwitcher(),
                    const Divider(indent: 16, endIndent: 16),
                    ListTile(
                      leading: const Icon(Icons.settings),
                      title: const Text('Settings'),
                      onTap: () {
                        Navigator.pushNamed(
                          context,
                          route.settingsPage,
                        );
                      },
                    ),
                    ListTile(
                      leading: const Icon(Icons.help),
                      title: const Text('About'),
                      onTap: () {
                        Navigator.pushNamed(
                          context,
                          route.aboutPage,
                        );
                      },
                    ),
                    const SizedBox(
                      height: 48,
                    ),
                  ],
                ),
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
                    const Divider(height: 0),
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
