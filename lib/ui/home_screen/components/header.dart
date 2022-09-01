import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:mini_vtop/models/student_profile_model.dart';
import 'package:mini_vtop/ui/header_section_screen/quick_glance_screen.dart';

import 'package:mini_vtop/state/providers.dart';

import 'package:mini_vtop/state/vtop_actions.dart';

import '../../../state/vtop_data_state.dart';

class HomeHeader extends ConsumerStatefulWidget {
  const HomeHeader({Key? key}) : super(key: key);

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
      readVTOPActionsProviderValue.callStudentProfileAllView(context: context);
    }

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      margin: const EdgeInsets.symmetric(horizontal: 16.0),
      elevation: 0,
      shape: RoundedRectangleBorder(
        side: BorderSide(
          color: Theme.of(context).colorScheme.outline,
        ),
        borderRadius: const BorderRadius.all(Radius.circular(12)),
      ),
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

                    final VTOPData vtopData = ref.watch(vtopDataProvider);

                    return Row(
                      children: [
                        Text(
                          "Hello, ",
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        studentProfilePageStatus == VTOPPageStatus.loaded
                            ? Text(
                                vtopData.studentProfile.firstName,
                                style: Theme.of(context).textTheme.titleMedium,
                              )
                            : studentProfilePageStatus ==
                                    VTOPPageStatus.processing
                                ? SpinKitThreeBounce(
                                    size: 24,
                                    color:
                                        Theme.of(context).colorScheme.onSurface,
                                  )
                                : Text(
                                    "Error",
                                    style:
                                        Theme.of(context).textTheme.titleMedium,
                                  ),
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
            OutlinedButton.icon(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (BuildContext context) => const QuickGlance(),
                  ),
                );
              },
              icon: const Icon(Icons.arrow_forward),
              label: const Text("Quick Glance"),
            ),
          ],
        ),
      ),
    );
  }
}
