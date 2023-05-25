import 'package:flutter/material.dart';
import 'package:heart_beat_monitor/models/user.dart';
import 'package:heart_beat_monitor/pages/home_page.dart';
import 'package:heart_beat_monitor/services/db_service.dart';
import 'package:heart_beat_monitor/services/preference_service.dart';
import 'package:heart_beat_monitor/models/session.dart';
import 'package:heart_beat_monitor/utils/constants.dart';
import 'package:heart_beat_monitor/widgets/cup_button.dart';
import 'package:heart_beat_monitor/widgets/report_chart.dart';

class SessionsPage extends StatefulWidget {
  const SessionsPage({
    super.key,
    required this.user,
  });

  final User user;

  @override
  State<SessionsPage> createState() => _SessionsPageState();
}

class _SessionsPageState extends State<SessionsPage> {
  bool isLoading = false;
  final _db = DBService();
  List<Session> sessions = [];

  void getAllSessions() async {
    setState(() {
      isLoading = true;
    });
    int? id = await PreferenceService.getIDPref();
    List<Session> result = await _db.getSessions(id!);
    setState(() {
      sessions = result;
      isLoading = false;
    });
  }

  void clearAllSessions(ThemeData theme) async {
    setState(() {
      isLoading = true;
    });
    int result = await _db.deleteSessions();
    if (result > 0) {
      setState(() {
        sessions.clear();
      });
    } else {
      kSnakBar(
        theme,
        'There is no sessions found to remove!',
        const Duration(seconds: 2),
      );
    }
    setState(() {
      isLoading = false;
    });
  }

  Color getSessionColor(String datetime, int bpm) {
    User u = widget.user;
    if (getDate(datetime).difference(DateTime.now()).inDays < 0) {
      if (bpm < (u.getBPMRange()['min'] as int)) {
        return const Color.fromARGB(255, 255, 186, 186).withOpacity(0.3);
      } else if (bpm > (u.getBPMRange()['max'] as int)) {
        return const Color(0xffE92C2C).withOpacity(0.3);
      } else {
        return const Color(0xffF96767).withOpacity(0.3);
      }
    } else {
      if (bpm < (u.getBPMRange()['min'] as int)) {
        return const Color.fromARGB(255, 255, 186, 186);
      } else if (bpm > (u.getBPMRange()['max'] as int)) {
        return const Color(0xffE92C2C);
      } else {
        return const Color(0xffF96767);
      }
    }
  }

  DateTime getDate(String str) {
    List<String> date = str.split("-");
    List<String> time = date[2].split(":");
    int year = int.parse(date[0]);
    int month = int.parse(date[1]);
    int day = int.parse(date[2].substring(0, 2));
    int hour = int.parse(time[0].substring(2));
    int min = int.parse(time[1]);
    int sec = int.parse(time[2].substring(0, 2));

    return DateTime(
      year,
      month,
      day,
      hour,
      min,
      sec,
    );
  }

