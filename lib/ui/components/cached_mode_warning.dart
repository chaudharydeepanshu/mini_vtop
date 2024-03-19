import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:minivtop/state/providers.dart';

class CachedModeWarning extends StatelessWidget {
  const CachedModeWarning({super.key, this.supportsRefresh = true});

  final bool supportsRefresh;

  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (BuildContext context, WidgetRef ref, Widget? child) {
        final bool enableOfflineMode = ref.watch(
            vtopActionsProvider.select((value) => value.enableOfflineMode));

        return enableOfflineMode
            ? Container(
                color: Theme.of(context).colorScheme.errorContainer,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Expanded(
                          child: Text(
                            "You are using cached mode which means the data being shown is old.",
                            style: Theme.of(context)
                                .textTheme
                                .labelSmall
                                ?.copyWith(
                                  color: Theme.of(context)
                                      .colorScheme
                                      .onErrorContainer,
                                ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Expanded(
                          child: supportsRefresh
                              ? Text(
                                  "Swipe down to enable live mode.",
                                  style: Theme.of(context)
                                      .textTheme
                                      .labelSmall
                                      ?.copyWith(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .onErrorContainer,
                                      ),
                                  textAlign: TextAlign.center,
                                )
                              : const SizedBox(),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                  ],
                ),
              )
            : const SizedBox();
      },
    );
  }
}
