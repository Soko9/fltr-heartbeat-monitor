import 'package:flutter/material.dart';
import 'package:get/get.dart';

const String kPrefBoolKey = 'isFirstTime';
const String kPrefIDKey = 'userID';

const String kPrefThemeKey = 'themeMode';
const String kThemeKeyLight = 'lightTheme';
const String kThemeKeyDark = 'darkTheme';

const String kPrefSchemeKey = 'schemeColor';
const String kSchemeKeyRed = 'schemeColorRed';
const String kSchemeKeyBlue = 'schemeColorBlue';
const String kSchemeKeyYellow = 'schemeColorYellow';
const String kSchemeKeyGreen = 'schemeColorGreen';

const String kDBTableUserName = 'users';
const String kDBTableSessionName = 'sessions';
const String kDBPath =
    '/data/user/0/com.example.heart_beat_monitor/databasesheart_monitor_database.db';

InputDecoration kFormDecoration(ThemeData theme) => InputDecoration(
      contentPadding: const EdgeInsets.all(12.0),
      floatingLabelAlignment: FloatingLabelAlignment.center,
      filled: true,
      fillColor: theme.scaffoldBackgroundColor,
      border: OutlineInputBorder(
        borderSide: BorderSide(
          width: 2.0,
          color: theme.primaryColor,
        ),
        borderRadius: BorderRadius.circular(6.0),
      ),
      labelStyle: theme.textTheme.labelMedium,
      focusColor: theme.primaryColor,
      enabledBorder: OutlineInputBorder(
        borderSide: BorderSide(
          width: 2.0,
          color: theme.colorScheme.background,
        ),
        borderRadius: BorderRadius.circular(6.0),
      ),
      focusedBorder: OutlineInputBorder(
        borderSide: BorderSide(
          width: 2.0,
          color: theme.primaryColor,
        ),
        borderRadius: BorderRadius.circular(6.0),
      ),
      errorBorder: OutlineInputBorder(
        borderSide: const BorderSide(
          width: 2.0,
          color: Colors.purple,
        ),
        borderRadius: BorderRadius.circular(6.0),
      ),
      disabledBorder: OutlineInputBorder(
        borderSide: const BorderSide(
          width: 2.0,
          color: Colors.grey,
        ),
        borderRadius: BorderRadius.circular(6.0),
      ),
    );

SnackbarController kSnakBar(ThemeData theme, String text, Duration duration,
        [void Function(GetSnackBar)? onTap]) =>
    Get.snackbar(
      '',
      '',
      barBlur: 10.0,
      duration: duration,
      onTap: onTap,
      titleText: Text(
        text.toUpperCase(),
        textAlign: TextAlign.center,
        style: theme.textTheme.labelSmall?.copyWith(
          fontWeight: FontWeight.w700,
          fontSize: 18.0,
        ),
      ),
    );
