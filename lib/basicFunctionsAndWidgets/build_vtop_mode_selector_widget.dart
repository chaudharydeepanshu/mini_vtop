import 'package:flutter/material.dart';
import 'package:mini_vtop/basicFunctionsAndWidgets/widget_size_limiter.dart';

class BuildVtopModeSelector extends StatefulWidget {
  const BuildVtopModeSelector(
      {Key? key,
      required this.screenBasedPixelWidth,
      required this.screenBasedPixelHeight,
      required this.dropdownItems,
      required this.dropdownValue,
      required this.onDropDownChanged})
      : super(key: key);

  final double screenBasedPixelWidth;
  final double screenBasedPixelHeight;

  final List<String> dropdownItems;

  final ValueChanged<String?> onDropDownChanged;

  final String dropdownValue;

  @override
  _BuildVtopModeSelectorState createState() => _BuildVtopModeSelectorState();
}

class _BuildVtopModeSelectorState extends State<BuildVtopModeSelector> {
  late final double _screenBasedPixelWidth = widget.screenBasedPixelWidth;

  late String _dropdownValue = widget.dropdownValue;

  late final List<String> _semesters = widget.dropdownItems;

  @override
  void didUpdateWidget(BuildVtopModeSelector oldWidget) {
    if (oldWidget.dropdownValue != widget.dropdownValue) {
      setState(() {
        _dropdownValue = widget.dropdownValue;
      });
    }
    super.didUpdateWidget(oldWidget);
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Flexible(
          flex: 1,
          child: Text(
            "VTOP Mode",
            overflow: TextOverflow.ellipsis,
            style: getDynamicTextStyle(
                textStyle: Theme.of(context).textTheme.bodyText1,
                sizeDecidingVariable: _screenBasedPixelWidth),
          ),
        ),
        Flexible(
          flex: 1,
          child: Container(
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(
                  widgetSizeProvider(
                      fixedSize: 10,
                      sizeDecidingVariable: _screenBasedPixelWidth),
                ),
                topRight: Radius.circular(
                  widgetSizeProvider(
                      fixedSize: 10,
                      sizeDecidingVariable: _screenBasedPixelWidth),
                ),
              ),
            ),
            child: DropdownButton<String>(
              // itemHeight: kMinInteractiveDimension,
              dropdownColor: Theme.of(context).colorScheme.primaryContainer,
              value: _dropdownValue,
              isExpanded: true,
              icon: Icon(
                Icons.arrow_downward,
                size: widgetSizeProvider(
                    fixedSize: 24,
                    sizeDecidingVariable: _screenBasedPixelWidth),
                color: Theme.of(context).colorScheme.onPrimary,
              ),
              elevation: 16,
              underline: Container(
                height: widgetSizeProvider(
                    fixedSize: 2, sizeDecidingVariable: _screenBasedPixelWidth),
              ),
              onChanged: (String? newValue) {
                widget.onDropDownChanged.call(newValue);
              },
              items: _semesters.map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Container(
                    // height: value == _dropdownValue
                    //     ? kMinInteractiveDimension
                    //     : null,
                    // color: value["semesterCode"] == dropdownValue ? const Color(0xff04294f) : null,
                    decoration: BoxDecoration(
                      color: value == _dropdownValue
                          ? Theme.of(context).colorScheme.primary
                          : null,
                      borderRadius: BorderRadius.all(
                        Radius.circular(
                          widgetSizeProvider(
                              fixedSize: 10,
                              sizeDecidingVariable: _screenBasedPixelWidth),
                        ),
                      ),
                    ),
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Row(
                        children: [
                          Padding(
                            padding: EdgeInsets.all(
                              widgetSizeProvider(
                                  fixedSize: 8,
                                  sizeDecidingVariable: _screenBasedPixelWidth),
                            ),
                            child: FittedBox(
                              fit: BoxFit.scaleDown,
                              child: Text(
                                value,
                                overflow: TextOverflow.ellipsis,
                                style: getDynamicTextStyle(
                                    textStyle: Theme.of(context)
                                        .textTheme
                                        .button
                                        ?.copyWith(
                                          color: value == _dropdownValue
                                              ? Theme.of(context)
                                                  .colorScheme
                                                  .onPrimary
                                              : Theme.of(context)
                                                  .colorScheme
                                                  .onPrimaryContainer,
                                        ),
                                    sizeDecidingVariable:
                                        _screenBasedPixelWidth),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ),
      ],
    );
  }
}
