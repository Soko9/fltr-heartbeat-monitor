import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:heart_beat_monitor/services/preference_service.dart';
import 'package:heart_beat_monitor/utils/constants.dart';

class ThemeService extends ChangeNotifier {
  final RxBool isDarkMode = false.obs;
  final RxString colorScheme = kSchemeKeyRed.obs;

  static Color lightRed = const Color(0xffE92C2C);
  static Color darkRed = const Color(0xffF96767);
  static Color lightBlue = const Color(0xff1272CC);
  static Color darkBlue = const Color(0xff45A5FF);
  static Color lightYellow = const Color(0xffF98600);
  static Color darkYellow = const Color(0xffFFB257);
  static Color lightGreen = const Color(0xff00952A);
  static Color darkGreen = const Color(0xff45D56D);

  static final kColorLight = const Color(0xffE92C2C).obs;
  static final kColorDark = const Color(0xffF96767).obs;

  static Color kColorLightBack = const Color(0xffffffff);
  static Color kColorLightGrey = const Color(0xffE7E7E7);
  static Color kColorLightText = const Color(0xff292929);

  static Color kColorDarkBack = const Color(0xff292929);
  static Color kColorDarkGrey = const Color(0xff585757);
  static Color kColorDarkText = const Color(0xffFAFAFA);

  ThemeMode get currentTheme =>
      isDarkMode.value ? ThemeMode.dark : ThemeMode.light;

  void getThemeAndColorScheme() async {
    String? theme = await PreferenceService.getThemePref();
    String? scheme = await PreferenceService.getSchemePref();

    if (theme != null) {
      if (theme == kThemeKeyLight) {
        isDarkMode.value = false;
      } else {
        isDarkMode.value = true;
      }
    }

    if (scheme != null) {
      changeColorScheme(scheme);
    }
  }

  void toggleTheme() async {
    await PreferenceService.setThemePref(
        isDarkMode.value ? kThemeKeyLight : kThemeKeyDark);
    isDarkMode.toggle();
    notifyListeners();
  }

  void changeColorScheme(String scheme) async {
    colorScheme.value = scheme;
    await PreferenceService.setSchemePref(scheme);
    switch (scheme) {
      case kSchemeKeyRed:
        kColorLight.value = lightRed;
        kColorDark.value = darkRed;
        break;
      case kSchemeKeyBlue:
        kColorLight.value = lightBlue;
        kColorDark.value = darkBlue;
        break;
      case kSchemeKeyYellow:
        kColorLight.value = lightYellow;
        kColorDark.value = darkYellow;
        break;
      case kSchemeKeyGreen:
        kColorLight.value = lightGreen;
        kColorDark.value = darkGreen;
        break;
      default:
        kColorLight.value = lightRed;
        kColorDark.value = darkRed;
    }
    notifyListeners();
  }

  static Rx<ThemeData> get lightMode => ThemeData(
        fontFamily: 'Changa',
        primaryColor: kColorLight.value,
        colorScheme: ColorScheme.fromSeed(
          seedColor: kColorLight.value,
          primary: kColorLight.value,
          secondary: kColorLight.value,
          tertiary: kColorLight.value,
          background: kColorLightGrey,
        ),
        scaffoldBackgroundColor: kColorLightBack,
        iconTheme: IconThemeData(
          color: kColorLight.value,
          size: 36.0,
          opacity: 1.0,
        ),
        textTheme: TextTheme(
          // For Button Text
          titleMedium: TextStyle(
            fontSize: 18.0,
            color: kColorLightBack,
            fontWeight: FontWeight.w600,
            letterSpacing: 2.2,
            height: 1.35,
          ),
          // For Containers Text
          displayLarge: TextStyle(
            fontSize: 48.0,
            fontWeight: FontWeight.w200,
            color: kColorLightText,
            height: 1.35,
          ),
          // For Chart Axis Text
          displaySmall: TextStyle(
            fontSize: 16.0,
            color: kColorLightText,
            letterSpacing: 3.0,
            textBaseline: TextBaseline.alphabetic,
            height: 1.35,
          ),
          // For Settings Titles
          displayMedium: TextStyle(
            fontSize: 24.0,
            color: kColorLight.value,
            letterSpacing: 1.5,
            height: 1.35,
          ),
          // For AppBar Titles
          titleLarge: TextStyle(
            color: kColorLight.value,
            letterSpacing: 2.0,
            height: 1.35,
          ),
          // For Sessions BPM Text
          labelLarge: const TextStyle(
            fontSize: 48.0,
            fontWeight: FontWeight.w800,
            height: 1.35,
          ),
          // For Text Fields Text
          labelMedium: TextStyle(
            fontSize: 22.0,
            color: kColorDarkGrey,
            letterSpacing: 1.5,
            height: 1.35,
          ),
          // For Sessions Date Text
          labelSmall: TextStyle(
            fontWeight: FontWeight.w200,
            fontSize: 22.0,
            color: kColorLightText,
            height: 1.35,
          ),
        ),
      ).obs;

  static Rx<ThemeData> get darkMode => ThemeData(
        fontFamily: 'Changa',
        primaryColor: kColorDark.value,
        colorScheme: ColorScheme.fromSeed(
          seedColor: kColorDark.value,
          primary: kColorDark.value,
          secondary: kColorDark.value,
          tertiary: kColorDark.value,
          background: kColorDarkGrey,
        ),
        scaffoldBackgroundColor: kColorDarkBack,
        iconTheme: IconThemeData(
          color: kColorDark.value,
          size: 36.0,
          opacity: 1.0,
        ),
        textTheme: TextTheme(
          // For Button Text
          titleMedium: TextStyle(
            fontSize: 18.0,
            color: kColorDarkBack,
            fontWeight: FontWeight.w600,
            letterSpacing: 2.2,
            height: 1.35,
          ),
          // For Containers Text
          displayLarge: TextStyle(
            fontSize: 48.0,
            fontWeight: FontWeight.w200,
            color: kColorDarkText,
            height: 1.35,
          ),
          // For Chart Axis Text
          displaySmall: TextStyle(
            fontSize: 16.0,
            color: kColorDarkText,
            letterSpacing: 3.0,
            textBaseline: TextBaseline.alphabetic,
            height: 1.35,
          ),
          // For Settings Titles
          displayMedium: TextStyle(
            fontSize: 24.0,
            color: kColorDark.value,
            letterSpacing: 1.5,
            height: 1.35,
          ),
          // For AppBar Titles
          titleLarge: TextStyle(
            color: kColorDark.value,
            letterSpacing: 2.0,
            height: 1.35,
          ),
          // For Sessions BPM Text
          labelLarge: const TextStyle(
            fontSize: 48.0,
            fontWeight: FontWeight.w800,
            height: 1.35,
          ),
          // For Text Fields Text
          labelMedium: TextStyle(
            fontSize: 22.0,
            color: kColorLightGrey,
            letterSpacing: 1.5,
            height: 1.35,
          ),
          // For Sessions Date Text
          labelSmall: TextStyle(
            fontWeight: FontWeight.w200,
            fontSize: 22.0,
            color: kColorDarkText,
            height: 1.35,
          ),
        ),
      ).obs;
}
