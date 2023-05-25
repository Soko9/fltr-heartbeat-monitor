import 'dart:async';
import 'dart:math';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:heart_beat_monitor/models/session.dart';
import 'package:heart_beat_monitor/services/db_service.dart';
import 'package:heart_beat_monitor/services/preference_service.dart';
import 'package:heart_beat_monitor/models/sensor_data.dart';
import 'package:heart_beat_monitor/models/user.dart';
import 'package:heart_beat_monitor/pages/sessions_page.dart';
import 'package:heart_beat_monitor/pages/settings_page.dart';
import 'package:heart_beat_monitor/services/theme_service.dart';
import 'package:heart_beat_monitor/widgets/data_chart.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:wakelock/wakelock.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with TickerProviderStateMixin {
  final ThemeService themeService = Get.put<ThemeService>(ThemeService());

  bool isLoading = false;
  User? currentUser;
  bool _toggled = false;
  bool _processing = false;

  final double _alpha = 0.3;
  final List<int> _bpmValues = [];
  int _bpm = 0;

  final List<SensorData> _data = [];
  CameraController? _cameraController;

  Future<void> _initController() async {
    try {
      List cameras = await availableCameras();
      _cameraController = CameraController(cameras.first, ResolutionPreset.low);
      await _cameraController!.initialize();
      Future.delayed(const Duration(milliseconds: 500), () {
        _cameraController!.setFlashMode(FlashMode.torch);
      });
      _cameraController!.startImageStream((image) {
        if (!_processing) {
          setState(() => _processing = true);
          _scanImage(image: image);
        }
      });
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  void _scanImage({required CameraImage image}) {
    final bytes = image.planes.first.bytes;
    double avg =
        bytes.reduce((value, element) => value + element) / bytes.length;
    if (_data.length >= 50) setState(() => _data.removeAt(0));
    setState(() => _data.add(SensorData(time: DateTime.now(), value: avg)));
    Future.delayed(const Duration(milliseconds: 1000 ~/ 30), () {
      setState(() => _processing = false);
    });
  }

  void _disposeController() {
    _cameraController?.dispose();
    _cameraController = null;
  }

  void _updateBPM(BuildContext context, ThemeData theme) async {
    List<SensorData> sensorData;
    double avg, maxValue, threshold, bpm;
    int listLength, counter, previous;
    while (_toggled) {
      maxValue = 0;
      avg = 0.0;
      bpm = 0;
      counter = 0;
      previous = 0;
      sensorData = List.from(_data);
      listLength = sensorData.length;
      for (SensorData data in sensorData) {
        avg += data.value / listLength;
        if (data.value > maxValue) maxValue = data.value;
      }
      threshold = (maxValue + avg) / 2;
      for (int i = 1; i < listLength; i++) {
        if (sensorData[i - 1].value < threshold &&
            sensorData[i].value > threshold) {
          if (previous != 0) {
            counter++;
            bpm +=
                60000 / (sensorData[i].time.millisecondsSinceEpoch - previous);
          }
          previous = sensorData[i].time.millisecondsSinceEpoch;
        }
      }
      if (counter > 0) {
        bpm /= counter;
        Map<String, int> range = currentUser!.getBPMRange();
        int bound = (range["bound"]! * 0.035).toInt();
        setState(() {
          if (_bpmValues.length < 100) {
            _bpm = ((1 - _alpha) * bpm + _alpha * bpm).round();
            if (_bpm >= range["min"]! - bound &&
                _bpm <= range["max"]! + bound) {
              _bpmValues.add(_bpm);
            }
          } else {
            _bpmValues.sort();
            print(_bpmValues);
            print(currentUser!.getBPMRange());
            print((currentUser!.getBPMRange()["bound"]! * 0.035).toInt());
            // _bpm = calculateBPMUsingMiddle(_bpmValues);
            // print("------------------");
            _bpm = calculateBPMUsingPart(_bpmValues);
            _finishPPG(context, theme);
          }
        });
      }
      await Future.delayed(const Duration(milliseconds: 1000 ~/ 30));
    }
  }

  int calculateBPMUsingMiddle(List<int> bpmValues) {
    int bpm = 0;
    int total = bpmValues.reduce((value, element) => value + element);
    int avg = total ~/ 100;
    int middle = bpmValues[49];
    // print(middle);
    // print(avg);
    if (avg < middle) {
      List<int> maxSub = bpmValues.sublist(90);
      int newAvg = maxSub.reduce((value, element) => value + element) ~/ 10;
      bpm = newAvg;
    } else if (avg > middle) {
      List<int> minSub = bpmValues.sublist(0, 11);
      int newAvg = minSub.reduce((value, element) => value + element) ~/ 10;
      bpm = newAvg;
    } else {
      bpm = avg;
    }
    // print(bpm);
    return bpm;
  }

  int calculateBPMUsingPart(List<int> bpmValues) {
    int bpm = 0;
    int countMin = 0;
    int countMax = 0;
    for (int value in bpmValues) {
      if (value < currentUser!.getBPMRange()["min"]!) countMin++;
      if (value > currentUser!.getBPMRange()["max"]!) countMax++;
    }
    print(countMin);
    print(countMax);
    if (countMin < countMax) {
      List<int> maxSub = bpmValues.sublist(90);
      print(maxSub);
      int newAvg = maxSub.reduce((value, element) => value + element) ~/ 10;
      bpm = (newAvg - (currentUser!.getBPMRange()["bound"]! * 0.035)).toInt();
    } else if (countMin > countMax) {
      List<int> minSub = bpmValues.sublist(0, 10);
      print(minSub);
      int newAvg = minSub.reduce((value, element) => value + element) ~/ 10;
      bpm = (newAvg + (currentUser!.getBPMRange()["bound"]! * 0.035)).toInt();
    } else {
      bpm = bpmValues[49];
    }
    print(bpm);
    return bpm;
  }

  Future<void> callEmergency(BuildContext context, ThemeData theme) async {
    Navigator.pop(context);
    addSession(context, theme);
    final Uri launchUri = Uri(
      scheme: 'tel',
      path: currentUser!.emergencyNumber.toString().trim(),
    );
    await launchUrl(
      launchUri,
      mode: LaunchMode.platformDefault,
    );
  }

  void showEmergencyDialog(BuildContext context, ThemeData theme) {
    Get.defaultDialog(
      radius: 8.0,
      barrierDismissible: false,
      backgroundColor: theme.scaffoldBackgroundColor,
      titlePadding: const EdgeInsets.only(
        top: 26.0,
        left: 13.0,
        right: 13.0,
        bottom: 13,
      ),
      contentPadding:
          const EdgeInsets.symmetric(horizontal: 13.0, vertical: 13.0),
      title: 'Your BPM Is Not In The Normal Range'.toUpperCase(),
      titleStyle: theme.textTheme.displayMedium?.copyWith(
        fontSize: 18.0,
        fontWeight: FontWeight.w600,
      ),
      content: Text(
        'Do You Want To Call The Emergency Number Now?'.toUpperCase(),
        style: theme.textTheme.displayMedium?.copyWith(
          fontSize: 14.0,
          fontWeight: FontWeight.w400,
        ),
      ),
      confirm: Padding(
        padding: const EdgeInsets.only(top: 13.0),
        child: TextButton(
          style: TextButton.styleFrom(
            backgroundColor: theme.primaryColor,
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            shape: RoundedRectangleBorder(
              side: BorderSide(
                color: theme.colorScheme.secondary,
                width: 2,
                style: BorderStyle.solid,
              ),
              borderRadius: BorderRadius.circular(12.0),
            ),
          ),
          onPressed: () => callEmergency(context, theme),
          child: Text(
            'YES, NOW',
            style: theme.textTheme.displayMedium?.copyWith(
              fontSize: 16.0,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
        ),
      ),
      cancel: Padding(
        padding: const EdgeInsets.only(top: 13.0),
        child: TextButton(
          style: TextButton.styleFrom(
            backgroundColor: theme.scaffoldBackgroundColor,
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            shape: RoundedRectangleBorder(
              side: BorderSide(
                color: theme.colorScheme.secondary,
                width: 2,
                style: BorderStyle.solid,
              ),
              borderRadius: BorderRadius.circular(12.0),
            ),
          ),
          onPressed: () => Navigator.pop(context),
          child: Text(
            'NO, IT\'S OKAY',
            style: theme.textTheme.displayMedium?.copyWith(
              fontSize: 16.0,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ),
    );
  }

  void addSession(BuildContext context, ThemeData theme) async {
    final db = DBService();
    Session session = Session(
      id: Random().nextInt(88888),
      dateTime: DateTime.now().toString(),
      bpm: _bpm,
      userID: currentUser!.id,
    );
    await db.insertSession(session);
    setState(() {
      _bpm = 0;
      _bpmValues.clear();
      _data.clear();
    });
    // else {
    //   kSnakBar(
    //     theme,
    //     'A Session was added to the log\nCheck it out!',
    //     const Duration(seconds: 3),
    //     (_) {
    //       Navigator.push(
    //         context,
    //         MaterialPageRoute(
    //           builder: (context) => SessionsPage(user: currentUser!),
    //         ),
    //       );
    //     },
    //   );
    // }
  }

  void _startPPG(BuildContext context, ThemeData theme) {
    _initController().then(
      (value) {
        Wakelock.enable();
        setState(() {
          _toggled = true;
          _processing = false;
        });
        _updateBPM(context, theme);
      },
    );
  }

  void _finishPPG(BuildContext context, ThemeData theme) {
    _disposeController();
    Wakelock.disable();
    setState(() {
      _processing = false;
      _toggled = false;
    });
    if (_bpm < currentUser!.getBPMRange()['min']! ||
        _bpm > currentUser!.getBPMRange()['max']!) {
      if (!mounted) return;
      showEmergencyDialog(context, theme);
    }
  }

  void getData() async {
    setState(() {
      isLoading = true;
    });
    int? id = await PreferenceService.getIDPref();
    User current = await DBService().getUserByID(id!);
    setState(() {
      currentUser = current;
      isLoading = false;
    });
  }

  @override
  void initState() {
    super.initState();
    themeService.addListener(
      () {
        if (!mounted) return;
        setState(() {});
      },
    );
    getData();
  }

  @override
  void dispose() {
    _disposeController();
    // themeService.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);
    return isLoading
        ? Scaffold(
            backgroundColor: theme.scaffoldBackgroundColor,
            body: Center(
              child: CircularProgressIndicator(
                strokeWidth: 2.0,
                color: theme.primaryColor,
              ),
            ),
          )
        : Scaffold(
            backgroundColor: theme.scaffoldBackgroundColor,
            appBar: AppBar(
              backgroundColor: Colors.transparent,
              excludeHeaderSemantics: true,
              title: Text(
                currentUser!.name.toUpperCase(),
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w300,
                  fontSize: 24.0,
                  height: 2.0,
                ),
              ),
              centerTitle: true,
              elevation: 0.0,
              leading: IconButton(
                onPressed: _toggled || _bpm != 0
                    ? null
                    : () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (context) => SessionsPage(
                              user: currentUser!,
                            ),
                          ),
                        );
                      },
                icon: IconTheme(
                  data: theme.iconTheme,
                  child: const Icon(Icons.web_stories),
                ),
              ),
              actions: [
                Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: IconButton(
                    onPressed: _toggled || _bpm != 0
                        ? null
                        : () {
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    SettingsPage(user: currentUser!),
                              ),
                            );
                          },
                    icon: IconTheme(
                      data: theme.iconTheme,
                      child: const Icon(Icons.settings_rounded),
                    ),
                  ),
                ),
              ],
            ),
            body: SafeArea(
              child: Column(
                children: [
                  Expanded(
                    flex: 3,
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Row(
                        children: [
                          Expanded(
                            flex: 6,
                            child: Padding(
                              padding: _toggled || _bpm != 0
                                  ? const EdgeInsets.all(24.0)
                                  : const EdgeInsets.all(0.0),
                              child: Center(
                                child: _cameraController == null
                                    ? Container(
                                        width: double.maxFinite,
                                        decoration: BoxDecoration(
                                          color: theme.colorScheme.background,
                                          borderRadius:
                                              BorderRadius.circular(100.0),
                                        ),
                                      )
                                    : Container(
                                        width: double.maxFinite,
                                        decoration: BoxDecoration(
                                          color: theme.colorScheme.background,
                                          borderRadius:
                                              BorderRadius.circular(100.0),
                                        ),
                                        child: ClipRRect(
                                          borderRadius:
                                              BorderRadius.circular(100.0),
                                          child:
                                              CameraPreview(_cameraController!),
                                        ),
                                      ),
                              ),
                            ),
                          ),
                          Expanded(
                            child: Container(),
                          ),
                          Expanded(
                            flex: 6,
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.transparent,
                                borderRadius: BorderRadius.circular(200.0),
                              ),
                              child: Center(
                                child: !_toggled && _bpm != 0
                                    ? GestureDetector(
                                        onTap: () {
                                          addSession(context, theme);
                                        },
                                        child: IconTheme(
                                          data: theme.iconTheme
                                              .copyWith(size: 111.0),
                                          child: const Icon(
                                            Icons.done_outline_rounded,
                                          ),
                                        ),
                                      )
                                    : SizedBox(
                                        width: 120.0,
                                        height: 120.0,
                                        child: CircularProgressIndicator(
                                          value: _bpmValues.length.toDouble() /
                                              100.0,
                                          color: ThemeService.kColorDark.value,
                                          backgroundColor: ThemeService
                                              .kColorDark.value
                                              .withOpacity(0.3),
                                          strokeWidth: 50.0,
                                        ),
                                      ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  !_toggled && _bpm != 0
                      ? Expanded(
                          flex: 3,
                          child: GestureDetector(
                            onTap: () {
                              addSession(context, theme);
                            },
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Text(
                                  "BPM",
                                  textAlign: TextAlign.center,
                                  style: theme.textTheme.displaySmall!.copyWith(
                                    color: ThemeService.kColorDark.value,
                                    fontSize: 24.0,
                                  ),
                                ),
                                Expanded(
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceEvenly,
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      Text(
                                        "min\n${currentUser!.getBPMRange()["min"].toString()}",
                                        textAlign: TextAlign.center,
                                        style: theme.textTheme.displaySmall!
                                            .copyWith(
                                          color: ThemeService.kColorDark.value,
                                        ),
                                      ),
                                      Text(
                                        _bpm.toString(),
                                        textAlign: TextAlign.center,
                                        style: theme.textTheme.displayLarge!
                                            .copyWith(
                                          fontSize: 140.0,
                                          height: 1.1,
                                          fontWeight: FontWeight.w900,
                                          color: ThemeService.kColorDark.value,
                                        ),
                                      ),
                                      Text(
                                        "max\n${currentUser!.getBPMRange()["max"].toString()}",
                                        textAlign: TextAlign.center,
                                        style: theme.textTheme.displaySmall!
                                            .copyWith(
                                          color: ThemeService.kColorDark.value,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        )
                      : const SizedBox(),
                  Expanded(
                    flex: 4,
                    child: Container(
                      decoration: BoxDecoration(
                        color: theme.colorScheme.background,
                        borderRadius: const BorderRadius.all(
                          Radius.circular(8.0),
                        ),
                      ),
                      margin: const EdgeInsets.all(12.0),
                      child: Obx(
                        () => DataChart(
                          data: _data,
                          scheme: themeService.colorScheme.value,
                        ),
                      ),
                    ),
                  ),
                  _toggled || _bpm != 0
                      ? const SizedBox()
                      : Expanded(
                          flex: 3,
                          child: Center(
                            child: Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 8.0),
                              child: Column(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: [
                                  Text(
                                    'When You Click To Measure The Heart Beats\nPlace Your Finger On The Camera'
                                        .toUpperCase(),
                                    textAlign: TextAlign.center,
                                    style:
                                        theme.textTheme.displaySmall?.copyWith(
                                      fontSize: 16.0,
                                      letterSpacing: 0.0,
                                      fontWeight: FontWeight.w400,
                                    ),
                                  ),
                                  IconButton(
                                    onPressed: () {
                                      _startPPG(context, theme);
                                    },
                                    icon: _toggled
                                        ? const SizedBox()
                                        : const Icon(Icons
                                            .local_fire_department_rounded),
                                    color: theme.primaryColor,
                                    iconSize: 65.0,
                                    splashColor:
                                        theme.primaryColor.withOpacity(0.4),
                                    splashRadius: 100.0,
                                    highlightColor:
                                        theme.primaryColor.withOpacity(0.2),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                ],
              ),
            ),
          );
  }
}
