import 'package:flutter/material.dart';

class LinearCompletionMeter extends StatefulWidget {
  const LinearCompletionMeter(
      {super.key,
      required this.progressInPercent,
      required this.showProgressLabel});

  final double progressInPercent;
  final bool showProgressLabel;

  @override
  State<LinearCompletionMeter> createState() => _LinearCompletionMeterState();
}

class _LinearCompletionMeterState extends State<LinearCompletionMeter>
    with SingleTickerProviderStateMixin {
  late AnimationController controller;
  late Animation<double> animation;

  @override
  void initState() {
    controller = AnimationController(
        duration: const Duration(milliseconds: 1500), vsync: this);
    animation = Tween(begin: 0.0, end: widget.progressInPercent / 100)
        .animate(controller)
      ..addListener(() {
        setState(() {
          // the state that has changed here is the animation object’s value
        });
      });
    controller.forward();
    super.initState();
  }

  @override
  void dispose() {
    controller.stop();
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant LinearCompletionMeter oldWidget) {
    if (oldWidget.progressInPercent != widget.progressInPercent) {
      controller.reset();
      animation = Tween(
              begin: oldWidget.progressInPercent / 100,
              end: widget.progressInPercent / 100)
          .animate(controller)
        ..addListener(() {
          setState(() {
            // the state that has changed here is the animation object’s value
          });
        });
      controller.forward();
    }
    super.didUpdateWidget(oldWidget);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        widget.showProgressLabel
            ? Align(
                alignment: Alignment.lerp(
                    Alignment.topLeft, Alignment.topRight, animation.value)!,
                child: Text(
                  "${(animation.value * 100).toStringAsFixed(2)} %",
                  style: Theme.of(context).textTheme.labelSmall,
                ),
              )
            : const SizedBox(),
        ClipRRect(
          borderRadius: const BorderRadius.all(Radius.circular(12)),
          child: LinearProgressIndicator(
            value: animation.value,
            backgroundColor: Theme.of(context).colorScheme.surfaceVariant,
            minHeight: 10,
          ),
        ),
      ],
    );
  }
}
