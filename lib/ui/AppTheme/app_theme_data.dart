import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
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
      // primaryColor: const Color(0xFF030303),
      appBarTheme: AppBarTheme(
        backgroundColor: colorScheme.background,
        elevation: 0,
        iconTheme: IconThemeData(color: colorScheme.primary),
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
    );
  }

  static const _light = FontWeight.w300;
  static const _regular = FontWeight.w400;
  static const _medium = FontWeight.w500;
  static const _semiBold = FontWeight.w600;
  static const _bold = FontWeight.w700;

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

  static final TextTheme _textTheme = TextTheme(
    headline1: GoogleFonts.montserrat(
      fontWeight: _light,
      fontSize: 96.0,
    ),
    headline2: GoogleFonts.montserrat(
      fontWeight: _light,
      fontSize: 60.0,
    ),
    headline3: GoogleFonts.montserrat(
      fontWeight: _regular,
      fontSize: 48.0,
    ),
    headline4: GoogleFonts.montserrat(
      fontWeight: _regular,
      fontSize: 34.0,
    ),
    headline5: GoogleFonts.montserrat(
      fontWeight: _regular,
      fontSize: 24.0,
    ),
    headline6: GoogleFonts.oswald(
      fontWeight: _medium,
      fontSize: 20.0,
    ),
    subtitle1: GoogleFonts.montserrat(
      fontWeight: _regular,
      fontSize: 16.0,
    ),
    subtitle2: GoogleFonts.montserrat(
      fontWeight: _medium,
      fontSize: 14.0,
    ),
    bodyText1: GoogleFonts.montserrat(
      fontWeight: _regular,
      fontSize: 16.0,
    ),
    bodyText2: GoogleFonts.montserrat(
      fontWeight: _regular,
      fontSize: 14.0,
    ),
    caption: GoogleFonts.oswald(
      fontWeight: _regular,
      fontSize: 12.0,
    ),
    button: GoogleFonts.montserrat(
      fontWeight: _medium,
      fontSize: 14.0,
    ),
    overline: GoogleFonts.montserrat(
      fontWeight: _regular,
      fontSize: 10.0,
    ),
  );
}
