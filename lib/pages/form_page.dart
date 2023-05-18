import 'dart:math';

import 'package:flutter/material.dart';
import 'package:heart_beat_monitor/services/db_service.dart';
import 'package:heart_beat_monitor/services/preference_service.dart';
import 'package:heart_beat_monitor/models/user.dart';
import 'package:heart_beat_monitor/pages/home_page.dart';
import 'package:heart_beat_monitor/utils/constants.dart';
import 'package:heart_beat_monitor/widgets/athlete_switch.dart';
import 'package:heart_beat_monitor/widgets/cup_button.dart';

class FormPage extends StatefulWidget {
  const FormPage({super.key});

  @override
  State<FormPage> createState() => _FormPageState();
}

class _FormPageState extends State<FormPage> {
  bool isLoading = false;
  final _db = DBService();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _ageController = TextEditingController();
  final TextEditingController _emergencyNumberController =
      TextEditingController();
  bool isAthlete = false;

  void clearAllData() async {
    await PreferenceService.clearPreferences();
    await _db.deleteUsers();
    await _db.deleteSessions();
    await _db.deleteDatabase();
  }

  @override
  void initState() {
    super.initState();
    clearAllData();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _ageController.dispose();
    _emergencyNumberController.dispose();
    super.dispose();
  }

  void addUser(ThemeData theme) async {
    setState(() {
      isLoading = true;
    });

    int userID = Random().nextInt(99999);
    await _db
        .insertUser(
      User(
        id: userID,
        name: _nameController.text,
        age: int.parse(_ageController.text),
        emergencyNumber: int.parse(_emergencyNumberController.text),
        isAthlete: isAthlete.toString(),
      ),
    )
        .then((value) async {
      PreferenceService.setBoolPref();
      PreferenceService.setIDPref(userID);
      PreferenceService.setThemePref(kThemeKeyLight);
      PreferenceService.setSchemePref(kSchemeKeyRed);
      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => const HomePage(),
        ),
      );
      kSnakBar(
        theme,
        'Account created successfully!',
        const Duration(seconds: 2),
      );
      _nameController.clear();
      _ageController.clear();
      _emergencyNumberController.clear();
    });
    setState(() {
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);
    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        backgroundColor: theme.scaffoldBackgroundColor,
        body: isLoading
            ? Center(
                child: CircularProgressIndicator(
                  strokeWidth: 2.0,
                  color: theme.primaryColor,
                ),
              )
            : Center(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: SafeArea(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          vertical: 8.0, horizontal: 24.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 12.0),
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
                            padding: const EdgeInsets.symmetric(vertical: 12.0),
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
                            padding: const EdgeInsets.symmetric(vertical: 12.0),
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
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 8.0),
                                    child: Text(
                                      "Are you a professional athlete?",
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
                            onPress: () => addUser(theme),
                            text: 'let\'s go',
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
      ),
    );
  }
}
