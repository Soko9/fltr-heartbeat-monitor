import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:heart_beat_monitor/pages/form_page.dart';
import 'package:heart_beat_monitor/services/db_service.dart';
import 'package:heart_beat_monitor/models/user.dart';
import 'package:heart_beat_monitor/pages/home_page.dart';
import 'package:heart_beat_monitor/services/theme_service.dart';
import 'package:heart_beat_monitor/utils/constants.dart';
import 'package:heart_beat_monitor/widgets/athlete_switch.dart';
import 'package:heart_beat_monitor/widgets/color_scheme_box.dart';
import 'package:heart_beat_monitor/widgets/cup_button.dart';
import 'package:heart_beat_monitor/widgets/settings_title.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({
    super.key,
    required this.user,
  });

  final User user;

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  ThemeService themeService = Get.put<ThemeService>(ThemeService());
  bool isLoading = false;
  final _db = DBService();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _ageController = TextEditingController();
  final TextEditingController _emergencyNumberController =
      TextEditingController();
  bool isAthlete = false;

  @override
  void initState() {
    super.initState();
    themeService.addListener(
      () {
        if (!mounted) return;
        setState(() {});
      },
    );
    setState(() {
      isLoading = true;
    });
    _nameController.text = widget.user.name;
    _ageController.text = widget.user.age.toString();
    _emergencyNumberController.text = widget.user.emergencyNumber.toString();
    setState(() {
      isAthlete = widget.user.isAthlete == "true" ? true : false;
      isLoading = false;
    });
  }

  @override
  void dispose() {
    // themeService.dispose();
    _nameController.dispose();
    _ageController.dispose();
    _emergencyNumberController.dispose();
    super.dispose();
  }

  void updateUser(ThemeData theme) async {
    setState(() {
      isLoading = true;
    });
    User current = widget.user;
    current.setName(_nameController.text);
    current.setAge(int.parse(_ageController.text));
    current.setEmergencyNumber(int.parse(_emergencyNumberController.text));
    current.setIsAthlete(isAthlete);

    await _db.updateUser(current).then((value) {
      setState(() {
        isLoading = false;
      });
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => const HomePage(),
        ),
      );
      kSnakBar(
        theme,
        'Info updated successfully!',
        const Duration(seconds: 2),
      );
      _nameController.clear();
      _ageController.clear();
      _emergencyNumberController.clear();
    });
  }

  void showInfo(ThemeData theme) {
    Get.defaultDialog(
      radius: 8.0,
      backgroundColor: theme.scaffoldBackgroundColor,
      titlePadding: const EdgeInsets.only(
        top: 26.0,
        left: 52.0,
        right: 52.0,
        bottom: 13,
      ),
      contentPadding: const EdgeInsets.all(13.0),
      title: 'ADDITIONAL INFO',
      titleStyle: theme.textTheme.displayMedium?.copyWith(
        fontSize: 26.0,
        fontWeight: FontWeight.w600,
      ),
      content: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              IconTheme(
                data: theme.iconTheme,
                child: const Icon(Icons.numbers_rounded),
              ),
              const SizedBox(
                width: 16.0,
              ),
              Text(
                '1.0.0',
                style: theme.textTheme.labelSmall
                    ?.copyWith(fontWeight: FontWeight.w600),
              ),
            ],
          ),
          const SizedBox(
            height: 32.0,
          ),
          OutlinedButton(
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => const FormPage(),
                ),
              );
            },
            child: Text(
              "Delete My Account",
              style: theme.textTheme.displayMedium?.copyWith(
                fontWeight: FontWeight.w400,
                fontSize: 22.0,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);
    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        backgroundColor: theme.scaffoldBackgroundColor,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          title: Text(
            'Settings'.toUpperCase(),
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w300,
              fontSize: 24.0,
              height: 2.0,
            ),
          ),
          centerTitle: true,
          elevation: 0.0,
          leading: IconButton(
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => const HomePage(),
                ),
              );
            },
            icon: IconTheme(
              data: theme.iconTheme,
              child: const Icon(Icons.chevron_left_outlined),
            ),
          ),
          actions: [
            Padding(
              padding: const EdgeInsets.only(right: 8.0),
              child: IconButton(
                onPressed: () => showInfo(theme),
                icon: IconTheme(
                  data: theme.iconTheme.copyWith(size: 32.0),
                  child: const Icon(Icons.info_rounded),
                ),
              ),
            ),
          ],
        ),
        body: isLoading
            ? Center(
                child: CircularProgressIndicator(
                  strokeWidth: 2.0,
                  color: theme.primaryColor,
                ),
              )
            : SafeArea(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                      vertical: 8.0, horizontal: 24.0),
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const SettingsTitle(
                          title: 'user data',
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 16.0),
                          child: TextFormField(
                            controller: _nameController,
                            keyboardType: TextInputType.name,
                            style: theme.textTheme.labelMedium,
                            decoration: kFormDecoration(theme).copyWith(
                              labelText: 'Name',
                              prefixIcon: IconTheme(
                                data: theme.iconTheme,
                                child: const Icon(Icons.text_fields),
                              ),
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 16.0),
                          child: TextField(
                            controller: _ageController,
                            keyboardType: TextInputType.number,
                            style: theme.textTheme.labelMedium,
                            decoration: kFormDecoration(theme).copyWith(
                              labelText: 'Year Of Birth',
                              prefixIcon: IconTheme(
                                data: theme.iconTheme,
                                child: const Icon(Icons.cake_rounded),
                              ),
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 16.0),
                          child: TextField(
                            controller: _emergencyNumberController,
                            keyboardType: TextInputType.number,
                            style: theme.textTheme.labelMedium,
                            decoration: kFormDecoration(theme).copyWith(
                              labelText: 'Emergency Number',
                              prefixIcon: IconTheme(
                                data: theme.iconTheme,
                                child: const Icon(Icons.emergency_rounded),
                              ),
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 12.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Expanded(
                                child: Padding(
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 8.0),
                                  child: Text(
                                    "Are you still a professional athlete?",
                                    style: theme.textTheme.labelMedium,
                                  ),
                                ),
                              ),
                              AthleteSwitch(
                                isAthlete: isAthlete,
                                onSwitch: () {
                                  setState(() {
                                    isAthlete = !isAthlete;
                                  });
                                },
                              ),
                            ],
                          ),
                        ),
                        CupButton(
                          onPress: () => updateUser(theme),
                          text: 'update info',
                        ),
                        const SettingsTitle(
                          title: 'app info',
                          margin: EdgeInsets.only(
                            top: 58.0,
                            bottom: 8.0,
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 16.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Expanded(
                                child: Text(
                                  'Theme',
                                  style: theme.textTheme.titleLarge?.copyWith(
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                              IconTheme(
                                data: theme.iconTheme,
                                child: const Icon(Icons.wb_sunny_rounded),
                              ),
                              const SizedBox(width: 12.0),
                              Obx(
                                () => CupertinoSwitch(
                                  value: themeService.isDarkMode.value,
                                  activeColor: theme.colorScheme.background,
                                  trackColor: theme.colorScheme.background,
                                  thumbColor: theme.primaryColor,
                                  onChanged: (value) {
                                    setState(() {
                                      isLoading = true;
                                    });
                                    themeService.toggleTheme();
                                    setState(() {
                                      isLoading = false;
                                    });
                                  },
                                ),
                              ),
                              const SizedBox(width: 12.0),
                              IconTheme(
                                data: theme.iconTheme,
                                child: const Icon(Icons.dark_mode_rounded),
                              ),
                            ],
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 16.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Expanded(
                                child: Text(
                                  'Color Scheme',
                                  style: theme.textTheme.titleLarge?.copyWith(
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                              ColorSchemeBox(
                                onPress: () {
                                  setState(() {
                                    isLoading = true;
                                  });
                                  themeService.changeColorScheme(kSchemeKeyRed);
                                  setState(() {
                                    isLoading = false;
                                  });
                                },
                                lightColor: ThemeService.lightRed,
                                darkColor: ThemeService.darkRed,
                              ),
                              ColorSchemeBox(
                                onPress: () {
                                  setState(() {
                                    isLoading = true;
                                  });
                                  themeService
                                      .changeColorScheme(kSchemeKeyBlue);
                                  setState(() {
                                    isLoading = false;
                                  });
                                },
                                lightColor: ThemeService.lightBlue,
                                darkColor: ThemeService.darkBlue,
                              ),
                              ColorSchemeBox(
                                onPress: () {
                                  setState(() {
                                    isLoading = true;
                                  });
                                  themeService
                                      .changeColorScheme(kSchemeKeyYellow);
                                  setState(() {
                                    isLoading = false;
                                  });
                                },
                                lightColor: ThemeService.lightYellow,
                                darkColor: ThemeService.darkYellow,
                              ),
                              ColorSchemeBox(
                                onPress: () {
                                  setState(() {
                                    isLoading = true;
                                  });
                                  themeService
                                      .changeColorScheme(kSchemeKeyGreen);
                                  setState(() {
                                    isLoading = false;
                                  });
                                },
                                lightColor: ThemeService.lightGreen,
                                darkColor: ThemeService.darkGreen,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
      ),
    );
  }
}
