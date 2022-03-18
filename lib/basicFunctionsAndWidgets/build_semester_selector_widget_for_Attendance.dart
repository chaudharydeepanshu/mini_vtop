import 'package:flutter/material.dart';
import 'package:mini_vtop/basicFunctionsAndWidgets/widget_size_limiter.dart';

class BuildSemesterSelectorForAttendance extends StatefulWidget {
  const BuildSemesterSelectorForAttendance(
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
  _BuildSemesterSelectorForAttendanceState createState() =>
      _BuildSemesterSelectorForAttendanceState();
}

class _BuildSemesterSelectorForAttendanceState
    extends State<BuildSemesterSelectorForAttendance> {
  late final double _screenBasedPixelWidth = widget.screenBasedPixelWidth;

  late String _dropdownValue = widget.dropdownValue;

  late final List<Map<String, String>> _semesters = widget.dropdownItems;

  @override
  void didUpdateWidget(BuildSemesterSelectorForAttendance oldWidget) {
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
            "Attendance",
            overflow: TextOverflow.ellipsis,
            style: getDynamicTextStyle(
                textStyle: Theme.of(context).textTheme.bodyText1,
                sizeDecidingVariable: _screenBasedPixelWidth),
          ),
        ),
        // SizedBox(
        //   width: widgetSizeProvider(
        //       fixedSize: 5, sizeDecidingVariable: _screenBasedPixelWidth),
        // ),
        Flexible(
          flex: 2,
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
                // color: Colors.white,
              ),
              elevation: 16,
              // style: const TextStyle(color: Colors.deepPurple),
              underline: Container(
                height: widgetSizeProvider(
                    fixedSize: 2, sizeDecidingVariable: _screenBasedPixelWidth),
                // color: Colors.deepPurpleAccent,
              ),
              onChanged: (String? newValue) {
                widget.onDropDownChanged.call(newValue);
              },
              items: _semesters
                  .map<DropdownMenuItem<String>>((Map<dynamic, dynamic> value) {
                return DropdownMenuItem<String>(
                  value: value["semesterCode"],
                  child: Container(
                    // width: 145,
                    // height: value["semesterCode"] == _dropdownValue
                    //     ? kMinInteractiveDimension
                    //     : null,
                    // color: value["semesterCode"] == dropdownValue ? const Color(0xff04294f) : null,
                    decoration: BoxDecoration(
                      color: value["semesterCode"] == _dropdownValue
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
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Padding(
                        padding: EdgeInsets.all(
                          widgetSizeProvider(
                              fixedSize: 8,
                              sizeDecidingVariable: _screenBasedPixelWidth),
                        ),
                        child: Text(
                          value["semesterName"],
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: getDynamicTextStyle(
                              textStyle: Theme.of(context)
                                  .textTheme
                                  .button
                                  ?.copyWith(
                                    color:
                                        value["semesterCode"] == _dropdownValue
                                            ? Theme.of(context)
                                                .colorScheme
                                                .onPrimary
                                            : Theme.of(context)
                                                .colorScheme
                                                .onPrimaryContainer,
                                  ),
                              sizeDecidingVariable: _screenBasedPixelWidth),
                        ),
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
