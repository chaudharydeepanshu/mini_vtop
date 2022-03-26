import 'package:flutter/material.dart';
import 'lib_color_schemes.g.dart';

class AppThemeData {
  static const _lightFillColor = Colors.black;
  static const _darkFillColor = Colors.white;

  static final Color _lightFocusColor = Colors.black.withOpacity(0.12);
  static final Color _darkFocusColor = Colors.white.withOpacity(0.12);

  static ThemeData lightThemeData =
      themeData(lightColorScheme, _lightFocusColor);
  static ThemeData darkThemeData = themeData(darkColorScheme, _darkFocusColor);

  static ThemeData themeData(ColorScheme colorScheme, Color focusColor) {
    return ThemeData(
      colorScheme: colorScheme,
      textTheme: _textTheme,
      // Matches manifest.json colors and background color.
      primaryColor: colorScheme.primary,
      appBarTheme: AppBarTheme(
        backgroundColor: colorScheme.background,
        elevation: 0,
        iconTheme: IconThemeData(color: colorScheme.primary),
        titleTextStyle: _textTheme.headline6!.apply(color: colorScheme.primary),
      ),
      tabBarTheme: TabBarTheme(
        labelColor: colorScheme.primary,
      ),
      iconTheme: IconThemeData(color: colorScheme.primary),
      canvasColor: colorScheme.background,
      scaffoldBackgroundColor: colorScheme.background,
      highlightColor: Colors.transparent,
      focusColor: focusColor,
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: Color.alphaBlend(
          _lightFillColor.withOpacity(0.80),
          _darkFillColor,
        ),
        contentTextStyle: _textTheme.subtitle1!.apply(color: _darkFillColor),
      ),
      backgroundColor: colorScheme.background,
      checkboxTheme: CheckboxThemeData(
        fillColor: MaterialStateProperty.all(
          colorScheme.primary,
        ),
        checkColor: MaterialStateProperty.all(
          colorScheme.onPrimary,
        ),
      ),
    );
  }

  static const _light = FontWeight.w300;
  static const _regular = FontWeight.w400;
  static const _medium = FontWeight.w500;
  // static const _semiBold = FontWeight.w600;
  // static const _bold = FontWeight.w700;

  // For reference
  // textAppearanceHeadline1	Light 96sp
  // textAppearanceHeadline2	Light 60sp
  // textAppearanceHeadline3	Regular 48sp
  // textAppearanceHeadline4	Regular 34sp
  // textAppearanceHeadline5	Regular 24sp
  // textAppearanceHeadline6	Medium 20sp
  // textAppearanceSubtitle1	Regular 16sp
  // textAppearanceSubtitle2	Medium 14sp
  // textAppearanceBody1	Regular 16sp
  // textAppearanceBody2	Regular 14sp
  // textAppearanceCaption	Regular 12sp
  // textAppearanceButton	Medium all caps 14sp
  // textAppearanceOverline	Regular all caps 10sp
  // {
  //   FontWeight.w100: 'Thin',
  //   FontWeight.w200: 'ExtraLight',
  //   FontWeight.w300: 'Light',
  //   FontWeight.w400: 'Regular',
  //   FontWeight.w500: 'Medium',
  //   FontWeight.w600: 'SemiBold',
  //   FontWeight.w700: 'Bold',
  //   FontWeight.w800: 'ExtraBold',
  //   FontWeight.w900: 'Black',
  // }

  static const TextTheme _textTheme = TextTheme(
    headline1: TextStyle(
      fontFamily: 'Montserrat',
      fontWeight: _light,
      fontSize: 96.0,
    ),
    headline2: TextStyle(
      fontFamily: 'Montserrat',
      fontWeight: _light,
      fontSize: 60.0,
    ),
    headline3: TextStyle(
      fontFamily: 'Montserrat',
      fontWeight: _regular,
      fontSize: 48.0,
    ),
    headline4: TextStyle(
      fontFamily: 'Montserrat',
      fontWeight: _regular,
      fontSize: 34.0,
    ),
    headline5: TextStyle(
      fontFamily: 'Montserrat',
      fontWeight: _regular,
      fontSize: 24.0,
    ),
    headline6: TextStyle(
      fontFamily: 'Oswald',
      fontWeight: _medium,
      fontSize: 20.0,
    ),
    subtitle1: TextStyle(
      fontFamily: 'Montserrat',
      fontWeight: _regular,
      fontSize: 16.0,
    ),
    subtitle2: TextStyle(
      fontFamily: 'Montserrat',
      fontWeight: _medium,
      fontSize: 14.0,
    ),
    bodyText1: TextStyle(
      fontFamily: 'Montserrat',
      fontWeight: _regular,
      fontSize: 16.0,
    ),
    bodyText2: TextStyle(
      fontFamily: 'Montserrat',
      fontWeight: _regular,
      fontSize: 14.0,
    ),
    caption: TextStyle(
      fontFamily: 'Oswald',
      fontWeight: _regular,
      fontSize: 12.0,
    ),
    button: TextStyle(
      fontFamily: 'Montserrat',
      fontWeight: _medium,
      fontSize: 14.0,
    ),
    overline: TextStyle(
      fontFamily: 'Montserrat',
      fontWeight: _regular,
      fontSize: 10.0,
    ),
  );
}
