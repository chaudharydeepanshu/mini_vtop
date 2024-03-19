import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:minivtop/models/student_academics_model.dart';
import 'package:minivtop/shared_preferences/preferences.dart';
import 'package:minivtop/state/connection_state.dart';
import 'package:minivtop/state/providers.dart';
import 'package:minivtop/state/user_login_state.dart';
import 'package:minivtop/state/vtop_actions.dart';
import 'package:minivtop/state/vtop_data_state.dart';
import 'package:minivtop/ui/components/cached_mode_warning.dart';
import 'package:minivtop/ui/components/empty_content_indicator.dart';
import 'package:minivtop/ui/components/page_body_indicators.dart';
import 'package:minivtop/ui/header_section_screen/components/gpa_section.dart';

class AcademicsPage extends ConsumerStatefulWidget {
  const AcademicsPage({super.key});

  @override
  ConsumerState<AcademicsPage> createState() => _AcademicsState();
}

class _AcademicsState extends ConsumerState<AcademicsPage> {
  @override
  void initState() {
    final VTOPPageStatus studentGradeHistoryPageStatus =
        ref.read(vtopActionsProvider).studentGradeHistoryPageStatus;

    if (studentGradeHistoryPageStatus != VTOPPageStatus.loaded) {
      final VTOPActions readVTOPActionsProviderValue =
          ref.read(vtopActionsProvider);
      readVTOPActionsProviderValue.studentGradeHistoryAction();
    }

    super.initState();
  }

  refreshData(WidgetRef ref) {
    final VTOPActions readVTOPActionsProviderValue =
        ref.read(vtopActionsProvider);
    readVTOPActionsProviderValue.updateOfflineModeStatus(mode: false);
    readVTOPActionsProviderValue.studentGradeHistoryAction();
    readVTOPActionsProviderValue.updateStudentProfilePageStatus(
        status: VTOPPageStatus.processing);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Academics"),
        centerTitle: true,
      ),
      body: RefreshIndicator(
        child: Consumer(
          builder: (BuildContext context, WidgetRef ref, Widget? child) {
            final VTOPPageStatus studentGradeHistoryPageStatus = ref.watch(
                vtopActionsProvider
                    .select((value) => value.studentGradeHistoryPageStatus));

            final bool enableOfflineMode = ref.watch(
                vtopActionsProvider.select((value) => value.enableOfflineMode));

            if (enableOfflineMode == true) {
              final Preferences readPreferencesProviderValue =
                  ref.read(preferencesProvider);
              String? oldHTMLDoc =
                  readPreferencesProviderValue.academicsHTMLDoc;
              final VTOPData readVTOPDataProviderValue =
                  ref.read(vtopDataProvider);
              if (oldHTMLDoc != null) {
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  readVTOPDataProviderValue.setStudentAcademics(
                      studentGradeHistoryDocument: oldHTMLDoc);
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

            return studentGradeHistoryPageStatus == VTOPPageStatus.loaded ||
                    enableOfflineMode
                ? const Column(
                    children: [
                      CachedModeWarning(),
                      Expanded(child: AcademicsBody()),
                    ],
                  )
                : PageBodyIndicators(
                    pageStatus: studentGradeHistoryPageStatus,
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

class AcademicsBody extends StatelessWidget {
  const AcademicsBody({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (BuildContext context, WidgetRef ref, Widget? child) {
        final StudentAcademicsModel? studentAcademics = ref
            .watch(vtopDataProvider.select((value) => value.studentAcademics));

        if (studentAcademics != null) {
          return ListView(
            children: [
              CGPASection(
                currentGPA: studentAcademics.cgpa,
              ),
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
