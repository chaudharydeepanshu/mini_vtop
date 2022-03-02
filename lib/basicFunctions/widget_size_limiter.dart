import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
// enum SizeType { width, height }
//
// double widgetSizeProvider({
//   required SizeType sizeType,
//   required BuildContext context,
//   required double fixedSize,
// }) {
//   double sizeDecidingVariable;
//   if (sizeType == SizeType.width) {
//     sizeDecidingVariable = MediaQuery.of(context).size.width * 0.0027625;
//   } else {
//     sizeDecidingVariable = MediaQuery.of(context).size.height * 0.00169;
//   }
//   return sizeDecidingVariable * fixedSize > fixedSize
//       ? fixedSize
//       : sizeDecidingVariable * fixedSize;
// }

double widgetSizeProvider({
  required double sizeDecidingVariable,
  required double fixedSize,
}) {
  return sizeDecidingVariable * fixedSize > fixedSize
      ? fixedSize
      : sizeDecidingVariable * fixedSize;
}

TextStyle? getDynamicTextStyle({
  required TextStyle? textStyle,
  required double sizeDecidingVariable,
}) {
  return textStyle?.copyWith(
    fontSize: widgetSizeProvider(
        fixedSize: (textStyle.fontSize)!,
        sizeDecidingVariable: sizeDecidingVariable),
  );
}

class SizeConfig {
  static MediaQueryData? _mediaQueryData;
  static double? screenWidth;
  static double? screenHeight;
  static double? blockSizeHorizontal;
  static double? blockSizeVertical;
  static double? _safeAreaHorizontal;
  static double? _safeAreaVertical;
  static double? safeBlockHorizontal;
  static double? safeBlockVertical;

  void init(BuildContext context) {
    _mediaQueryData = MediaQuery.of(context);
    screenWidth = _mediaQueryData?.size.width;
    screenHeight = _mediaQueryData?.size.height;
    blockSizeHorizontal = (screenWidth! / 100);
    blockSizeVertical = (screenHeight! / 100);
    _safeAreaHorizontal =
        (_mediaQueryData?.padding.left)! + (_mediaQueryData?.padding.right)!;
    _safeAreaVertical =
        ((_mediaQueryData?.padding.top)! + (_mediaQueryData?.padding.bottom)!);
    safeBlockHorizontal = (screenWidth! - _safeAreaHorizontal!) / 100;
    safeBlockVertical = (screenHeight! - _safeAreaVertical!) / 100;
  }
}