  @override
  void initState() {
    super.initState();
    getAllSessions();
  }

  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);
    return DefaultTabController(
      length: 3,
      child: WillPopScope(
        onWillPop: () async => false,
        child: Scaffold(
          backgroundColor: theme.scaffoldBackgroundColor,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            title: Text(
              'Sessions Log'.toUpperCase(),
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
                  onPressed: () => clearAllSessions(theme),
                  icon: IconTheme(
                    data: theme.iconTheme,
                    child: const Icon(
                      Icons.clear_all_rounded,
                    ),
                  ),
                ),
              ),
            ],
            bottom: TabBar(
              labelColor: theme.textTheme.displayMedium?.color,
              indicatorColor: theme.textTheme.displayMedium?.color,
              unselectedLabelColor: Colors.grey,
              labelStyle: theme.textTheme.displayMedium
                  ?.copyWith(fontSize: 16.0, letterSpacing: -1.0),
              tabs: const [
                Tab(text: 'Sessions'),
                Tab(text: 'Daily Report'),
                Tab(text: 'Weekly Report'),
              ],
            ),
          ),
          body: TabBarView(
            physics: const BouncingScrollPhysics(),
            children: [
              isLoading
                  ? Center(
                      child: CircularProgressIndicator(
                        strokeWidth: 2.0,
                        color: theme.primaryColor,
                      ),
                    )
                  : SafeArea(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            vertical: 8.0, horizontal: 12.0),
                        child: sessions.isEmpty
                            ? Center(
                                child: Text(
                                  'No Sessions Found!',
                                  textAlign: TextAlign.center,
                                  style: theme.textTheme.displayMedium,
                                ),
                              )
                            : Column(
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.only(bottom: 8.0),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.end,
                                      children: [
                                        Text(
                                          '↤',
                                          style: theme.textTheme.displayMedium,
                                        ),
                                        Text(
                                          'Swipe Right or Left to Delete a Session',
                                          style: theme.textTheme.displayMedium
                                              ?.copyWith(fontSize: 14.0),
                                        ),
                                        Text(
                                          '↦',
                                          style: theme.textTheme.displayMedium,
                                        ),
                                      ],
                                    ),
                                  ),
                                  Expanded(
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 12.0),
                                      child: ListView.builder(
                                        itemBuilder: (context, index) =>
                                            Dismissible(
                                          background: Container(
                                            color: Colors.transparent,
                                            child: Padding(
                                              padding:
                                                  const EdgeInsets.all(16.0),
                                              child: Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.start,
                                                children: const [
                                                  Icon(
                                                    Icons.delete_rounded,
                                                    color: Colors.red,
                                                    size: 52.0,
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                          secondaryBackground: Container(
                                            color: Colors.transparent,
                                            child: Padding(
                                              padding:
                                                  const EdgeInsets.all(16.0),
                                              child: Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.end,
                                                children: const [
                                                  Icon(
                                                    Icons.delete_rounded,
                                                    color: Colors.red,
                                                    size: 52.0,
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                          key:
                                              ValueKey<int>(sessions[index].id),
                                          onDismissed: (direction) async {
                                            await _db.deleteSessionByID(
                                                sessions[index].id);
                                            getAllSessions();
                                            setState(() {
                                              sessions.removeAt(index);
                                            });
                                          },
                                          confirmDismiss: (direction) async {
                                            return await showDialog(
                                              context: context,
                                              builder: (context) => AlertDialog(
                                                // actionsOverflowDirection:
                                                //     VerticalDirection.down,
                                                // actionsOverflowAlignment:
                                                //     OverflowBarAlignment.center,
                                                // actionsOverflowButtonSpacing:
                                                //     12.0,
                                                actionsAlignment:
                                                    MainAxisAlignment
                                                        .spaceAround,
                                                title: const Text(
                                                    "Remove Session"),
                                                content: Text(
                                                  "Are you sure you want to delete this session?",
                                                  style: theme
                                                      .textTheme.displayMedium,
                                                ),
                                                actions: [
                                                  CupButton(
                                                    onPress: () =>
                                                        Navigator.of(context)
                                                            .pop(true),
                                                    text: "YES",
                                                  ),
                                                  CupButton(
                                                    onPress: () =>
                                                        Navigator.of(context)
                                                            .pop(false),
                                                    text: "NO",
                                                  ),
                                                ],
                                              ),
                                            );
                                          },
                                          child: Card(
                                            shape: RoundedRectangleBorder(
                                              side: BorderSide.none,
                                              borderRadius:
                                                  BorderRadius.circular(8.0),
                                            ),
                                            color: getDate(sessions[index]
                                                            .dateTime)
                                                        .day <
                                                    DateTime.now().day
                                                ? theme.colorScheme.background
                                                    .withOpacity(0.3)
                                                : theme.colorScheme.background,
                                            elevation: 0.0,
                                            margin: const EdgeInsets.symmetric(
                                                vertical: 12.0),
                                            child: ListTile(
                                              contentPadding:
                                                  const EdgeInsets.all(12.0),
                                              leading: Text(
                                                sessions[index].bpm.toString(),
                                                style: theme
                                                    .textTheme.labelLarge
                                                    ?.copyWith(
                                                  color: getSessionColor(
                                                      sessions[index].dateTime,
                                                      sessions[index].bpm),
                                                ),
                                              ),
                                              trailing: Text(
                                                '${sessions[index].dateTime.substring(0, 10)}\n${sessions[index].dateTime.substring(11, 19)}',
                                                textAlign: TextAlign.right,
                                                style:
                                                    theme.textTheme.labelSmall,
                                              ),
                                            ),
                                          ),
                                        ),
                                        itemCount: sessions.length,
                                        physics: const BouncingScrollPhysics(),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                      ),
                    ),
              ReportChart(
                user: widget.user,
                sessions: sessions,
                theme: theme,
              ),
              ReportChart(
                  user: widget.user,
                  sessions: sessions,
                  theme: theme,
                  isDaily: false),
            ],
          ),
        ),
      ),
    );
  }
}
