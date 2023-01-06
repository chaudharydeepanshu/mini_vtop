class CapString {
  String inCaps(String text) => '${text[0].toUpperCase()}${text.substring(1)}';
  String allInCaps(String text) => text.toUpperCase();
  String capitalizeFirstOfEach(String text) => text
      .split(" ")
      .map((str) => "${str[0].toUpperCase()}${str.substring(1).toLowerCase()}")
      .join(" ");
  String capitalizeFirstOfEachExceptRomanNumerals(String text) {
    return text.split(" ").map((str) {
      if (str.startsWith(RegExp(r'[IVXLCDM]+'))) {
        // Preserve the case of Roman numerals
        return "${str[0].toUpperCase()}${str.substring(1)}";
      } else {
        // Capitalize the first letter of non-Roman numerals
        return "${str[0].toUpperCase()}${str.substring(1).toLowerCase()}";
      }
    }).join(" ");
  }
}

String toTitleCaseBeforeSemesterWord(String s) {
  List<String> listOfWords = s.split(" ");

  int indexOfWordSemester =
      listOfWords.indexWhere((element) => element.toLowerCase() == "semester");

  List<String> newListOfWords = [];
  for (int i = 0; i < listOfWords.length; i++) {
    if (i <= indexOfWordSemester) {
      newListOfWords.add(CapString().capitalizeFirstOfEach(listOfWords[i]));
    } else {
      newListOfWords.add(listOfWords[i]);
    }
  }
  return newListOfWords.join(" ");
}
