import 'package:flutter/material.dart';
import 'package:heart_beat_monitor/models/session.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:heart_beat_monitor/models/user.dart';
import 'package:heart_beat_monitor/services/theme_service.dart';

class ReportChart extends StatelessWidget {
  final User user;
  final List<Session> sessions;
  final ThemeData theme;
  final bool isDaily;

  const ReportChart({
    super.key,
    required this.user,
    required this.sessions,
    required this.theme,
    this.isDaily = true,
  });

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

  Map<dynamic, dynamic> configureSessions(List<Session> sessions) {
    if (sessions.isEmpty) return {};
    DateTime now = DateTime.now();
    Map<DateTime, int> dOutput = {};
    Map<int, int> wOutput = {1: 0, 2: 0, 3: 0, 4: 0, 5: 0, 6: 0, 7: 0};
    if (isDaily) {
      for (Session session in sessions) {
        if (getDate(session.dateTime).day == now.day) {
          dOutput[getDate(session.dateTime)] = session.bpm;
        }
      }
      print(dOutput);
      return dOutput;
    } else {
      int monCount = 0,
          tueCount = 0,
          wedCount = 0,
          thuCount = 0,
          friCount = 0,
          satCount = 0,
          sunCount = 0;
      for (Session session in sessions) {
        if (getDate(session.dateTime).isAfter(
              now.subtract(
                Duration(days: now.weekday),
              ),
            ) &&
            getDate(session.dateTime).isBefore(
              now.add(
                const Duration(days: 7),
              ),
            )) {
          switch (getDate(session.dateTime).weekday) {
            case DateTime.monday:
              wOutput[DateTime.monday] =
                  wOutput[DateTime.monday]! + session.bpm;
              monCount++;
              break;
            case DateTime.tuesday:
              wOutput[DateTime.tuesday] =
                  wOutput[DateTime.tuesday]! + session.bpm;
              tueCount++;
              break;
            case DateTime.wednesday:
              wOutput[DateTime.wednesday] =
                  wOutput[DateTime.wednesday]! + session.bpm;
              wedCount++;
              break;
            case DateTime.thursday:
              wOutput[DateTime.thursday] =
                  wOutput[DateTime.thursday]! + session.bpm;
              thuCount++;
              break;
            case DateTime.friday:
              wOutput[DateTime.friday] =
                  wOutput[DateTime.friday]! + session.bpm;
              friCount++;
              break;
            case DateTime.saturday:
              wOutput[DateTime.saturday] =
                  wOutput[DateTime.saturday]! + session.bpm;
              satCount++;
              break;
            case DateTime.sunday:
              wOutput[DateTime.sunday] =
                  wOutput[DateTime.sunday]! + session.bpm;
              sunCount++;
              break;
          }
        }
      }
      wOutput[DateTime.monday] = wOutput[DateTime.monday] != 0
          ? wOutput[DateTime.monday]! ~/ monCount
          : 0;
      wOutput[DateTime.tuesday] = wOutput[DateTime.tuesday] != 0
          ? wOutput[DateTime.tuesday]! ~/ tueCount
          : 0;
      wOutput[DateTime.wednesday] = wOutput[DateTime.wednesday] != 0
          ? wOutput[DateTime.wednesday]! ~/ wedCount
          : 0;
      wOutput[DateTime.thursday] = wOutput[DateTime.thursday] != 0
          ? wOutput[DateTime.thursday]! ~/ thuCount
          : 0;
      wOutput[DateTime.friday] = wOutput[DateTime.friday] != 0
          ? wOutput[DateTime.friday]! ~/ friCount
          : 0;
      wOutput[DateTime.saturday] = wOutput[DateTime.saturday] != 0
          ? wOutput[DateTime.saturday]! ~/ satCount
          : 0;
      wOutput[DateTime.sunday] = wOutput[DateTime.sunday] != 0
          ? wOutput[DateTime.sunday]! ~/ sunCount
          : 0;
      print(wOutput);
      return wOutput;
    }
  }

  @override
  Widget build(BuildContext context) {
    return _barChartData(context) == null
        ? Center(
            child: Text(
              'No Sessions Found!',
              textAlign: TextAlign.center,
              style: theme.textTheme.displayMedium,
            ),
          )
        : Padding(
            padding: const EdgeInsets.all(24.0),
            child: isDaily
                ? BarChart(
                    _barChartData(context)!,
                    swapAnimationDuration: const Duration(milliseconds: 150),
                    swapAnimationCurve: Curves.linear,
                  )
                : BarChart(
                    _barChartData(context)!,
                    swapAnimationDuration: const Duration(milliseconds: 150),
                    swapAnimationCurve: Curves.linear,
                  ),
          );
  }

