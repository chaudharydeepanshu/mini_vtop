import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mini_vtop/models/student_profile_model.dart';
import 'package:mini_vtop/ui/header_section_screen/quick_glance_screen.dart';

import '../../../state/providers.dart';
import '../../../state/vtop_data_state.dart';

class HomeHeader extends StatelessWidget {
  const HomeHeader({Key? key}) : super(key: key);

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
                    final StudentProfileModel studentProfile = ref.watch(
                        vtopDataProvider
                            .select((value) => value.studentProfile));

                    return Text(
                      "Hello, ${studentProfile.firstName}",
                      style: Theme.of(context).textTheme.titleMedium,
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
            OutlinedButton(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (BuildContext context) => const QuickGlance(),
                    ),
                  );
                },
                child: Row(
                  children: [
                    Icon(Icons.arrow_forward),
                    Text("Quick Glance"),
                  ],
                )),
          ],
        ),
      ),
    );
  }
}
