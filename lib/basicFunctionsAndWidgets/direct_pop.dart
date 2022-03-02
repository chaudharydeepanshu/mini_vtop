import 'package:flutter/cupertino.dart';

Future<bool> directPop(
    {required ValueChanged<bool> onProcessingSomething}) async {
  onProcessingSomething.call(false);
  debugPrint('Direct Pop');
  return true;
}