  BarChartData? _barChartData(BuildContext context) {
    final list = configureSessions(sessions).entries.toList();
    if (list.isEmpty) return null;
    return BarChartData(
        barTouchData: BarTouchData(
          touchTooltipData: BarTouchTooltipData(
            tooltipBgColor: Colors.transparent,
            tooltipPadding: const EdgeInsets.all(0),
            tooltipMargin: 0,
            getTooltipItem: (group, groupIndex, rod, rodIndex) {
              String tooltipText = '${rod.toY.toInt()}';
              return BarTooltipItem(
                tooltipText,
                TextStyle(
                  color: ThemeService.kColorDark.value,
                  // fontSize: list.length * 0.05 + 12.0,
                  fontWeight: FontWeight.bold,
                ),
              );
            },
          ),
        ),
        gridData: FlGridData(
          show: !isDaily,
          drawVerticalLine: true,
          horizontalInterval: 1,
          verticalInterval: 1,
          getDrawingHorizontalLine: (value) {
            return FlLine(
              color: Colors.grey.shade300,
              strokeWidth: 0,
            );
          },
          getDrawingVerticalLine: (value) {
            return FlLine(
              color: Colors.grey.shade500,
              strokeWidth: 0,
            );
          },
        ),
        titlesData: FlTitlesData(
          show: true,
          rightTitles: AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          topTitles: AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 30,
              interval: 1,
              getTitlesWidget: bottomTitleWidgets,
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: false,
              interval: 1,
              getTitlesWidget: leftTitleWidgets,
              reservedSize: 48,
            ),
          ),
        ),
        borderData: FlBorderData(
          show: false,
          border: Border.all(width: 3.0, color: ThemeService.kColorDark.value),
        ),
        minY: user.getBPMRange()["min"]!.toDouble() - 10.0,
        maxY: user.getBPMRange()["max"]!.toDouble() + 10.0,
        barGroups: (isDaily
                ? configureSessions(sessions) as Map<DateTime, int>
                : configureSessions(sessions) as Map<int, int>)
            .entries
            .map(
              (e) => BarChartGroupData(
                x: isDaily ? list.length : (e as MapEntry<int, int>).key,
                showingTooltipIndicators: [0],
                barRods: [
                  BarChartRodData(
                    color: ThemeService.kColorDark.value,
                    width:
                        MediaQuery.of(context).size.width / list.length * 0.5,
                    borderRadius: BorderRadius.circular(2.0),
                    borderSide: BorderSide.none,
                    toY: e.value.toDouble(),
                  ),
                ],
              ),
            )
            .toList());
  }

  Widget bottomTitleWidgets(double value, TitleMeta meta) {
    String text = "";
    switch (value.toInt()) {
      case 1:
        text = "Mon";
        break;
      case 2:
        text = "Tue";
        break;
      case 3:
        text = "Wed";
        break;
      case 4:
        text = "Thu";
        break;
      case 5:
        text = "Fri";
        break;
      case 6:
        text = "Sat";
        break;
      case 7:
        text = "Sun";
        break;
      default:
        "";
    }
    return isDaily
        ? const SizedBox()
        // SideTitleWidget(
        //     axisSide: meta.axisSide,
        //     child: Text(value.toInt().toString()),
        //   )
        : Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: Text(
              text,
              textAlign: TextAlign.end,
              style: theme.textTheme.displaySmall?.copyWith(
                fontSize: 16.0,
                letterSpacing: 0.0,
                fontWeight: FontWeight.w400,
              ),
            ),
          );
  }

  Widget leftTitleWidgets(double value, TitleMeta meta) => Text(
        isDaily
            ? (configureSessions(sessions) as Map<DateTime, int>)
                    .values
                    .contains(value.toInt())
                ? value.toInt().toString()
                : ''
            : (configureSessions(sessions) as Map<int, int>)
                    .values
                    .contains(value.toInt())
                ? value.toInt().toString()
                : '',
        textAlign: TextAlign.left,
        style: theme.textTheme.displaySmall?.copyWith(
          fontSize: 10.0,
          letterSpacing: 0.0,
          fontWeight: FontWeight.w400,
        ),
      );
}
