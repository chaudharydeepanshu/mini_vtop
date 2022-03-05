import 'package:flutter/material.dart';
import 'package:mini_vtop/basicFunctionsAndWidgets/widget_size_limiter.dart';

class BuildSemesterSelector extends StatefulWidget {
  const BuildSemesterSelector(
      {Key? key,
      required this.screenBasedPixelWidth,
      required this.screenBasedPixelHeight,
      required this.dropdownItems,
      required this.dropdownValue,
      required this.onDropDownChanged})
      : super(key: key);

  final double screenBasedPixelWidth;
  final double screenBasedPixelHeight;

  final List<Map<String, String>> dropdownItems;

  final ValueChanged<String?> onDropDownChanged;

  final String dropdownValue;

  @override
  _BuildSemesterSelectorState createState() => _BuildSemesterSelectorState();
}

class _BuildSemesterSelectorState extends State<BuildSemesterSelector> {
  late final double _screenBasedPixelWidth = widget.screenBasedPixelWidth;
  late final double _screenBasedPixelHeight = widget.screenBasedPixelHeight;

  late String _dropdownValue = widget.dropdownValue;

  late final List<Map<String, String>> _semesters = widget.dropdownItems;

  @override
  void didUpdateWidget(BuildSemesterSelector oldWidget) {
    if (oldWidget.dropdownValue != widget.dropdownValue) {
      setState(() {
        _dropdownValue = widget.dropdownValue;
      });
    }
    super.didUpdateWidget(oldWidget);
  }

  @override
  Widget build(BuildContext context) {
    return FittedBox(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            "Semester",
            style: getDynamicTextStyle(
                textStyle: Theme.of(context).textTheme.bodyText1,
                sizeDecidingVariable: _screenBasedPixelWidth),
          ),
          SizedBox(
            width: widgetSizeProvider(
                fixedSize: 5, sizeDecidingVariable: _screenBasedPixelWidth),
          ),
          SizedBox(
            width: widgetSizeProvider(
                fixedSize: 280, sizeDecidingVariable: _screenBasedPixelWidth),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                FittedBox(
                  fit: BoxFit.scaleDown,
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
                      itemHeight: kMinInteractiveDimension,
                      dropdownColor:
                          Theme.of(context).colorScheme.primaryContainer,
                      value: _dropdownValue,
                      // isExpanded: true,
                      icon: Icon(
                        Icons.arrow_downward,
                        size: widgetSizeProvider(
                            fixedSize: 24,
                            sizeDecidingVariable: _screenBasedPixelWidth),
                        color: Theme.of(context).colorScheme.onPrimary,
                        // color: Colors.white,
                      ),
                      elevation: 16,
                      // style: const TextStyle(color: Colors.deepPurple),
                      underline: Container(
                        height: widgetSizeProvider(
                            fixedSize: 2,
                            sizeDecidingVariable: _screenBasedPixelWidth),
                        // color: Colors.deepPurpleAccent,
                      ),
                      onChanged: (String? newValue) {
                        widget.onDropDownChanged.call(newValue);
                      },
                      items: _semesters.map<DropdownMenuItem<String>>(
                          (Map<dynamic, dynamic> value) {
                        return DropdownMenuItem<String>(
                          value: value["semesterCode"],
                          child: Container(
                            height: value["semesterCode"] == _dropdownValue
                                ? kMinInteractiveDimension
                                : null,
                            // color: value["semesterCode"] == dropdownValue ? const Color(0xff04294f) : null,
                            decoration: BoxDecoration(
                              color: value["semesterCode"] == _dropdownValue
                                  ? Theme.of(context).colorScheme.primary
                                  : null,
                              borderRadius: BorderRadius.all(
                                Radius.circular(
                                  widgetSizeProvider(
                                      fixedSize: 10,
                                      sizeDecidingVariable:
                                          _screenBasedPixelWidth),
                                ),
                              ),
                            ),
                            child: Row(
                              children: [
                                Padding(
                                  padding: EdgeInsets.all(
                                    widgetSizeProvider(
                                        fixedSize: 8,
                                        sizeDecidingVariable:
                                            _screenBasedPixelWidth),
                                  ),
                                  child: FittedBox(
                                    fit: BoxFit.scaleDown,
                                    child: Text(
                                      value["semesterName"],
                                      style: getDynamicTextStyle(
                                          textStyle: Theme.of(context)
                                              .textTheme
                                              .button
                                              ?.copyWith(
                                                color: value["semesterCode"] ==
                                                        _dropdownValue
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
                        );
                      }).toList(),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
