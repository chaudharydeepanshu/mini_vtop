import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_gauges/gauges.dart';

class CGPASection extends StatelessWidget {
  const CGPASection({super.key, required this.currentGPA});

  final double currentGPA;
  final double totalGPA = 10;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Text(
            "GPA",
            style: Theme.of(context).textTheme.titleLarge,
          ),
        ),
        const SizedBox(
          height: 8,
        ),
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
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      "Your GPA till now is $currentGPA / $totalGPA",
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    CGPAMeter(
                      currentGPA: currentGPA,
                      totalGPA: totalGPA,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class CGPAMeter extends StatelessWidget {
  const CGPAMeter({super.key, required this.currentGPA, required this.totalGPA});

  final double currentGPA;
  final double totalGPA;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 150,
      width: 150,
      constraints: const BoxConstraints(
        minWidth: 150,
        minHeight: 150,
      ),
      alignment: Alignment.centerLeft,
      child: SfRadialGauge(
        enableLoadingAnimation: true,
        // animationDuration: 3000,
        axes: <RadialAxis>[
          RadialAxis(
            minimum: 0,
            maximum: 100,
            radiusFactor: 0.85,
            canScaleToFit: true,
            startAngle: 270,
            showLabels: false,
            showTicks: false,
            endAngle: 270,
            axisLineStyle: const AxisLineStyle(
              thickness: 0.25,
              // color: Theme.of(context)
              //     .colorScheme
              //     .onSurfaceVariant
              //     .withOpacity(0.2),
              thicknessUnit: GaugeSizeUnit.factor,
            ),
            pointers: <GaugePointer>[
              RangePointer(
                enableAnimation: true,
                value: currentGPA / totalGPA * 100,
                // value: 45,
                width: 0.25,
                // pointerOffset: 0.1,
                sizeUnit: GaugeSizeUnit.factor,
                cornerStyle: CornerStyle.startCurve,
                color: Theme.of(context).colorScheme.onSurface,
                // gradient: SweepGradient(
                //   colors: [
                //     kOrangeColor,
                //     kOrangeColor.withOpacity(0.7),
                //   ],
                //   stops: const [
                //     0.25,
                //     0.75,
                //   ],
                // ),
              ),
              MarkerPointer(
                enableAnimation: true,
                value: currentGPA / totalGPA * 100,
                markerType: MarkerType.circle,
                // color: const Color.fromARGB(255, 251, 182, 78),
                markerWidth: 18,
                markerHeight: 18,
              )
            ],
            annotations: [
              GaugeAnnotation(
                positionFactor: 0.15,
                // angle: 90,
                widget: Text(
                  currentGPA.toStringAsFixed(2),
                  style: Theme.of(context).textTheme.displaySmall,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
