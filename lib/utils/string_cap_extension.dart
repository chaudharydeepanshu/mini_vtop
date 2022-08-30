class CapString {
  String inCaps(String text) => '${text[0].toUpperCase()}${text.substring(1)}';
  String allInCaps(String text) => text.toUpperCase();
  String capitalizeFirstOfEach(String text) => text
      .split(" ")
      .map((str) => "${str[0].toUpperCase()}${str.substring(1).toLowerCase()}")
      .join(" ");
}
