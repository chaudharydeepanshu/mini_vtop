import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

import 'package:minivtop/state/providers.dart';

import 'package:minivtop/state/vtop_actions.dart';

import 'package:minivtop/models/student_profile_model.dart';
import 'package:minivtop/shared_preferences/preferences.dart';
import 'package:minivtop/state/vtop_data_state.dart';

// import 'package:minivtop/route/route.dart' as route;

class HomeHeader extends ConsumerStatefulWidget {
  const HomeHeader({super.key});

  @override
  ConsumerState<HomeHeader> createState() => _HomeHeaderState();
}

class _HomeHeaderState extends ConsumerState<HomeHeader> {
  @override
  void initState() {
    final VTOPPageStatus studentProfilePageStatus =
        ref.read(vtopActionsProvider).studentProfilePageStatus;

    if (studentProfilePageStatus != VTOPPageStatus.loaded) {
      final VTOPActions readVTOPActionsProviderValue =
          ref.read(vtopActionsProvider);
      readVTOPActionsProviderValue.studentProfileAllViewAction();
    }

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      margin: const EdgeInsets.symmetric(horizontal: 16.0),
      // elevation: 0,
      // shape: RoundedRectangleBorder(
      //   side: BorderSide(
      //     color: Theme.of(context).colorScheme.outline,
      //   ),
      //   borderRadius: const BorderRadius.all(Radius.circular(12)),
      // ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Consumer(
                  builder:
                      (BuildContext context, WidgetRef ref, Widget? child) {
                    final VTOPPageStatus studentProfilePageStatus = ref.watch(
                        vtopActionsProvider
                            .select((value) => value.studentProfilePageStatus));

                    final bool enableOfflineMode = ref.watch(vtopActionsProvider
                        .select((value) => value.enableOfflineMode));

                    if (enableOfflineMode == true) {
                      final Preferences readPreferencesProviderValue =
                          ref.read(preferencesProvider);
                      String? oldHTMLDoc =
                          readPreferencesProviderValue.studentProfileHTMLDoc;
                      final VTOPData readVTOPDataProviderValue =
                          ref.read(vtopDataProvider);
                      if (oldHTMLDoc != null) {
                        WidgetsBinding.instance.addPostFrameCallback((_) {
                          readVTOPDataProviderValue.setStudentProfile(
                              studentProfileViewDocument: oldHTMLDoc);
                        });
                      }
                    }

                    return Row(
                      children: [
                        Text(
                          "Hello, ",
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        studentProfilePageStatus == VTOPPageStatus.processing
                            ? SpinKitThreeBounce(
                                size: 24,
                                color: Theme.of(context).colorScheme.onSurface,
                              )
                            : const UserName(),
                      ],
                    );
                  },
                ),
                const SizedBox(
                  height: 10,
                ),
                Text(
                  "Have a great day",
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
            // OutlinedButton.icon(
            //   onPressed: () {
            //     Navigator.pushNamed(
            //       context,
            //       route.quickGlancePage,
            //     );
            //   },
            //   icon: const Icon(Icons.arrow_forward),
            //   label: const Text("Quick Glance"),
            // ),
          ],
        ),
      ),
    );
  }
}

class UserName extends StatelessWidget {
  const UserName({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (BuildContext context, WidgetRef ref, Widget? child) {
        final StudentProfileModel? studentProfile =
            ref.watch(vtopDataProvider.select((value) => value.studentProfile));

        if (studentProfile != null) {
          return Text(
            studentProfile.firstName,
            style: Theme.of(context).textTheme.titleMedium,
          );
        } else {
          return Text(
            "Anonymous",
            style: Theme.of(context).textTheme.titleMedium,
          );
        }
      },
    );
  }
}
