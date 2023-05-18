import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:heart_beat_monitor/services/preference_service.dart';
import 'package:heart_beat_monitor/pages/form_page.dart';
import 'package:heart_beat_monitor/pages/home_page.dart';
import 'package:heart_beat_monitor/services/theme_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    HeartBeatMonitorApp(
      isFirstTime: await PreferenceService.getBoolPref(),
    ),
  );
}

class HeartBeatMonitorApp extends StatefulWidget {
  const HeartBeatMonitorApp({
    super.key,
    required this.isFirstTime,
  });

  final bool? isFirstTime;

  @override
  State<HeartBeatMonitorApp> createState() => _HeartBeatMonitorAppState();
}

class _HeartBeatMonitorAppState extends State<HeartBeatMonitorApp> {
  ThemeService themeService = Get.put<ThemeService>(ThemeService());

  @override
  void initState() {
    super.initState();
    themeService.getThemeAndColorScheme();
    themeService.addListener(
      () {
        if (!mounted) return;
        setState(() {});
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => GetMaterialApp(
        title: 'Heart Beat Monitor',
        debugShowCheckedModeBanner: false,
        theme: ThemeService.lightMode.value,
        darkTheme: ThemeService.darkMode.value,
        themeMode: themeService.currentTheme,
        home: widget.isFirstTime == null ? const FormPage() : const HomePage(),
      ),
    );
  }
}
