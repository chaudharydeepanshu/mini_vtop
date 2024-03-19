import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:minivtop/state/providers.dart';
import 'package:minivtop/state/vtop_actions.dart';

import '../../../models/student_profile_model.dart';
import '../../../shared_preferences/preferences.dart';
import '../../../state/connection_state.dart';
import '../../../state/user_login_state.dart';
import '../../../state/vtop_data_state.dart';
import '../../components/cached_mode_warning.dart';
import '../../components/empty_content_indicator.dart';
import '../../components/page_body_indicators.dart';

class StudentProfilePage extends ConsumerStatefulWidget {
  const StudentProfilePage({super.key});

  @override
  ConsumerState<StudentProfilePage> createState() => _StudentProfileState();
}

class _StudentProfileState extends ConsumerState<StudentProfilePage> {
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

  refreshData(WidgetRef ref) {
    final VTOPActions readVTOPActionsProviderValue =
        ref.read(vtopActionsProvider);
    readVTOPActionsProviderValue.studentProfileAllViewAction();
    readVTOPActionsProviderValue.updateStudentProfilePageStatus(
        status: VTOPPageStatus.processing);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Student Profile"),
        centerTitle: true,
      ),
      body: RefreshIndicator(
        child: Consumer(
          builder: (BuildContext context, WidgetRef ref, Widget? child) {
            final VTOPPageStatus studentProfilePageStatus = ref.watch(
                vtopActionsProvider
                    .select((value) => value.studentProfilePageStatus));

            final bool enableOfflineMode = ref.watch(
                vtopActionsProvider.select((value) => value.enableOfflineMode));

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

            ref.listen<ConnectionStatusState>(connectionStatusStateProvider,
                (ConnectionStatusState? previous, ConnectionStatusState next) {
              if (next.connectionStatus == ConnectionStatus.connected &&
                  ref.read(userLoginStateProvider).loginResponseStatus ==
                      LoginResponseStatus.loggedIn) {
                refreshData(ref);
              }
            });

            return studentProfilePageStatus == VTOPPageStatus.loaded ||
                    enableOfflineMode
                ? const Column(
                    children: [
                      CachedModeWarning(),
                      Expanded(child: StudentProfileBody()),
                    ],
                  )
                : PageBodyIndicators(
                    pageStatus: studentProfilePageStatus,
                    location: Location.afterHomeScreen);
          },
        ),
        onRefresh: () async {
          refreshData(ref);
        },
      ),
    );
  }
}

class StudentProfileBody extends StatelessWidget {
  const StudentProfileBody({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (BuildContext context, WidgetRef ref, Widget? child) {
        final StudentProfileModel? studentProfile =
            ref.watch(vtopDataProvider.select((value) => value.studentProfile));

        if (studentProfile != null) {
          return ListView(
            children: [
              Card(
                  clipBehavior: Clip.antiAlias,
                  margin: const EdgeInsets.symmetric(horizontal: 16.0),
                  // elevation: 0,
                  // shape: RoundedRectangleBorder(
                  //   side: BorderSide(
                  //     color: Theme.of(context).colorScheme.outline,
                  //   ),
                  //   borderRadius: const BorderRadius.all(Radius.circular(12)),
                  // ),
                  child: Column(
                    children: [
                      DetailLine(
                        parameter1: 'Name',
                        parameter2: studentProfile.name,
                      ),
                      const Divider(),
                      DetailLine(
                        parameter1: 'DOB',
                        parameter2: studentProfile.dob,
                      ),
                      const Divider(),
                      DetailLine(
                        parameter1: 'Blood Group',
                        parameter2: studentProfile.bloodGroup,
                      ),
                      const Divider(),
                      DetailLine(
                        parameter1: 'Roll No.',
                        parameter2: studentProfile.rollNo,
                      ),
                      const Divider(),
                      DetailLine(
                        parameter1: 'Application No.',
                        parameter2: studentProfile.applicationNo,
                      ),
                      const Divider(),
                      DetailLine(
                        parameter1: 'Program',
                        parameter2: studentProfile.program,
                      ),
                      const Divider(),
                      DetailLine(
                        parameter1: 'Branch',
                        parameter2: studentProfile.branch,
                      ),
                      const Divider(),
                      DetailLine(
                        parameter1: 'School',
                        parameter2: studentProfile.school,
                      ),
                    ],
                  )),
            ],
          );
        } else {
          return LayoutBuilder(
            builder: (context, constraints) => SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: SizedBox(
                height: constraints.maxHeight,
                child: const EmptyContentIndicator(),
              ),
            ),
          );
        }
      },
    );
  }
}

class DetailLine extends StatelessWidget {
  const DetailLine(
      {super.key, required this.parameter1, required this.parameter2});

  final String parameter1;
  final String parameter2;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: IntrinsicHeight(
        child: Row(
          children: [
            Expanded(
              flex: 5,
              child: Text(
                parameter1,
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ),
            const VerticalDivider(),
            Expanded(flex: 10, child: Text(parameter2)),
          ],
        ),
      ),
    );
  }
}
